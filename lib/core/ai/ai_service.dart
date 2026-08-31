import 'dart:convert';

import '../../domain/models/category.dart';
import '../../core/utils/formatters.dart' show Fmt;
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/budget.dart';
import '../../domain/services/duplicate_finder.dart';
import '../../domain/services/item_calculator.dart';
import '../../domain/services/item_insights.dart';
import '../../domain/services/item_retrieval.dart';
import '../../domain/services/statistics_service.dart';
import 'ai_client.dart';
import 'ai_prompts.dart';

/// AI 解析出的物品草稿，供表单预填后由用户确认保存。
class AiItemDraft {
  AiItemDraft({
    this.name,
    this.categoryName,
    this.price,
    this.purchaseDate,
    this.channel,
    this.brand,
    this.model,
    this.quantity,
    this.locationText,
    this.merchantName,
    this.orderNumber,
    this.notes,
    this.tags = const [],
    this.warrantyMonths,
  });

  final String? name;
  final String? categoryName;
  final double? price;
  final DateTime? purchaseDate;
  final String? channel;
  final String? brand;
  final String? model;
  final int? quantity;
  final String? locationText;
  final String? merchantName;
  final String? orderNumber;
  final String? notes;
  final List<String> tags;
  final int? warrantyMonths;

  /// 把位置描述拆成层级路径，如“家/卧室/衣柜”→[家,卧室,衣柜]。
  static List<String> splitLocationPath(String text) => text
      .trim()
      .split(RegExp(r'[/、>＞]'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

/// AI 服务：一句话添加、总结、问答。纯逻辑层，不依赖 UI。
class AiService {
  AiService(this.client);

  final AiClient client;

  /// 一句话解析物品草稿。传入 [imageBase64] 时启用视觉识别（拍照添加）。
  /// 一句话解析物品草稿（单条便捷入口）。
  Future<AiItemDraft> parseItem(
    String input,
    List<Category> categories, {
    String? imageBase64,
  }) async {
    final list = await parseItems(input, categories,
        imageBase64: imageBase64);
    if (list.isEmpty) {
      throw AiException('AI 未识别出任何物品');
    }
    return list.first;
  }

  /// 批量解析：一句话多件物品拆成多条草稿（风衣8999、短袖399…）。
  Future<List<AiItemDraft>> parseItems(
    String input,
    List<Category> categories, {
    String? imageBase64,
  }) async {
    final names = categories.map((c) => c.name).toList();
    var system = AiPrompts.itemParseSystem(names);
    var userText = AiPrompts.itemParseUserText(input);
    if (imageBase64 != null) {
      system =
          '$system\n用户附带了一张物品照片，请结合照片识别名称、品牌、型号与分类，'
          '文字描述与照片冲突时以文字为准。';
      userText = '$userText（见附图）';
    }
    final raw = imageBase64 == null
        ? await client.ask(system, userText, jsonMode: true)
        : await client.askWithImage(
            system,
            userText,
            imageBase64,
            jsonMode: true,
          );

    // 兼容 {"items":[...]}、[...] 与旧版单对象三种形态。
    final List<dynamic> arr;
    final decoded = _tryDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final inner = decoded['items'] ?? decoded['data'];
      if (inner is List) {
        arr = inner;
      } else {
        arr = [decoded];
      }
    } else if (decoded is List) {
      arr = decoded;
    } else {
      throw AiException('AI 返回内容无法解析为 JSON');
    }

    return arr
        .map((e) => e is Map<String, dynamic> ? _draftFromJson(e) : null)
        .whereType<AiItemDraft>()
        .toList();
  }

  /// 单个草稿 JSON → AiItemDraft。
  static AiItemDraft? _draftFromJson(Map<String, dynamic> json) {
    final name = _str(json['name']);
    if (name == null) return null;
    DateTime? date;
    final dateStr = json['purchaseDate'];
    if (dateStr is String && dateStr.length >= 10) {
      date = DateTime.tryParse(dateStr.substring(0, 10));
    }
    return AiItemDraft(
      name: name,
      categoryName: _str(json['category']),
      price: _num(json['price']),
      purchaseDate: date,
      channel: _str(json['channel']),
      brand: _str(json['brand']),
      model: _str(json['model']),
      quantity: _int(json['quantity']),
      locationText: _str(json['locationText']),
      merchantName: _str(json['merchantName']),
      orderNumber: _str(json['orderNumber']),
      notes: _str(json['notes']),
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      warrantyMonths: _int(json['warrantyMonths']),
    );
  }

  /// 宽松 JSON 解码（剥 markdown 围栏）。
  static dynamic _tryDecode(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '')
          .replaceAll(RegExp(r'\n?```$'), '')
          .trim();
    }
    try {
      return jsonDecode(text);
    } catch (_) {
      final start = text.indexOf('{');
      final startArr = text.indexOf('[');
      final from = (start >= 0 && (startArr < 0 || start < startArr))
          ? start
          : startArr;
      final endObj = text.lastIndexOf('}');
      final endArr = text.lastIndexOf(']');
      final to = endObj > endArr ? endObj : endArr;
      if (from >= 0 && to > from) {
        try {
          return jsonDecode(text.substring(from, to + 1));
        } catch (_) {}
      }
      return null;
    }
  }

