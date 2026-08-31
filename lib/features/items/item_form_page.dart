import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/constants/default_categories.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../domain/models/category.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_event.dart';
import '../../domain/models/location.dart';
import '../../domain/services/budget.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/dup_warning.dart';
import '../../shared/widgets/radar_view.dart';
import '../locations/location_picker_sheet.dart';
import 'sale_form_sheet.dart';

/// 添加 / 编辑物品表单。
class ItemFormPage extends ConsumerStatefulWidget {
  const ItemFormPage({super.key, this.existingId, this.initialLocationId});

  final String? existingId;
  final String? initialLocationId;

  @override
  ConsumerState<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends ConsumerState<ItemFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController(text: '1');
  final _merchantCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _locationDetailCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();

  String? _coverImage;
  List<String> _extraImages = [];
  List<String> _invoiceImages = [];
  String? _categoryId;
  ItemStatus _status = ItemStatus.inUse;
  DateTime _purchaseDate = DateTime.now();
  String _currency = 'CNY';
  String? _purchaseChannel;
  Location? _location;
  int? _warrantyMonths;
  int? _maintenanceMonths;
  UsageFrequency? _usageFrequency;
  DateTime? _warrantyEndDate;
  int? _overallScore;
  final Map<String, int?> _dimScores = {
    for (final d in kScoreDimensions) d.$1: null,
  };
  List<String> _tags = [];
  Timer? _draftTimer;
  bool _initialized = false;

  String? _existingId;
  Item? _existing;

  @override
  void initState() {
    super.initState();
    _existingId = widget.existingId;
    _loadDraft();
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _quantityCtrl.dispose();
    _merchantCtrl.dispose();
    _orderCtrl.dispose();
    _notesCtrl.dispose();
    _locationDetailCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final settings = ref.read(appSettingsProvider);
    _currency = settings.currency;
    _purchaseChannel ??= settings.defaultChannel;

    if (_existingId != null) {
      final item = await ref.read(itemRepoProvider).getById(_existingId!);
      if (item != null && mounted) {
        setState(() {
          _existing = item;
          _nameCtrl.text = item.name;
          _priceCtrl.text = Money.toDecimalString(item.purchasePrice);
          _coverImage = item.coverImagePath;
          _extraImages = List.of(item.additionalImagePaths);
          _invoiceImages = List.of(item.invoiceImagePaths);
          _categoryId = item.categoryId;
          _status = item.status;
          _purchaseDate = item.purchaseDate;
          _currency = item.currency;
          _purchaseChannel = item.purchaseChannel ?? _purchaseChannel;
          _brandCtrl.text = item.brand ?? '';
          _modelCtrl.text = item.model ?? '';
          _quantityCtrl.text = item.quantity.toString();
          _merchantCtrl.text = item.merchantName ?? '';
          _orderCtrl.text = item.orderNumber ?? '';
          _notesCtrl.text = item.notes ?? '';
          _locationDetailCtrl.text = item.locationDetail ?? '';
          _tags = List.of(item.tags);
          _warrantyMonths = item.warrantyMonths;
          _maintenanceMonths = item.maintenanceMonths;
          _usageFrequency = item.usageFrequency;
          _warrantyEndDate = item.warrantyEndDate;
          _overallScore = item.overallScore;
          _dimScores['scoreValue'] = item.scoreValue;
          _dimScores['scoreUsage'] = item.scoreUsage;
          _dimScores['scoreFavorite'] = item.scoreFavorite;
          _dimScores['scoreUtilization'] = item.scoreUtilization;
          _dimScores['scoreCost'] = item.scoreCost;
          _dimScores['scoreRetention'] = item.scoreRetention;
        });
      }
    } else {
      // 新建：仅消费 AI 一句话添加的预填草稿（source=ai），用完即清；
      // 手动添加不再恢复任何上一次的填写记录。
      final repo = ref.read(settingsRepoProvider);
      final draft = await repo.getJson('draft_item');
      if (draft != null &&
          draft['source'] == 'ai' &&
          mounted &&
          !_initialized) {
        _applyDraftMap(draft);
        await repo.set('draft_item', '');
      }
      if (widget.initialLocationId != null) {
        final loc = await ref
            .read(locationRepoProvider)
            .getById(widget.initialLocationId!);
        if (loc != null) setState(() => _location = loc);
      }
    }
    setState(() => _initialized = true);
  }

