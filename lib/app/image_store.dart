import 'dart:io';

import 'package:flutter/material.dart';

import 'theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// 图片存取：统一压缩并复制到 App 私有目录。
class ImageStore {
  ImageStore._();

  static const _uuid = Uuid();

  static Future<Directory> _imageDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'images'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// 从相册选图（可多选），返回保存后的本地路径列表。
  static Future<List<String>> pickFromGallery({int maxCount = 9}) async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      imageQuality: 82,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    final result = <String>[];
    for (final f in files.take(maxCount)) {
      final saved = await _save(f);
      if (saved != null) result.add(saved);
    }
    return result;
  }

  /// 拍照。
  static Future<String?> pickFromCamera() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (file == null) return null;
    return _save(file);
  }

  static Future<String?> _save(XFile file) async {
    try {
      final dir = await _imageDir();
      final ext = p.extension(file.path).isEmpty
          ? '.jpg'
          : p.extension(file.path);
      final name = '${_uuid.v4()}$ext';
      final target = p.join(dir.path, name);
      await File(file.path).copy(target);
      return target;
    } catch (_) {
      return null;
    }
  }

  /// 图片是否仍存在。
  static bool exists(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  /// 删除图片文件（仅在确认无引用后调用）。
  static Future<void> delete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }

  /// 图片目录占用大小（字节）。
  static Future<int> storageUsage() async {
    try {
      final dir = await _imageDir();
      int total = 0;
      await for (final e in dir.list()) {
        if (e is File) total += await e.length();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  /// 清理无引用图片，返回清理数量。
  static Future<int> cleanUnreferenced(Set<String> referenced) async {
    int count = 0;
    try {
      final dir = await _imageDir();
      await for (final e in dir.list()) {
        if (e is File && !referenced.contains(e.path)) {
          await e.delete();
          count++;
        }
      }
    } catch (_) {}
    return count;
  }
}

/// 图片加载失败时回退到默认图。
class ItemImage extends StatelessWidget {
  const ItemImage(
    this.path, {
    super.key,
    this.icon,
    this.size,
    this.borderRadius,
  });

  final String? path;
  final IconData? icon;
  final double? size;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius ?? 0);
    final expand = size == double.infinity;
    Widget child;
    if (ImageStore.exists(path)) {
      // 按显示尺寸解码，避免大图全尺寸解码造成滚动掉帧。
      final cacheWidth = expand
          ? (MediaQuery.sizeOf(context).width *
                    MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(64, 1920)
          : size == null
          ? null
          : (size! * MediaQuery.devicePixelRatioOf(context)).round().clamp(
              64,
              1440,
            );
      child = ClipRRect(
        borderRadius: radius,
        child: Image.file(
          File(path!),
          width: size,
          height: size,
          cacheWidth: cacheWidth,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(context),
        ),
      );
    } else {
      child = _fallback(context);
    }
    if (expand) {
      // 详情页大图：填满父容器，不固定宽高。
      return child;
    }
    return SizedBox(width: size, height: size, child: child);
  }

  Widget _fallback(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // 彩色占位：薄荷 tint 底 + 主题色 icon（告别纯白灰块）。
    final tint = dark ? AppTheme.greenLight : AppTheme.green;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: 0.16),
            tint.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: borderRadius == null
            ? null
            : BorderRadius.circular(borderRadius!),
        border: Border.all(color: tint.withValues(alpha: 0.22)),
      ),
      child: Icon(
        icon ?? Icons.inventory_2_outlined,
        size: size == null ? 24 : size! * 0.4,
        color: tint,
      ),
    );
  }
}