  /// AI 二手残值估价（详情页入口）。
  Future<String> estimateResale(Item item, SaleRecord? sale) async {
    final days = ItemCalculator.usedDays(item, sale);
    final dims = <String?>[
      '物品价值 ${item.scoreValue ?? '-'}',
      '使用时间 ${item.scoreUsage ?? '-'}',
      '喜爱程度 ${item.scoreFavorite ?? '-'}',
      '有效利用率 ${item.scoreUtilization ?? '-'}',
      '性价比 ${item.scoreCost ?? '-'}',
      '保值度 ${item.scoreRetention ?? '-'}',
    ].join('；');
    final context = [
      '名称：${item.name}',
      '分类：${item.categoryName}',
      if ((item.brand ?? '').isNotEmpty || (item.model ?? '').isNotEmpty)
        '品牌型号：${item.brand ?? ''} ${item.model ?? ''}',
      '购买价：${(item.purchasePrice / 100).toStringAsFixed(0)} 元',
      '购买日期：${_fmtDate(item.purchaseDate)}（已持有 $days 天）',
      '当前状态：${item.status.label}',
      if (item.overallScore != null) '综合评分：${item.overallScore}/100',
      if (item.scoreValue != null || item.scoreRetention != null)
        '六维评分（0-10）：$dims',
      if ((item.notes ?? '').isNotEmpty) '备注：${Fmt.ellipsis(item.notes!, 60)}',
    ].join('\n');
    return client.ask(AiPrompts.resaleEstimateSystem, context);
  }

  /// AI 周报：基于近 7 天数据变化。
  Future<String> weeklyReport(
    List<Item> items,
    Map<String, SaleRecord> sales, {
    DateTime? now,
  }) async {
    final now_ = now ?? DateTime.now();
    final weekAgo = now_.subtract(const Duration(days: 7));
    final active = items.where((i) => !i.isDeleted).toList();
    final newItems = active
        .where((i) => !i.purchaseDate.isBefore(weekAgo))
        .toList();
    final soldThisWeek = active
        .where(
          (i) =>
              i.status == ItemStatus.sold &&
              sales[i.id] != null &&
              !sales[i.id]!.saleDate.isBefore(weekAgo),
        )
        .toList();
    final newSpend = newItems.fold<int>(0, (s, i) => s + i.purchasePrice);
    final saleIncome = soldThisWeek.fold<int>(
      0,
      (s, i) => s + (sales[i.id]?.netIncome ?? 0),
    );
    final newIdle = newItems.where((i) => i.status == ItemStatus.idle).length;
    final lines = [
      '统计周期：${_fmtDate(weekAgo)} 至 ${_fmtDate(now_)}',
      '本周新增 ${newItems.length} 件，共花 ${(newSpend / 100).toStringAsFixed(0)} 元'
          '${newItems.isEmpty ? '' : '：${newItems.take(8).map((i) => '${i.name}(${(i.purchasePrice / 100).toStringAsFixed(0)}元)').join('、')}${newItems.length > 8 ? '等' : ''}'}。',
      '本周转卖 ${soldThisWeek.length} 件，净回收 ${(saleIncome / 100).toStringAsFixed(0)} 元'
          '${soldThisWeek.isEmpty ? '' : '：${soldThisWeek.take(5).map((i) => i.name).join('、')}'}。',
      if (newIdle > 0) '新增物品中已有 $newIdle 件标记为闲置。',
      '（如果以上均为 0，说明本周没有物品变动，输出鼓励用户记录或盘点即可。）',
    ];
    return client.ask(AiPrompts.weeklyReportSystem, lines.join('\n'));
  }

  /// 总结物品与开支。
  Future<String> summarize(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId,
  ) async {
    final overview = StatisticsService.overview(items, salesByItemId);
    final cats = StatisticsService.byCategory(items, salesByItemId)
      ..sort((a, b) => b.purchaseTotal.compareTo(a.purchaseTotal));
    final catText = cats
        .take(8)
        .map(
          (c) =>
              '${c.categoryName} ${c.count}件共${(c.purchaseTotal / 100).toStringAsFixed(0)}元',
        )
        .join('；');
    final idle = items
        .where((i) => !i.isDeleted && i.status == ItemStatus.idle)
        .length;
    final data =
        '当前拥有 ${overview.ownedCount} 件物品，购买总额 ${(overview.ownedPurchaseTotal / 100).toStringAsFixed(0)} 元；'
        '历史共记录 ${overview.totalCount} 件，历史购买总额 ${(overview.historyPurchaseTotal / 100).toStringAsFixed(0)} 元；'
        '转卖回收净收入 ${(overview.saleNetIncomeTotal / 100).toStringAsFixed(0)} 元；'
        '闲置物品 $idle 件。分类分布：$catText。';
    return client.ask(AiPrompts.summarizeSystem, data);
  }

