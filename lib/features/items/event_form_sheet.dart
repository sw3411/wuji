import 'package:flutter/material.dart';

import '../../core/utils/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item_event.dart';

typedef SellLauncher = Future<void> Function();

/// 添加自定义物品事件。
/// [onSell]：选择「转卖」时的转卖流启动器（强制填金额/日期并联动）。
Future<ItemEvent?> showEventFormSheet(
  BuildContext context,
  String itemId, {
  SellLauncher? onSell,
}) {
  return showModalBottomSheet<ItemEvent>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (context) => _EventFormSheet(itemId: itemId, onSell: onSell),
  );
}

class _EventFormSheet extends StatefulWidget {
  const _EventFormSheet({required this.itemId, this.onSell});

  final String itemId;
  final SellLauncher? onSell;

  @override
  State<_EventFormSheet> createState() => _EventFormSheetState();
}

class _EventFormSheetState extends State<_EventFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  ItemEventType _type = ItemEventType.maintained;
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
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
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = '请填写事件标题');
      return;
    }
    Navigator.pop(
      context,
      ItemEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        itemId: widget.itemId,
        eventType: _type,
        eventDate: _date,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        amount: _amountCtrl.text.trim().isEmpty
            ? null
            : Money.parse(_amountCtrl.text),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Text('添加事件', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: ItemEventType.values
                  .where((t) => t != ItemEventType.purchased)
                  .map(
                    (t) => ChoiceChip(
                      label: Text(t.label),
                      selected: _type == t,
                      onSelected: (_) {
                        if (t == ItemEventType.sold && widget.onSell != null) {
                          // 转卖必须走统一转卖流：强制填金额/日期。
                          Navigator.pop(context);
                          widget.onSell!();
                          return;
                        }
                        setState(() => _type = t);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: '事件标题 *'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: '事件日期'),
                child: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: '关联金额（元，可选）'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: '详细描述'),
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
