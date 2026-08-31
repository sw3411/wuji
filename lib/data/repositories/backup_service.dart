import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_info.dart';
import '../../domain/models/category.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_event.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../db/app_database.dart';
import 'category_repository.dart';
import 'item_repository.dart';
import 'location_repository.dart';
import 'sale_repository.dart';
import 'settings_repository.dart';

/// 备份恢复异常。
class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 备份与恢复。备份为单个 JSON 文件（含图片 base64）。
class BackupService {
  BackupService(
    this._db,
    this._itemRepo,
    this._locationRepo,
    this._categoryRepo,
    this._saleRepo,
    this._settingsRepo,
  );

  final AppDatabase _db;
  final ItemRepository _itemRepo;
  final LocationRepository _locationRepo;
  final CategoryRepository _categoryRepo;
  final SaleRepository _saleRepo;
  final SettingsRepository _settingsRepo;

  /// 导出备份文件并调起系统分享。
  Future<File> export() async {
    final data = await _buildPayload();

    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now();
    final name =
        'wuji_backup_${stamp.year}${_two(stamp.month)}${_two(stamp.day)}_${_two(stamp.hour)}${_two(stamp.minute)}.${AppInfo.backupFileExtension}';
    final file = File(p.join(dir.path, name));
    await file.writeAsString(jsonEncode(data), flush: true);

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: '${AppInfo.appName} 数据备份');
    await _settingsRepo.set(
      SettingsRepository.keyLastBackupAt,
      DateTime.now().toIso8601String(),
    );
    return file;
  }

  /// 仅生成备份数据（测试用）。
  Future<Map<String, dynamic>> _buildPayload() async {
    final items = await _itemRepo.getAll();
    final locations = await _locationRepo.getAll();
    final categories = await _categoryRepo.getAll();
    final settings = await _settingsRepo.exportAll();

    final sales = (await _db.select(_db.saleRecords).get())
        .map(AppDatabase.toSaleRecord)
        .toList();
    final events = (await _db.select(_db.itemEvents).get())
        .map(AppDatabase.toItemEvent)
        .toList();

    // 收集全部图片引用。
    final imagePaths = <String>{};
    for (final i in items) {
      if (i.coverImagePath != null) imagePaths.add(i.coverImagePath!);
      imagePaths.addAll(i.additionalImagePaths);
      imagePaths.addAll(i.invoiceImagePaths);
    }
    for (final l in locations) {
      if (l.imagePath != null) imagePaths.add(l.imagePath!);
    }
    for (final e in events) {
      imagePaths.addAll(e.imagePaths);
    }

    final images = <String, String>{};
    for (final path in imagePaths) {
      final f = File(path);
      if (await f.exists()) {
        images[path] = base64Encode(await f.readAsBytes());
      }
    }

    return {
      'app': AppInfo.appName,
      'format': 'wuji-backup',
      'version': AppInfo.backupVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
      'locations': locations.map((l) => l.toJson()).toList(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'saleRecords': sales.map((s) => s.toJson()).toList(),
      'itemEvents': events.map((e) => e.toJson()).toList(),
      'settings': settings,
      'images': images,
    };
  }

  /// 校验备份文件结构，不写入数据。
  Future<Map<String, dynamic>> validate(File file) async {
    Map<String, dynamic> data;
    try {
      data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    } catch (_) {
      throw BackupException('文件不是有效的 JSON，可能已损坏');
    }
    if (data['format'] != 'wuji-backup') {
      throw BackupException('这不是「${AppInfo.appName}」的备份文件');
    }
    final version = (data['version'] as num?)?.toInt() ?? 0;
    if (version > AppInfo.backupVersion) {
      throw BackupException(
        '备份版本（v$version）高于当前 App 支持的版本（v${AppInfo.backupVersion}），请先升级 App',
      );
    }
    if (data['items'] is! List) {
      throw BackupException('备份缺少物品数据，文件可能不完整');
    }
    return data;
  }

  /// 恢复备份。overwrite=true 覆盖现有数据，false 合并（按 id 去重，新数据优先）。
  /// 恢复前自动创建当前数据的临时备份。
  Future<int> restore(
    Map<String, dynamic> data, {
    required bool overwrite,
  }) async {
    // 先把当前数据写一份临时备份，失败可回滚。
    final tempBackup = await _buildPayload();
    final dir = await getApplicationDocumentsDirectory();
    final rollbackFile = File(
      p.join(
        dir.path,
        'rollback_${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    await rollbackFile.writeAsString(jsonEncode(tempBackup), flush: true);

    try {
      if (overwrite) {
        await _db.delete(_db.items).go();
        await _db.delete(_db.locations).go();
        await _db.delete(_db.categories).go();
        await _db.delete(_db.saleRecords).go();
        await _db.delete(_db.itemEvents).go();
      }

      int count = 0;
      for (final c in (data['categories'] as List)) {
        await _categoryRepo.upsert(
          Category.fromJson(c as Map<String, dynamic>),
        );
      }
      for (final l in (data['locations'] as List)) {
        await _locationRepo.upsert(
          Location.fromJson(l as Map<String, dynamic>),
        );
      }
      for (final raw in (data['items'] as List)) {
        await _itemRepo.upsert(Item.fromJson(raw as Map<String, dynamic>));
        count++;
      }
      for (final raw in (data['saleRecords'] as List? ?? const [])) {
        await _saleRepo.upsert(
          SaleRecord.fromJson(raw as Map<String, dynamic>),
        );
      }
      for (final raw in (data['itemEvents'] as List? ?? const [])) {
        await _itemRepo.addEvent(
          ItemEvent.fromJson(raw as Map<String, dynamic>),
        );
      }
      if (data['settings'] is Map<String, dynamic>) {
        await _settingsRepo.importAll(
          (data['settings'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v.toString()),
          ),
          overwrite: overwrite,
        );
      }

      // 恢复图片。
      final images = data['images'] as Map<String, dynamic>? ?? {};
      final appDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDir.path, 'images'));
      if (!imageDir.existsSync()) imageDir.createSync(recursive: true);
      for (final e in images.entries) {
        final target = p.join(imageDir.path, p.basename(e.key));
        try {
          await File(target).writeAsBytes(base64Decode(e.value as String));
        } catch (_) {
          // 单张图片失败不中断整体恢复。
        }
      }
      return count;
    } catch (e) {
      throw BackupException('恢复失败：$e。原数据已保留临时备份（${rollbackFile.path}）');
    }
  }

  /// 导出 CSV（物品清单），并调起系统分享。
  Future<File> exportCsv() async {
    final items = await _itemRepo.getAll();
    final buffer = StringBuffer();
    buffer.writeln('名称,分类,购买价格,货币,购买日期,渠道,品牌,型号,数量,状态,位置,标签,备注');
    for (final i in items) {
      String esc(String s) =>
          s.contains(',') || s.contains('"') || s.contains('\n')
          ? '"${s.replaceAll('"', '""')}"'
          : s;
      buffer.writeln(
        [
          esc(i.name),
          esc(i.categoryName),
          (i.purchasePrice / 100).toStringAsFixed(2),
          i.currency,
          i.purchaseDate.toIso8601String().substring(0, 10),
          esc(i.purchaseChannel ?? ''),
          esc(i.brand ?? ''),
          esc(i.model ?? ''),
          i.quantity.toString(),
          esc(i.status.label),
          esc(i.locationName ?? ''),
          esc(i.tags.join(' ')),
          esc(i.notes ?? ''),
        ].join(','),
      );
    }
    final dir = await getTemporaryDirectory();
    final file = File(
      p.join(
        dir.path,
        'wuji_items_${DateTime.now().millisecondsSinceEpoch}.csv',
      ),
    );
    await file.writeAsString('\uFEFF${buffer.toString()}', flush: true);
    await Share.shareXFiles([
      XFile(file.path),
    ], subject: '${AppInfo.appName} 物品清单');
    return file;
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