  /// 按维度生成洞察（维度见 AiPrompts.kInsightDimensions）。
  /// 按维度的数据需求注入物品明细/重复分组/转卖明细/闲置/月度数据。
  /// [budget] 非空时所有维度都能感知月度预算进度。
  Future<String> insightByDimension(
    String dimensionId,
    List<Item> items,
    Map<String, SaleRecord> sales,
    ItemInsights insights, {
    BudgetStatus? budget,
  }) async {
    final dim = kInsightDimensions.firstWhere(
      (d) => d.id == dimensionId,
      orElse: () => throw AiException('未知洞察维度'),
    );
    final system =
        '${AiPrompts.systemBase}\n'
        '你是用户的私人消费顾问。任务：${dim.systemPrompt}\n'
        '你可以调用工具主动查询用户的本地物品数据（RAG）：需要什么信息就查什么，'
        '通常先 get_stats 看全局，再按需用 query_items 等工具深入。\n'
        '只依据工具返回的数据，不要编造；金额单位元；'
        '用 Markdown 分点输出，关键词加粗，总长不超过 220 字。';

    try {
      return await client.chatWithTools(
        [AiMessage('system', system), AiMessage('user', '请完成任务。')],
        _insightTools(),
        (name, args) =>
            _executeTool(name, args, items, sales, insights, budget: budget),
      );
    } on AiExceptionWithStatus catch (e) {
      // 服务商不支持 tools（通常返回 400）：降级为一次性注入上下文。
      if (e.statusCode != 400) rethrow;
      final context = buildInsightContext(
        items,
        sales,
        insights,
        budget: budget,
      );
      final extra = <String>[];
      if (dim.needsDuplication) {
        extra.add('[疑似重复分组]\n${buildDuplicationHints(items)}');
      }
      if (dim.needsRoster) {
        extra.add('[物品清单]\n${buildItemRoster(items, sales, ownedOnly: true)}');
      }
      if (dim.needsSold) {
        extra.add('[已转卖明细]\n${buildSoldRoster(items, sales)}');
      }
      if (dim.needsIdle) {
        extra.add('[闲置清单]\n${buildIdleRoster(items, sales)}');
      }
      if (dim.needsMonthly) {
        extra.add('[近6月月度数据]\n${buildMonthlySummary(items)}');
      }
      final fullContext = extra.isEmpty
          ? context
          : '$context\n\n${extra.join('\n\n')}';
      return client.ask(
        system.replaceAll(
          '你可以调用工具主动查询用户的本地物品数据（RAG）：'
              '需要什么信息就查什么，通常先 get_stats 看全局，再按需用 query_items 等工具深入。\n',
          '',
        ),
        '用户物品数据如下，请据此完成任务：\n$fullContext',
      );
    }
  }

