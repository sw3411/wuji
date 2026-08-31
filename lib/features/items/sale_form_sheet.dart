import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../../app/providers.dart';
import '../../core/utils/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_event.dart';
import '../../domain/models/sale_record.dart';
import '../../shared/widgets/common.dart';

/// 转卖信息表单（新建 / 编辑）。
Future<SaleRecord?> showSaleFormSheet(
  BuildContext context, {
  SaleRecord? existing,
  required String itemId,
}) {
  return showModalBottomSheet<SaleRecord>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (context) => _SaleFormSheet(existing: existing, itemId: itemId),
  );
}

class _SaleFormSheet extends StatefulWidget {
  const _SaleFormSheet({this.existing, required this.itemId});

  final SaleRecord? existing;
  final String itemId;

  @override
  State<_SaleFormSheet> createState() => _SaleFormSheetState();
}

class _SaleFormSheetState extends State<_SaleFormSheet> {
  late final TextEditingController _price = TextEditingController(
    text: widget.existing == null
        ? ''
        : Money.toDecimalString(widget.existing!.salePrice),
  );
  late final TextEditingController _shipping = TextEditingController(
    text: widget.existing == null || widget.existing!.shippingCost == 0
        ? ''
        : Money.toDecimalString(widget.existing!.shippingCost),
  );
  late final TextEditingController _fee = TextEditingController(
    text: widget.existing == null || widget.existing!.platformFee == 0
        ? ''
        : Money.toDecimalString(widget.existing!.platformFee),
  );
  late final TextEditingController _other = TextEditingController(
    text: widget.existing == null || widget.existing!.otherCost == 0
        ? ''
        : Money.toDecimalString(widget.existing!.otherCost),
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.existing?.buyerNote ?? '',
  );

  late DateTime _date = widget.existing?.saleDate ?? DateTime.now();
  String _platform = '';
  String? _error;

  @override
  void dispose() {
    _price.dispose();
    _shipping.dispose();
    _fee.dispose();
    _other.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _date = d);
  }

  void _submit() {
    final price = Money.parse(_price.text);
    if (price == null) {
      setState(() => _error = '请输入有效的转卖价格');
      return;
    }
    if (price < 0) {
      setState(() => _error = '转卖价格不能为负数');
      return;
    }
    final shipping = Money.parse(_shipping.text) ?? 0;
    final fee = Money.parse(_fee.text) ?? 0;
    final other = Money.parse(_other.text) ?? 0;

    Navigator.pop(
      context,
      SaleRecord(
        id:
            widget.existing?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        itemId: widget.itemId,
        salePrice: price,
        saleDate: _date,
        platform: _platform.isEmpty ? widget.existing?.platform : _platform,
        buyerNote: _note.text.trim().isEmpty ? null : _note.text.trim(),
        shippingCost: shipping,
        platformFee: fee,
        otherCost: other,
        createdAt: widget.existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.existing;
    final platforms = [...kSalePlatforms];
    if (e?.platform != null && !platforms.contains(e!.platform)) {
      platforms.insert(0, e.platform!);
    }
    _platform = _platform.isEmpty
        ? (e?.platform ?? platforms.first)
        : _platform;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('转卖信息', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _price,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: '转卖价格（元）*',
                hintText: '实际成交价',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: '转卖日期 *'),
                child: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _platform,
              decoration: const InputDecoration(labelText: '转卖平台'),
              items: platforms
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _platform = v ?? platforms.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _shipping,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: '运费（元）'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fee,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: '平台手续费（元）'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _other,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: '其他成本（元）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(labelText: '买家 / 交易备注'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: _submit, child: const Text('保存')),
            ),
          ],
        ),
      ),
    );
  }
}

/// 统一转卖流：任何入口选择「转卖」都走这里。
/// 弹转卖表单（金额/日期必填）→ 落 SaleRecord → 物品状态改已转卖 →
/// 创建或更新转卖事件（金额/日期联动）。取消表单则什么也不发生。
/// 返回 true 表示完成转卖。
Future<bool> runSellFlow(
  BuildContext context,
  WidgetRef ref,
  Item item, {
  SaleRecord? existing,
}) async {
  final result = await showSaleFormSheet(context,
      existing: existing, itemId: item.id);
  if (result == null) return false;

  final repo = ref.read(itemRepoProvider);
  final saleRepo = ref.read(saleRepoProvider);
  await saleRepo.upsert(result);
  if (item.status != ItemStatus.sold) {
    await repo.updateItem(item.copyWith(status: ItemStatus.sold));
  }

  // 事件联动：已有转卖事件则更新金额/日期/标题，否则新建。
  final events = await repo.watchEvents(item.id).first.catchError(
        (_) => const <ItemEvent>[],
      );
  final soldEvent = events
      .where((e) => e.eventType == ItemEventType.sold)
      .firstOrNull;
  final now = DateTime.now();
  final title = '转卖给${result.platform ?? '他人'}';
  if (soldEvent != null) {
    await repo.updateEvent(soldEvent.copyWith(
      eventDate: result.saleDate,
      title: title,
      amount: result.salePrice,
    ));
  } else {
    await repo.addEvent(ItemEvent(
      id: '',
      itemId: item.id,
      eventType: ItemEventType.sold,
      eventDate: result.saleDate,
      title: title,
      amount: result.salePrice,
      createdAt: now,
      updatedAt: now,
    ));
  }

  if (context.mounted) {
    showAutoToast(
      context,
      '转卖净收入 ${Money.format(result.netIncome, currency: item.currency)}',
    );
  }
  return true;
}