  void _applyDraftMap(Map<String, dynamic> d) {
    setState(() {
      _nameCtrl.text = d['name'] as String? ?? '';
      _priceCtrl.text = d['price'] as String? ?? '';
      _coverImage = d['cover'] as String?;
      _extraImages = (d['extras'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      _categoryId = d['categoryId'] as String?;
      _purchaseChannel = d['channel'] as String?;
      _brandCtrl.text = d['brand'] as String? ?? '';
      _modelCtrl.text = d['model'] as String? ?? '';
      _merchantCtrl.text = d['merchantName'] as String? ?? '';
      _orderCtrl.text = d['orderNumber'] as String? ?? '';
      _notesCtrl.text = d['notes'] as String? ?? '';
      _tags = (d['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();
      final quantity = (d['quantity'] as num?)?.toInt();
      if (quantity != null && quantity > 0) {
        _quantityCtrl.text = quantity.toString();
      }
      _warrantyMonths = (d['warrantyMonths'] as num?)?.toInt();
      _maintenanceMonths = (d['maintenanceMonths'] as num?)?.toInt();
      _usageFrequency = UsageFrequency.fromName(d['usageFrequency'] as String?);
      final locationId = d['locationId'] as String?;
      final locationName = d['locationName'] as String?;
      if (locationId != null && locationName != null) {
        _location = Location(
          id: locationId,
          name: locationName,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
      _overallScore = (d['overallScore'] as num?)?.toInt();
      final dims = d['dimScores'] as Map<String, dynamic>?;
      if (dims != null) {
        for (final key in _dimScores.keys.toList()) {
          _dimScores[key] = (dims[key] as num?)?.toInt();
        }
      }
      final dateStr = d['purchaseDate'] as String?;
      if (dateStr != null) {
        _purchaseDate = DateTime.tryParse(dateStr) ?? DateTime.now();
      }
    });
  }

  Future<void> _pickCover() async {
    final action = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            if (_coverImage != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('删除封面'),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null) return;
    if (action == 'remove') {
      setState(() => _coverImage = null);
      return;
    }
    final path = action == 'camera'
        ? await ImageStore.pickFromCamera()
        : (await ImageStore.pickFromGallery(maxCount: 1)).firstOrNull;
    if (path != null) {
      setState(() => _coverImage = path);
    }
  }

  Future<void> _pickExtraImages() async {
    final paths = await ImageStore.pickFromGallery(
      maxCount: 9 - _extraImages.length,
    );
    if (paths.isNotEmpty) {
      setState(() => _extraImages.addAll(paths));
    }
  }

  Future<void> _pickInvoiceImages() async {
    final paths = await ImageStore.pickFromGallery(
      maxCount: 6 - _invoiceImages.length,
    );
    if (paths.isNotEmpty) setState(() => _invoiceImages.addAll(paths));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _purchaseDate = d);
  }

  Future<void> _pickWarrantyEnd() async {
    final d = await showDatePicker(
      context: context,
      initialDate:
          _warrantyEndDate ?? _purchaseDate.add(const Duration(days: 365)),
      firstDate: _purchaseDate,
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _warrantyEndDate = d;
        _warrantyMonths = null;
        _maintenanceMonths = null;
        _usageFrequency = null;
      });
    }
  }

  Future<void> _pickLocation() async {
    final loc = await showLocationPickerSheet(context);
    if (!mounted) return;
    setState(() => _location = loc);
  }

  void _addTag() {
    final t = _tagCtrl.text.trim();
    if (t.isEmpty || _tags.contains(t)) return;
    setState(() {
      _tags.add(t);
      _tagCtrl.clear();
    });
  }

  /// 已填写的可选项数量摘要。
  String _moreSummary() {
    int n = 0;
    if (_brandCtrl.text.trim().isNotEmpty) n++;
    if (_modelCtrl.text.trim().isNotEmpty) n++;
    if (_merchantCtrl.text.trim().isNotEmpty) n++;
    if (_orderCtrl.text.trim().isNotEmpty) n++;
    if (_notesCtrl.text.trim().isNotEmpty) n++;
    if (_locationDetailCtrl.text.trim().isNotEmpty) n++;
    if (_tags.isNotEmpty) n++;
    if (_warrantyMonths != null || _warrantyEndDate != null) n++;
    if (_extraImages.isNotEmpty) n++;
    if (_invoiceImages.isNotEmpty) n++;
    if (_purchaseChannel != null &&
        _purchaseChannel != ref.read(appSettingsProvider).defaultChannel) {
      n++;
    }
    return n == 0 ? '选填' : '已填 $n 项';
  }

  Future<void> _openMoreSheet() async {
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.85,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    '更多信息',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Text(
                        '状态与使用',
                        style: AppTheme.title(
                          Theme.of(sheetContext).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ItemStatus.values
                            .map(
                              (status) => _StatusStamp(
                                label: status.label,
                                selected: _status == status,
                                onTap: () => setSheet(() => _status = status),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<UsageFrequency>(
                        value: _usageFrequency,
                        decoration: const InputDecoration(
                          labelText: '使用频次',
                          prefixIcon: Icon(Icons.speed_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('不设置'),
                          ),
                          ...UsageFrequency.values.map(
                            (frequency) => DropdownMenuItem(
                              value: frequency,
                              child: Text(frequency.label),
                            ),
                          ),
                        ],
                        onChanged: (value) =>
                            setSheet(() => _usageFrequency = value),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '个人评价',
                        style: AppTheme.title(
                          Theme.of(sheetContext).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _overallScoreTile(sheetContext, setSheet),
                      const SizedBox(height: 12),
                      _dimSection(sheetContext, setSheet),
                      const Divider(height: 32),
                      TextFormField(
                        controller: _brandCtrl,
                        decoration: const InputDecoration(labelText: '品牌'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _modelCtrl,
                        decoration: const InputDecoration(labelText: '型号'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '数量',
                              ),
                              validator: (v) {
                                final n = int.tryParse(v ?? '');
                                if (n == null || n <= 0) return '数量需大于 0';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _purchaseChannel,
                              decoration: const InputDecoration(
                                labelText: '购买渠道',
                              ),
                              items: PurchaseChannel.values
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.label,
                                      child: Text(c.label),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => _purchaseChannel = v,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _currency,
                              decoration: const InputDecoration(
                                labelText: '货币',
                              ),
                              items: ['CNY', 'USD', 'EUR', 'JPY', 'GBP']
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _currency = v ?? 'CNY'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _merchantCtrl,
                              decoration: const InputDecoration(
                                labelText: '商家名称',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _orderCtrl,
                        decoration: const InputDecoration(labelText: '订单号'),
                      ),
                      const SizedBox(height: 12),

                      // 标签
                      Text('标签', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ..._tags.map(
                            (t) => Chip(
                              label: Text(t),
                              onDeleted: () => setState(() => _tags.remove(t)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tagCtrl,
                              decoration: const InputDecoration(
                                hintText: '输入标签后回车',
                                isDense: true,
                              ),
                              onFieldSubmitted: (_) => _addTag(),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _addTag,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 保修
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _warrantyMonths,
                              decoration: const InputDecoration(
                                labelText: '保修时长',
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('不设置'),
                                ),
                                ...[3, 6, 12, 18, 24, 36, 48, 60].map(
                                  (m) => DropdownMenuItem(
                                    value: m,
                                    child: Text('$m 个月'),
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(() {
                                _warrantyMonths = v;
                                if (v != null) _warrantyEndDate = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: InkWell(
                              onTap: _pickWarrantyEnd,
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: '保修截止日',
                                ),
                                child: Text(
                                  _warrantyEndDate == null
                                      ? '选择'
                                      : Fmt.date(_warrantyEndDate!),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 保养/耗材周期：到期本地通知提醒
                      DropdownButtonFormField<int>(
                        value: _maintenanceMonths,
                        decoration: const InputDecoration(
                          labelText: '保养/耗材周期',
                          prefixIcon: Icon(Icons.build_circle_outlined),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('不提醒'),
                          ),
                          ...[1, 2, 3, 6, 12, 24].map(
                            (m) => DropdownMenuItem(
                              value: m,
                              child: Text('每 $m 个月'),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setState(() => _maintenanceMonths = v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _locationDetailCtrl,
                        decoration: const InputDecoration(
                          labelText: '位置补充说明',
                          hintText: '例如：衣柜第二层左侧收纳盒',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: '备注'),
                      ),
                      const SizedBox(height: 12),

                      // 其他照片
                      _imageRow(
                        title: '物品照片',
                        paths: _extraImages,
                        onAdd: _extraImages.length >= 9
                            ? null
                            : _pickExtraImages,
                        onRemove: (p) => setState(() => _extraImages.remove(p)),
                        onSetCover: (p) => setState(() {
                          _extraImages.remove(p);
                          if (_coverImage != null) {
                            _extraImages.add(_coverImage!);
                          }
                          _coverImage = p;
                        }),
                      ),
                      const SizedBox(height: 12),
                      _imageRow(
                        title: '购买票据',
                        paths: _invoiceImages,
                        onAdd: _invoiceImages.length >= 6
                            ? null
                            : _pickInvoiceImages,
                        onRemove: (p) =>
                            setState(() => _invoiceImages.remove(p)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('完成'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  /// 总评分滑条块。
  Widget _overallScoreTile(BuildContext context, StateSetter setSheet) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '评分',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              if (_overallScore != null)
                PillChip('$_overallScore 分', solid: true, compact: true)
              else
                Text('未评分', style: AppTheme.caption(cs.onSurfaceVariant)),
              if (_overallScore != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: '清除评分',
                  onPressed: () => setSheet(() => _overallScore = null),
                ),
            ],
          ),
        ),
        Slider(
          value: (_overallScore ?? 0).toDouble(),
          max: 100,
          divisions: 100,
          label: '$_overallScore',
          onChanged: (v) => setSheet(() => _overallScore = v.round()),
        ),
        // 快捷档位：10 分一档。
        SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final score in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setSheet(() => _overallScore = score),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _overallScore == score
                            ? cs.primary
                            : cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: _overallScore == score
                              ? Colors.white
                              : cs.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 六维评分：实时雷达 + 滑动条（setSheet 用于面板内实时重建）。
  Widget _dimSection(BuildContext context, StateSetter setSheet) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            '六维评分（每项 0-10 分）',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        RadarView(
          labels: [for (final d in kScoreDimensions) d.$2],
          values: [
            for (final d in kScoreDimensions) _dimScores[d.$1]?.toDouble(),
          ],
          height: 200,
        ),
        for (final d in kScoreDimensions)
          _dimSlider(context, d.$1, d.$2, setSheet),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _dimSlider(
    BuildContext context,
    String key,
    String label,
    StateSetter setSheet,
  ) {
    final cs = Theme.of(context).colorScheme;
    final value = _dimScores[key];
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Slider(
            value: (value ?? 0).toDouble(),
            max: 10,
            divisions: 10,
            label: '$value',
            onChanged: (v) {
              _dimScores[key] = v.round();
              // 面板内立即重建，让滑条与雷达实时跟随。
              setSheet(() {});
            },
          ),
        ),
        SizedBox(
          width: 34,
          child: value == null
              ? Text(
                  '—',
                  textAlign: TextAlign.right,
                  style: AppTheme.caption(cs.onSurfaceVariant),
                )
              : Text(
                  '$value',
                  textAlign: TextAlign.right,
                  style: AppTheme.bigNumber(cs.primary, size: 14),
                ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final price = Money.parse(_priceCtrl.text);
    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的购买价格')));
      return;
    }
    final categories =
        ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
    final category = categories.where((c) => c.id == _categoryId).firstOrNull;
    if (category == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请选择分类')));
      return;
    }

    final repo = ref.read(itemRepoProvider);
    final now = DateTime.now();

    var item = Item(
      id: _existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      coverImagePath: _coverImage,
      additionalImagePaths: _extraImages,
      categoryId: category.id,
      categoryName: category.name,
      purchasePrice: price,
      currency: _currency,
      purchaseDate: _purchaseDate,
      purchaseChannel: _purchaseChannel,
      merchantName: _merchantCtrl.text.trim().isEmpty
          ? null
          : _merchantCtrl.text.trim(),
      orderNumber: _orderCtrl.text.trim().isEmpty
          ? null
          : _orderCtrl.text.trim(),
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim().isEmpty ? null : _modelCtrl.text.trim(),
      quantity: int.tryParse(_quantityCtrl.text) ?? 1,
      status: _status,
      locationId: _location?.id,
      locationName: _location?.name,
      locationDetail: _locationDetailCtrl.text.trim().isEmpty
          ? null
          : _locationDetailCtrl.text.trim(),
      locationImagePath: _location?.imagePath,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      tags: _tags,
      isFavorite: _existing?.isFavorite ?? false,
      warrantyMonths: _warrantyMonths,
      warrantyEndDate: _warrantyEndDate,
      maintenanceMonths: _maintenanceMonths,
      usageFrequency: _usageFrequency,
      aiTags: _existing?.aiTags,
      aiTagsSourceName: _existing?.aiTagsSourceName,
      scoreValue: _dimScores['scoreValue'],
      scoreUsage: _dimScores['scoreUsage'],
      scoreFavorite: _dimScores['scoreFavorite'],
      scoreUtilization: _dimScores['scoreUtilization'],
      scoreCost: _dimScores['scoreCost'],
      scoreRetention: _dimScores['scoreRetention'],
      overallScore: _overallScore,
      invoiceImagePaths: _invoiceImages,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );

    final wasSold = _existing?.status == ItemStatus.sold;
    final nowSold = _status == ItemStatus.sold;

    // 状态改为已转卖：弹出转卖表单。
    if (nowSold && !wasSold) {
      final sale = await showSaleFormSheet(context, itemId: item.id);
      if (sale == null) {
        setState(() => _status = _existing?.status ?? ItemStatus.inUse);
        return;
      }
      await ref.read(saleRepoProvider).upsert(sale);
      await repo.addEvent(
        ItemEvent(
          id: '',
          itemId: item.id,
          eventType: ItemEventType.sold,
          eventDate: sale.saleDate,
          title: '转卖给${sale.platform ?? '他人'}',
          amount: sale.salePrice,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // 取消已转卖状态：确认保留或删除历史转卖记录。
    if (wasSold && !nowSold) {
      final existingSale = await ref
          .read(saleRepoProvider)
          .getByItemId(item.id);
      if (existingSale != null) {
        if (!mounted) return;
        final keep = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('保留转卖记录？'),
            content: const Text('该物品已有转卖记录。状态修改后，历史转卖记录保留还是删除？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'cancel'),
                child: const Text('取消修改'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                child: const Text('删除记录'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, 'keep'),
                child: const Text('保留'),
              ),
            ],
          ),
        );
        if (keep == 'cancel' || keep == null) {
          setState(() => _status = ItemStatus.sold);
          return;
        }
        if (keep == 'delete') {
          await ref.read(saleRepoProvider).deleteByItemId(item.id);
        }
      }
    }

    await repo.upsert(item);

    // 同步保修到期提醒（开关关闭或无保修时自动取消旧提醒）。
    final settings = ref.read(appSettingsProvider);
    unawaited(
      NotificationService.syncItemReminder(
        item,
        enabled: settings.warrantyReminderEnabled,
        daysBefore: settings.warrantyReminderDays,
      ),
    );
    unawaited(NotificationService.syncMaintenanceReminder(item));

    // 新建物品补充购买事件。
    if (_existing == null) {
      await repo.addEvent(
        ItemEvent(
          id: '',
          itemId: item.id,
          eventType: ItemEventType.purchased,
          eventDate: item.purchaseDate,
          title: '购买「${item.name}」',
          amount: item.purchasePrice,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (mounted) {
      var msg = _existing == null ? '已添加「${item.name}」' : '已保存修改';
      // 新建且购买在本月：预算达 80% 以上即时预警（剁手后立刻看到）。
      if (_existing == null &&
          settings.monthlyBudgetCents > 0 &&
          !item.purchaseDate.isBefore(DateTime(now.year, now.month))) {
        final monthStart = DateTime(now.year, now.month);
        final monthItems =
            (ref.read(itemsProvider).valueOrNull ?? const <Item>[])
                .where(
                  (i) => !i.isDeleted && !i.purchaseDate.isBefore(monthStart),
                )
                .toList();
        var monthSpend = monthItems.fold<int>(0, (s, i) => s + i.purchasePrice);
        // 流可能尚未包含新物品，补上本次的金额。
        if (!monthItems.any((i) => i.id == item.id)) {
          monthSpend += item.purchasePrice;
        }
        final budget = BudgetStatus.evaluate(
          monthSpend,
          settings.monthlyBudgetCents,
        );
        if (budget != null && budget.level != BudgetLevel.ok) {
          final pct = (budget.ratio * 100).toStringAsFixed(0);
          msg += budget.level == BudgetLevel.exceeded
              ? ' · 本月已超预算（$pct%）'
              : ' · 本月已用预算 $pct%，注意控制';
        }
      }
      showAutoToast(context, msg);
      if (_existing == null) {
        context.pushReplacement('/item/${item.id}');
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(visibleCategoriesProvider);
    if (_categoryId == null && categories.isNotEmpty) {
      // 延迟到 build 中设置默认分类。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_categoryId == null && mounted) {
          setState(() => _categoryId = categories.first.id);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(_existingId == null ? '添加物品' : '编辑物品')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: cs.surface,
            border: Border(top: BorderSide(color: cs.outlineVariant)),
          ),
          child: FilledButton(onPressed: _submit, child: const Text('保存')),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 封面
            Center(
              child: GestureDetector(
                onTap: _pickCover,
                child: Container(
                  width: double.infinity,
                  height: 170,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: _coverImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_coverImage!),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 170,
                            errorBuilder: (_, __, ___) =>
                                const _CoverPlaceholder(),
                          ),
                        )
                      : const _CoverPlaceholder(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            const _FormSectionKicker('01', '物品信息'),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: '物品名称 *',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '名称不能为空' : null,
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _nameCtrl,
              builder: (context, v, _) => DupWarningCard(
                name: v.text,
                excludeId: _existingId,
                brand: _brandCtrl.text,
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _priceCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '购买价格（元）*',
                prefixIcon: Icon(Icons.payments_outlined),
              ),
              validator: (v) {
                final p = Money.parse(v ?? '');
                if (p == null) return '金额不能为空';
                if (p < 0) return '金额不能为负';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // 分类优先：帮助用户先确认“这是什么”。
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: const InputDecoration(
                labelText: '分类 *',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CategoryIcons.of(c.icon),
                            size: 18,
                            color: c.color,
                          ),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? '请选择分类' : null,
            ),
            const SizedBox(height: 24),

            const _FormSectionKicker('02', '位置与时间'),

            InkWell(
              onTap: _pickLocation,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '存放位置',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                child: Text(_location?.name ?? '稍后设置'),
              ),
            ),
            const SizedBox(height: 14),

            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '购买日期 *',
                  prefixIcon: Icon(Icons.event_outlined),
                ),
                child: Text(Fmt.date(_purchaseDate)),
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 24),

            const _FormSectionKicker('03', '可选信息'),
            Card(
              child: InkWell(
                onTap: _openMoreSheet,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tune, size: 20, color: cs.primary),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          '更多信息',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        _moreSummary(),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _imageRow({
    required String title,
    required List<String> paths,
    VoidCallback? onAdd,
    required void Function(String) onRemove,
    void Function(String)? onSetCover,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        SizedBox(
          height: 84,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...paths.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(p),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => onRemove(p),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (onSetCover != null)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () => onSetCover(p),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.crop_free,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (onAdd != null)
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: const Icon(Icons.add_photo_alternate_outlined),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 40,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 8),
        Text(
          '添加物品照片（可选）',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 状态戳记选择器：选中=实心黄铜底白字，未选=发丝边框次要字色。
/// 配对写死，绝不依赖主题推导（曾出现选中态文字与底色同色不可读）。
class _StatusStamp extends StatelessWidget {
  const _StatusStamp({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // 深浅两模式各自的明确配对：
    // 选中底=铜 / 选中字=白(浅)或墨(深)；未选底=透明 / 字与边=次要灰。
    final bg = selected
        ? (dark ? AppTheme.greenDark : AppTheme.green)
        : Colors.transparent;
    final fg = selected
        ? (dark ? const Color(0xFF191713) : Colors.white)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTheme.motionFast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTheme.stampRadius),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : (dark ? AppTheme.darkDivider : AppTheme.lightDivider),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            height: 1.3,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// 表单编号分区头：档案登记簿的「01 基本信息」式样。
class _FormSectionKicker extends StatelessWidget {
  const _FormSectionKicker(this.no, this.title);

  final String no;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = Theme.of(context).brightness == Brightness.dark
        ? AppTheme.greenDark
        : AppTheme.green;
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 12),
      child: Row(
        children: [
          Text(
            no,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 1, height: 13, color: cs.outlineVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: AppTheme.label(cs.onSurfaceVariant)),
          ),
          Container(width: 14, height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}