  /// 洞察维度的本地查询工具定义（OpenAI function calling 格式）。
  static List<Map<String, dynamic>> _insightTools() => [
    {
      'type': 'function',
      'function': {
        'name': 'get_stats',
        'description': '获取物品总览统计：数量、金额、分类分布、高日均物品、闲置、保修、体检',
        'parameters': {'type': 'object', 'properties': {}},
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'query_items',
        'description': '按条件查询物品明细（名称/分类/状态/价格区间/关键词），返回价格、品牌、已用天数、日均',
        'parameters': {
          'type': 'object',
          'properties': {
            'keyword': {'type': 'string', 'description': '名称/品牌/型号关键词'},
            'category': {'type': 'string', 'description': '分类名，如 手机数码'},
            'status': {'type': 'string', 'description': '状态，如 使用中/闲置/已转卖'},
            'minPrice': {'type': 'number', 'description': '最低价格（元）'},
            'maxPrice': {'type': 'number', 'description': '最高价格（元）'},
            'limit': {'type': 'integer', 'description': '返回条数，默认 30'},
          },
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'find_duplicates',
        'description': '找出疑似重复的物品分组（同分类多件、同品牌多件），用于判断功能重复',
        'parameters': {'type': 'object', 'properties': {}},
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_sold_records',
        'description': '获取已转卖物品明细：购价、卖价、净收入，用于保值分析',
        'parameters': {'type': 'object', 'properties': {}},
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'get_monthly_trend',
        'description': '获取近 6 个月每月新增件数与购买金额',
        'parameters': {'type': 'object', 'properties': {}},
      },
    },
  ];

  /// 本地执行 AI 的工具调用。
  Future<String> _executeTool(
    String name,
    Map<String, dynamic> args,
    List<Item> items,
    Map<String, SaleRecord> sales,
    ItemInsights insights, {
    BudgetStatus? budget,
  }) {
    switch (name) {
      case 'get_stats':
        return Future.value(
          buildInsightContext(items, sales, insights, budget: budget),
        );
      case 'find_duplicates':
        return Future.value(buildDuplicationHints(items));
      case 'get_sold_records':
        return Future.value(buildSoldRoster(items, sales));
      case 'get_monthly_trend':
        return Future.value(buildMonthlySummary(items));
      case 'query_items':
        {
          final keyword = args['keyword'] as String?;
          final category = args['category'] as String?;
          final status = args['status'] as String?;
          final minPrice = (args['minPrice'] as num?)?.toDouble();
          final maxPrice = (args['maxPrice'] as num?)?.toDouble();
          final limit = (args['limit'] as num?)?.toInt() ?? 30;
          var matched = items.where((i) => !i.isDeleted).toList();
          if (keyword != null && keyword.isNotEmpty) {
            final k = keyword.toLowerCase();
            matched = matched
                .where(
                  (i) =>
                      i.name.toLowerCase().contains(k) ||
                      (i.brand ?? '').toLowerCase().contains(k) ||
                      (i.model ?? '').toLowerCase().contains(k),
                )
                .toList();
          }
          if (category != null && category.isNotEmpty) {
            matched = matched
                .where((i) => i.categoryName.contains(category))
                .toList();
          }
          if (status != null && status.isNotEmpty) {
            matched = matched
                .where((i) => i.status.label.contains(status))
                .toList();
          }
          if (minPrice != null) {
            matched = matched
                .where((i) => i.purchasePrice >= minPrice * 100)
                .toList();
          }
          if (maxPrice != null) {
            matched = matched
                .where((i) => i.purchasePrice <= maxPrice * 100)
                .toList();
          }
          final header = '命中 ${matched.length} 件';
          final body = buildItemRoster(
            matched,
            sales,
            ownedOnly: false,
            limit: limit,
          );
          return Future.value('$header\n$body');
        }
      default:
        return Future.value('未知工具：$name');
    }
  }

  /// 消费洞察与建议：基于统计 + 体检结果生成归纳。
  Future<String> spendingAdvice(
    List<Item> items,
    Map<String, SaleRecord> sales,
    ItemInsights insights,
  ) async {
    if (items.where((i) => !i.isDeleted).isEmpty) {
      throw AiException('当前没有任何物品数据，先去添加几件物品吧');
    }
    final context = buildInsightContext(items, sales, insights);

    final system =
        '${AiPrompts.systemBase}\n'
        '你是用户的私人消费顾问。根据用户提供的物品数据，输出中文洞察，格式为四个小节（用「1. 2. 3. 4.」编号）：\n'
        '1. 消费结构归纳（钱主要花在哪）\n'
        '2. 花费集中点与优化空间（结合日均成本高的物品）\n'
        '3. 闲置物品处置建议（转卖/利用，可点名物品）\n'
        '4. 记录完善建议（结合体检结果）\n'
        '每节 1-2 句话，直说结论，总价不超过 250 字，不要编造数据外的信息。';
    return client.ask(system, context);
  }

  /// 多轮物品问答（本地 RAG）：
  /// 只发送「相关物品明细 + 统计摘要 + 对话回述」，大幅节省上下文。
  /// 传入 [actionHandler] 后启用写操作工具（update_item/delete_item），
  /// handler 在 UI 侧弹确认框并执行本地写入，返回给 AI 的结果文本。
  Future<String> chatQuery(
    String question,
    List<Item> items, {
    List<AiMessage> history = const [],
    List<String> subjectHints = const [],
    Map<String, SaleRecord> sales = const {},
    Future<String> Function(String toolName, Map<String, dynamic> args)?
    actionHandler,
  }) async {
    final active = items.where((i) => !i.isDeleted).toList();
    if (active.isEmpty) {
      throw AiException('当前没有任何物品数据，先去添加几件物品吧');
    }
    final retrieved = ItemRetrieval.retrieve(
      question,
      items,
      sales,
      subjectHints: subjectHints,
    );
    final detail = retrieved.matched.isEmpty
        ? '（本次检索没有命中具体物品，请看统计摘要）'
        : retrieved.matched
              .map(
                (i) =>
                    '- ${i.name}｜id:${i.id}｜分类:${i.categoryName}｜'
                    '价格:${(i.purchasePrice / 100).toStringAsFixed(1)}元｜'
                    '购买日:${_fmtDate(i.purchaseDate)}｜状态:${i.status.label}｜'
                    '位置:${i.locationName ?? '未设置'}｜'
                    '品牌:${i.brand ?? '-'}｜型号:${i.model ?? '-'}｜'
                    '频次:${i.usageFrequency?.label ?? '-'}｜'
                    '${i.effectiveWarrantyEndDate == null ? '无保修' : '保修至 ${_fmtDate(i.effectiveWarrantyEndDate!)}'}'
                    '${i.notes != null && i.notes!.isNotEmpty ? '｜备注:${Fmt.ellipsis(i.notes!, 40)}' : ''}',
              )
              .join('\n');
    final userMsg = buildChatUserMessage(
      history: history,
      question: question,
      subjectHints: retrieved.hints,
      detail: detail,
      digest: retrieved.digest,
    );

    if (actionHandler != null) {
      try {
        final insights = ItemInsightService.analyze(active, sales);
        final tools = [..._insightTools(), ..._actionToolDefs()];
        return await client.chatWithTools(
          [
            AiMessage('system', AiPrompts.querySystemWithActions),
            AiMessage('user', userMsg),
          ],
          tools,
          (name, args) => _actionToolNames.contains(name)
              ? actionHandler(name, args)
              : _executeTool(name, args, items, sales, insights),
        );
      } on AiExceptionWithStatus catch (e) {
        // 服务商不支持 tools：降级为纯问答（当前行为）。
        if (e.statusCode != 400) rethrow;
      }
    }
    return client.ask(AiPrompts.querySystem, userMsg);
  }

  /// 写操作工具定义（OpenAI function calling 格式）。
  static List<Map<String, dynamic>> _actionToolDefs() => [
    {
      'type': 'function',
      'function': {
        'name': 'update_item',
        'description': '修改物品的状态/位置/备注。执行前用户会收到确认弹窗。',
        'parameters': {
          'type': 'object',
          'properties': {
            'itemId': {'type': 'string', 'description': '物品 id（数据中 id: 后的字符串）'},
            'status': {
              'type': 'string',
              'description': '新状态：使用中/闲置/收纳中/已借出/维修中/已丢失/已丢弃/已赠送',
            },
            'locationName': {
              'type': 'string',
              'description': '新位置名称（必须是已有位置的名称）',
            },
            'notes': {'type': 'string', 'description': '新备注内容（整体替换）'},
          },
          'required': ['itemId'],
        },
      },
    },
    {
      'type': 'function',
      'function': {
        'name': 'delete_item',
        'description': '把物品移入回收站（软删除，30 天后自动清除）。执行前用户会收到确认弹窗。',
        'parameters': {
          'type': 'object',
          'properties': {
            'itemId': {'type': 'string', 'description': '物品 id'},
          },
          'required': ['itemId'],
        },
      },
    },
  ];

  static const _actionToolNames = {'update_item', 'delete_item'};

  /// 组装单条用户消息（纯函数，便于测试）。
  static String buildChatUserMessage({
    required List<AiMessage> history,
    required String question,
    required List<String> subjectHints,
    required String detail,
    required String digest,
  }) {
    final buf = StringBuffer();
    if (subjectHints.isNotEmpty) {
      buf.writeln('[当前话题物品] ${subjectHints.join('、')}');
      buf.writeln('（用户问题中的指代词优先指向这些物品）');
      buf.writeln();
    }
    buf.writeln('[相关物品明细]（本地检索按相关度选出）');
    buf.writeln(detail);
    buf.writeln();
    buf.writeln('[统计摘要]');
    buf.writeln(digest);
    buf.writeln();
    if (history.isNotEmpty) {
      buf.writeln('[对话记录]');
      final tail = history.length > 8
          ? history.sublist(history.length - 8)
          : history;
      for (final m in tail) {
        final text = m.content.length > 400
            ? '${m.content.substring(0, 400)}…'
            : m.content;
        buf.writeln('${m.role == 'user' ? '用户' : '助手'}：$text');
      }
      buf.writeln();
    }
    buf.writeln('当前问题：$question');
    return buf.toString();
  }

  /// 物品清单：当前持有，按价格降序，最多 80 件。
  /// 含品牌/型号/已用天数/日均，供 AI 做物品级判断。
  static String buildItemRoster(
    List<Item> items,
    Map<String, SaleRecord> sales, {
    bool ownedOnly = true,
    int limit = 80,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final active = items.where((i) => !i.isDeleted).toList();
    final list =
        (ownedOnly ? active.where((i) => i.status.isOwned) : active).toList()
          ..sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
    if (list.isEmpty) return '（无）';
    final buf = StringBuffer();
    if (list.length > limit) buf.writeln('共 ${list.length} 件，仅列前 $limit 件。');
    for (final i in list.take(limit)) {
      final days = ItemCalculator.usedDays(i, sales[i.id], now: now_);
      final daily = ItemCalculator.dailyCost(i, sales[i.id], now: now_);
      buf.writeln(
        '- ${i.name}｜${i.categoryName}｜${(i.purchasePrice / 100).toStringAsFixed(0)}元｜'
        'id:${i.id}｜'
        '${i.brand ?? ''}${i.brand != null && i.model != null ? ' ' : ''}${i.model ?? ''}｜'
        '已用$days天｜日均${(daily / 100).toStringAsFixed(1)}元｜'
        '频次:${i.usageFrequency?.label ?? '-'}｜${i.status.label}',
      );
    }
    return buf.toString().trimRight();
  }

  /// 疑似重复分组：同分类 ≥2 件、或同分类同品牌 ≥2 件。
  static String buildDuplicationHints(List<Item> items) {
    final active = items
        .where((i) => !i.isDeleted && i.status.isOwned)
        .toList();
    final byCat = <String, List<Item>>{};
    for (final i in active) {
      byCat.putIfAbsent(i.categoryName, () => []).add(i);
    }
    final lines = <String>[];
    for (final e in byCat.entries) {
      if (e.value.length < 2) continue;
      final desc = e.value
          .map(
            (i) =>
                '${i.name}(${(i.purchasePrice / 100).toStringAsFixed(0)}元${i.brand != null ? '/${i.brand}' : ''})',
          )
          .join('、');
      lines.add('- ${e.key}×${e.value.length}：$desc');
      if (lines.length >= 10) break;
    }
    return lines.isEmpty ? '（无明显重复分类）' : lines.join('\n');
  }

  /// 已转卖明细：购价/卖价/净收入。
  static String buildSoldRoster(
    List<Item> items,
    Map<String, SaleRecord> sales,
  ) {
    final sold = items
        .where(
          (i) =>
              !i.isDeleted &&
              i.status == ItemStatus.sold &&
              sales[i.id] != null,
        )
        .toList();
    if (sold.isEmpty) return '（无转卖记录）';
    final buf = StringBuffer();
    for (final i in sold.take(20)) {
      final sale = sales[i.id]!;
      buf.writeln(
        '- ${i.name}｜购${(i.purchasePrice / 100).toStringAsFixed(0)}元｜'
        '卖${(sale.salePrice / 100).toStringAsFixed(0)}元｜'
        '净收入${(sale.netIncome / 100).toStringAsFixed(0)}元',
      );
    }
    return buf.toString().trimRight();
  }

  /// 闲置清单：价格与已用天数。
  static String buildIdleRoster(
    List<Item> items,
    Map<String, SaleRecord> sales,
  ) {
    final idle = items
        .where((i) => !i.isDeleted && i.status == ItemStatus.idle)
        .toList();
    if (idle.isEmpty) return '（无闲置物品）';
    final now = DateTime.now();
    final buf = StringBuffer();
    for (final i in idle.take(15)) {
      buf.writeln(
        '- ${i.name}｜${i.categoryName}｜${(i.purchasePrice / 100).toStringAsFixed(0)}元｜'
        '已用${ItemCalculator.usedDays(i, sales[i.id], now: now)}天',
      );
    }
    return buf.toString().trimRight();
  }

  /// 近 6 个月月度数据：月份/件数/金额。
  static String buildMonthlySummary(List<Item> items) {
    final trend = StatisticsService.monthlyTrend(
      items.where((i) => !i.isDeleted).toList(),
      const {},
      months: 6,
    );
    if (trend.isEmpty) return '（无数据）';
    return trend
        .map(
          (m) =>
              '${m.monthKey}：${m.newCount}件/${(m.purchaseTotal / 100).toStringAsFixed(0)}元',
        )
        .join('；');
  }

  /// 每日综合诊断：基于九个维度的洞察结论做二次提炼。
  /// 输入：维度标题 → 洞察文本。
  Future<String> dailyDigest(Map<String, String> dimensionTexts) async {
    if (dimensionTexts.isEmpty) {
      throw AiException('暂无维度洞察，先生成至少一个维度的洞察');
    }
    final buf = StringBuffer();
    for (final e in dimensionTexts.entries) {
      var text = e.value;
      if (text.length > 400) text = '${text.substring(0, 400)}…';
      buf.writeln('【${e.key}】');
      buf.writeln(text);
    }
    return client.ask(kDailyDigestSystem, buf.toString());
  }

  /// AI 购买评估：结合已有相似物品、预算、品类消费判断值不值得买。
  Future<String> purchaseEvaluation({
    required String name,
    required int priceCents,
    required int expectMonths,
    required UsageFrequency frequency,
    String? categoryName,
    String? notes,
    required List<Item> items,
    Map<String, SaleRecord> sales = const {},
    int budgetCents = 0,
  }) async {
    final now = DateTime.now();
    final active = items.where((i) => !i.isDeleted).toList();

    // 本地预估：预计单次使用成本。
    final expectUses = frequency.perMonth * expectMonths;
    final cpuYuan = expectUses < 1
        ? priceCents / 100
        : priceCents / expectUses / 100;
    final necessity = categoryName == null
        ? null
        : ItemCalculator.necessityOf(categoryName);

    // 相似物品：点名使用情况，供 AI 判断重复。
    final dups = DuplicateFinder.findSimilar(name, active);
    final dupText = dups.isEmpty
        ? '（没有相似物品）'
        : dups
              .map(
                (m) =>
                    '- ${m.item.name}（${m.item.categoryName}，'
                    '${(m.item.purchasePrice / 100).toStringAsFixed(0)}元，'
                    '${m.item.status.label}，'
                    '持有${ItemCalculator.usedDays(m.item, sales[m.item.id], now: now)}天，'
                    '频次${m.item.usageFrequency?.label ?? '未填'}）',
              )
              .join('\n');

    // 品类花费与预算状态。
    String categorySpend = '';
    if (categoryName != null) {
      final matched = active
          .where(
            (i) =>
                i.categoryName.contains(categoryName) ||
                categoryName.contains(i.categoryName),
          )
          .toList();
      final spent = matched.fold<int>(0, (s, i) => s + i.purchasePrice);
      categorySpend =
          '「$categoryName」已有 ${matched.length} 件、共花 '
          '${(spent / 100).toStringAsFixed(0)} 元。';
    }
    String budgetLine = '';
    if (budgetCents > 0) {
      final monthStart = DateTime(now.year, now.month);
      final monthSpend = active
          .where((i) => !i.purchaseDate.isBefore(monthStart))
          .fold<int>(0, (s, i) => s + i.purchasePrice);
      final pct = (monthSpend / budgetCents * 100).toStringAsFixed(0);
      final afterPct = ((monthSpend + priceCents) / budgetCents * 100)
          .toStringAsFixed(0);
      budgetLine =
          '月度预算 ${(budgetCents / 100).toStringAsFixed(0)} 元，'
          '本月已花 ${(monthSpend / 100).toStringAsFixed(0)} 元（$pct%），'
          '购买后约 $afterPct%。';
    }

    final context = [
      '想买：$name',
      '预期价格：${(priceCents / 100).toStringAsFixed(0)} 元',
      '预计使用时长：$expectMonths 个月',
      '预计频次：${frequency.label}（每月约 ${frequency.perMonth} 次）',
      if (necessity != null) '品类属性：$categoryName（${necessity.label}）',
      if (notes != null && notes.trim().isNotEmpty) '补充说明：$notes',
      '按上述频次与时长估算：共约 ${expectUses.toStringAsFixed(0)} 次，'
          '单次使用成本约 ${cpuYuan.toStringAsFixed(1)} 元。',
      '\n用户已有的相似物品：\n$dupText',
      if (categorySpend.isNotEmpty) categorySpend,
      if (budgetLine.isNotEmpty) budgetLine,
    ].join('\n');
    return client.ask(AiPrompts.purchaseEvalSystem, context);
  }

  /// AI 批量打标：返回 itemId → 标签列表。
  /// 只处理传入的 [items]（调用方负责筛选未打标/名称已变更的）。
  Future<Map<String, List<String>>> generateItemTags(List<Item> items) async {
    if (items.isEmpty) return const {};
    final lines = items
        .map((i) => '${i.id}｜${i.name}｜${i.brand ?? '-'}｜${i.categoryName}')
        .join('\n');
    final raw = await client.ask(
      AiPrompts.kTaggingSystem,
      lines,
      jsonMode: true,
    );
    return parseTagsResponse(raw);
  }

  /// 解析打标响应（纯函数，便于测试）。
  /// 兼容 {"tags":[...]}、{"items":[...]}、[...] 三种形态。
  static Map<String, List<String>> parseTagsResponse(String raw) {
    final json = _extractJsonList(raw);
    if (json == null) {
      throw AiException('打标返回无法解析');
    }
    final result = <String, List<String>>{};
    for (final e in json) {
      if (e is! Map<String, dynamic>) continue;
      final id = e['id']?.toString();
      if (id == null || id.isEmpty) continue;
      final tags = (e['tags'] as List<dynamic>? ?? const [])
          .map((t) => t.toString().trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (tags.isNotEmpty) result[id] = tags;
    }
    return result;
  }

  static List<dynamic>? _extractJsonList(String raw) {
    var text = raw.trim();
    if (text.startsWith('```')) {
      text = text
          .replaceAll(RegExp(r'^```[a-zA-Z]*\n?'), '')
          .replaceAll(RegExp(r'\n?```$'), '')
          .trim();
    }
    try {
      final v = jsonDecode(text);
      if (v is List) return v;
      if (v is Map<String, dynamic>) {
        return (v['tags'] ?? v['items'] ?? v['data']) as List<dynamic>?;
      }
    } catch (_) {
      final start = text.indexOf('[');
      final end = text.lastIndexOf(']');
      if (start >= 0 && end > start) {
        try {
          return jsonDecode(text.substring(start, end + 1)) as List<dynamic>;
        } catch (_) {}
      }
    }
    return null;
  }

  /// AI 年度账单：该年新增/花费/转卖等本地数据 + AI 总结。
  Future<String> yearlyReport(
    List<Item> items,
    Map<String, SaleRecord> sales, {
    required int year,
  }) async {
    final active = items.where((i) => !i.isDeleted).toList();
    final inYear = active.where((i) => i.purchaseDate.year == year).toList();
    final spend = inYear.fold<int>(0, (s, i) => s + i.purchasePrice);
    final monthly = List.filled(12, 0);
    for (final i in inYear) {
      monthly[i.purchaseDate.month - 1] += i.purchasePrice;
    }
    final topItems = [...inYear]
      ..sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
    final soldInYear = active
        .where(
          (i) =>
              i.status == ItemStatus.sold &&
              sales[i.id] != null &&
              sales[i.id]!.saleDate.year == year,
        )
        .toList();
    final saleIncome = soldInYear.fold<int>(
      0,
      (s, i) => s + (sales[i.id]?.netIncome ?? 0),
    );
    final idle = active
        .where(
          (i) => i.status == ItemStatus.idle && i.purchaseDate.year == year,
        )
        .toList();

    final byCat = <String, int>{};
    for (final i in inYear) {
      byCat[i.categoryName] = (byCat[i.categoryName] ?? 0) + i.purchasePrice;
    }
    final topCats = byCat.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final lines = [
      '$year 年共新增 ${inYear.length} 件物品，共花费 ${(spend / 100).toStringAsFixed(0)} 元。',
      '月度花费：${monthly.asMap().entries.where((e) => e.value > 0).map((e) => '${e.key + 1}月${(e.value / 100).toStringAsFixed(0)}元').join('、')}${spend == 0 ? '（无）' : ''}。',
      if (topItems.isNotEmpty)
        '最贵的前三：${topItems.take(3).map((i) => '${i.name}(${(i.purchasePrice / 100).toStringAsFixed(0)}元)').join('、')}。',
      if (topCats.isNotEmpty)
        '花钱最多的分类：${topCats.take(3).map((e) => '${e.key}(${(e.value / 100).toStringAsFixed(0)}元)').join('、')}。',
      '转卖 ${soldInYear.length} 件，净回收 ${(saleIncome / 100).toStringAsFixed(0)} 元${soldInYear.isEmpty ? '' : '（${soldInYear.take(5).map((i) => i.name).join('、')}）'}。',
      if (idle.isNotEmpty)
        '这一年购买但现已闲置：${idle.length} 件（${idle.take(5).map((i) => i.name).join('、')}）。',
      if (inYear.isEmpty) '（该年没有任何记录，如实告知即可。）',
    ];
    return client.ask(AiPrompts.yearlyReportSystem, lines.join('\n'));
  }

  /// 洞察类请求共用的数据上下文：总览 + 分类 + 高日均 + 闲置 + 体检 + 预算。
  static String buildInsightContext(
    List<Item> items,
    Map<String, SaleRecord> sales,
    ItemInsights insights, {
    BudgetStatus? budget,
  }) {
    final overview = StatisticsService.overview(items, sales);
    final cats = StatisticsService.byCategory(items, sales)
      ..sort((a, b) => b.purchaseTotal.compareTo(a.purchaseTotal));
    final topCats = cats
        .take(4)
        .map(
          (c) =>
              '${c.categoryName}（${c.count}件，共${(c.purchaseTotal / 100).toStringAsFixed(0)}元，日均均值${(c.avgDailyCost).toStringAsFixed(1)}元）',
        )
        .join('；');
    final highDaily = insights.highDailyCost
        .map(
          (i) =>
              '${i.name}（${(i.purchasePrice / 100).toStringAsFixed(0)}元，日均${(ItemCalculator.dailyCost(i, sales[i.id]) / 100).toStringAsFixed(1)}元）',
        )
        .join('；');
    final idleNames = insights.longIdle.take(6).map((i) => i.name).join('、');
    final warrantyNames = insights.expiringWarranty
        .take(6)
        .map(
          (i) =>
              '${i.name}（${i.effectiveWarrantyEndDate!.month}/${i.effectiveWarrantyEndDate!.day}）',
        )
        .join('、');
    return [
      '当前拥有 ${overview.ownedCount} 件，持有购买总额 ${(overview.ownedPurchaseTotal / 100).toStringAsFixed(0)} 元；'
          '历史 ${overview.totalCount} 件、总额 ${(overview.historyPurchaseTotal / 100).toStringAsFixed(0)} 元；'
          '转卖回收净收入 ${(overview.saleNetIncomeTotal / 100).toStringAsFixed(0)} 元。',
      '分类金额从高到低：$topCats。',
      if (highDaily.isNotEmpty) '日均成本最高的持有物品：$highDaily。',
      if (idleNames.isNotEmpty)
        '长期闲置（${insights.longIdle.length} 件）：$idleNames。',
      if (warrantyNames.isNotEmpty)
        '保修将到期/已过期（${insights.expiringWarranty.length} 件）：$warrantyNames。',
      if (insights.maintenanceDue.isNotEmpty)
        '保养/耗材到期（${insights.maintenanceDue.length} 件）：'
            '${insights.maintenanceDue.take(5).map((i) => i.name).join('、')}。',
      '体检：价格缺失 ${insights.missingPrice.length} 件、未设位置 ${insights.missingLocation.length} 件、'
          '无照片 ${insights.missingImage.length} 件。',
      if (budget != null)
        '月度预算：本月已花费 ${(budget.spentCents / 100).toStringAsFixed(0)} 元 / '
            '预算 ${(budget.budgetCents / 100).toStringAsFixed(0)} 元'
            '（${(budget.ratio * 100).toStringAsFixed(0)}%${budget.level == BudgetLevel.exceeded
                ? '，已超支'
                : budget.level == BudgetLevel.warning
                ? '，接近预算'
                : ''}）。',
    ].join('\n');
  }

  /// 构建发往 AI 的物品数据集：覆盖日期、保修、位置等可被追问的字段。
  static String buildDataset(List<Item> items) {
    final active = items.where((i) => !i.isDeleted).toList();
    if (active.isEmpty) return '（暂无物品）';
    final buf = StringBuffer();
    if (active.length > 150) {
      buf.writeln('共 ${active.length} 件，仅列出前 150 件。');
    }
    for (final i in active.take(150)) {
      final warranty = i.effectiveWarrantyEndDate == null
          ? '无保修'
          : '保修至 ${_fmtDate(i.effectiveWarrantyEndDate!)}';
      final notes = (i.notes ?? '').isEmpty
          ? ''
          : '｜备注:${Fmt.ellipsis(i.notes!, 40)}';
      buf.writeln(
        '- ${i.name}｜分类:${i.categoryName}｜价格:${(i.purchasePrice / 100).toStringAsFixed(1)}元｜'
        '购买日:${_fmtDate(i.purchaseDate)}｜状态:${i.status.label}｜'
        '位置:${i.locationName ?? '未设置'}｜已用${ItemCalculator.usedDays(i, null)}天｜'
        '频次:${i.usageFrequency?.label ?? '-'}｜'
        '品牌:${i.brand ?? '-'}｜型号:${i.model ?? '-'}｜$warranty'
        '${i.tags.isEmpty ? '' : '｜标签:${i.tags.join(',')}'}$notes',
      );
    }
    return buf.toString();
  }

  // ---------- 内部工具 ----------


  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static double? _num(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
