import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myfortune/core/constants/fortune_config.dart';
import 'package:myfortune/core/constants/tarot_data.dart';
import 'package:myfortune/data/models/consultation.dart';
import 'package:myfortune/data/models/user_profile.dart';

class FortuneResult {
  final String reading;
  final int score; // 0-100
  final List<String> suggestedActions;

  const FortuneResult({
    required this.reading,
    required this.score,
    required this.suggestedActions,
  });
}

class DailyFortuneResult {
  final String content;
  final int overallScore;
  final int loveScore;
  final int workScore;
  final int moneyScore;
  final String warning;

  const DailyFortuneResult({
    required this.content,
    required this.overallScore,
    required this.loveScore,
    required this.workScore,
    required this.moneyScore,
    required this.warning,
  });
}

class CompatibilityResult {
  final String reading;
  final String partnerName;
  final String partnerZodiac;
  final int overallScore;
  final int loveScore;
  final int friendshipScore;
  final int workScore;
  final List<String> suggestedActions;

  const CompatibilityResult({
    required this.reading,
    required this.partnerName,
    required this.partnerZodiac,
    required this.overallScore,
    required this.loveScore,
    required this.friendshipScore,
    required this.workScore,
    required this.suggestedActions,
  });
}

class ClaudeService {
  static final _dio = Dio();
  static const _fallbackUrl = 'https://api.anthropic.com/v1/messages';
  static const _fallbackModel = 'claude-haiku-4-5-20251001';

  // trim() で .env の CRLF 改行・空白を除去
  String get _apiKey => (dotenv.env['CLAUDE_API_KEY'] ?? '').trim();
  String get _apiUrl =>
      (dotenv.env['CLAUDE_API_URL'] ?? _fallbackUrl).trim().isEmpty
          ? _fallbackUrl
          : (dotenv.env['CLAUDE_API_URL'] ?? _fallbackUrl).trim();
  // .env の CLAUDE_MODEL を優先、なければフォールバック
  String get _model =>
      (dotenv.env['CLAUDE_MODEL'] ?? _fallbackModel).trim().isEmpty
          ? _fallbackModel
          : (dotenv.env['CLAUDE_MODEL'] ?? _fallbackModel).trim();

  // ── 今日の運勢（全プラン無料） ──────────────────
  Future<DailyFortuneResult> generateDailyFortune({
    required UserProfile profile,
  }) async {
    final systemPrompt = _buildDailySystemPrompt();
    final userPrompt =
        '星座：${profile.zodiacSign}\n今日の日付：${_today()}\n5秒で読める今日の運勢を生成してください。';

    final text = await _callAi(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 600,
    );

    return _parseDailyFortune(text);
  }

  // ── タロット鑑定 ────────────────────────────────
  Future<FortuneResult> generateTarotReading({
    required UserProfile profile,
    required String worry,
    required List<TarotCard> cards,
    required List<bool> reversed,
    required List<Consultation> recentConsultations,
    String? fortuneSummary,
  }) async {
    final systemPrompt =
        _buildFortuneSystemPrompt(profile, recentConsultations, fortuneSummary: fortuneSummary);
    final cardDesc = List.generate(
      3,
      (i) =>
          '${["過去", "現在", "未来"][i]}：${cards[i].nameJp}（${reversed[i] ? "逆位置" : "正位置"}）- ${reversed[i] ? cards[i].reversedMeaning : cards[i].meaning}',
    ).join('\n');

    final userPrompt = '''
悩み：$worry

引いたカード：
$cardDesc

上記をもとに鑑定してください。
回答は必ず下記の形式のみで出力し、余計な前置きは一切不要です：

SCORE:XX
ACTION:アクション1（完結した文で）
ACTION:アクション2（完結した文で）
ACTION:アクション3（完結した文で）
READING:
（【前半 250〜350字】今回の占術（カード・数字・星座など）の内容を軸に、${profile.nickname}さんの相談テーマを丁寧に読み解く。占術固有の解釈を具体的に展開すること。
【後半 150〜200字】${profile.nickname}さんの特性・過去の占いパターンを踏まえ、「なぜ今この状況が続いているのか」「どんな傾向があるのか」を温かく一言添える。過去履歴や特性がない場合はこのパートは省略可。）
''';

    final text = await _callAi(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2500,
    );

    return _parseFortuneResult(text);
  }

  // ── 数秘術 ──────────────────────────────────────
  Future<FortuneResult> generateNumerologyReading({
    required UserProfile profile,
    required String worry,
    required List<Consultation> recentConsultations,
    String? fortuneSummary,
  }) async {
    final lifeNumber = _calcLifeNumber(profile.birthdate);
    final systemPrompt =
        _buildFortuneSystemPrompt(profile, recentConsultations, fortuneSummary: fortuneSummary);
    final userPrompt = '''
ライフパスナンバー：$lifeNumber
悩み：$worry

数秘術の観点から鑑定してください。
回答は必ず下記の形式のみで出力し、余計な前置きは一切不要です：

SCORE:XX
ACTION:アクション1（完結した文で）
ACTION:アクション2（完結した文で）
ACTION:アクション3（完結した文で）
READING:
（【前半 250〜350字】今回の占術（カード・数字・星座など）の内容を軸に、${profile.nickname}さんの相談テーマを丁寧に読み解く。占術固有の解釈を具体的に展開すること。
【後半 150〜200字】${profile.nickname}さんの特性・過去の占いパターンを踏まえ、「なぜ今この状況が続いているのか」「どんな傾向があるのか」を温かく一言添える。過去履歴や特性がない場合はこのパートは省略可。）
''';

    final text = await _callAi(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2200,
    );

    return _parseFortuneResult(text);
  }

  // ── 相性占い ─────────────────────────────────────
  Future<CompatibilityResult> generateCompatibilityReading({
    required UserProfile profile,
    required String partnerName,
    required DateTime partnerBirthdate,
    required List<Consultation> recentConsultations,
  }) async {
    final myLifeNumber = _calcLifeNumber(profile.birthdate);
    final partnerLifeNumber = _calcLifeNumber(partnerBirthdate);
    final partnerZodiac = _getZodiacSign(partnerBirthdate);

    final systemPrompt = _buildCompatibilitySystemPrompt(profile, recentConsultations);
    final userPrompt = '''
【あなた】
名前：${profile.nickname}
星座：${profile.zodiacSign}
ライフパスナンバー：$myLifeNumber

【相手】
名前：$partnerName
星座：$partnerZodiac
ライフパスナンバー：$partnerLifeNumber

二人の相性を多角的に分析してください。
回答は必ず下記の形式のみで出力してください：

OVERALL:XX
LOVE:XX
FRIEND:XX
WORK:XX
ACTION:アクション1（完結した文で）
ACTION:アクション2（完結した文で）
ACTION:アクション3（完結した文で）
READING:
（【前半 250〜350字】星座・数秘術・相性スコアの観点から二人の関係を具体的に分析する。強みと課題を正直に。
【後半 150〜200字】${profile.nickname}さんの特性・過去の相談傾向を踏まえ、この関係でのパターンや傾向を温かく一言添える。過去履歴や特性がない場合は省略可。）
''';

    final text = await _callAi(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 1800,
    );

    return _parseCompatibilityResult(text, partnerName, partnerZodiac);
  }

  // ── 月間サマリー（Pro限定） ────────────────────────
  Future<String> generateMonthlySummary({
    required UserProfile profile,
    required List<Consultation> consultations,
    required String monthKey,
  }) async {
    final avgScore = consultations
            .where((c) => c.score != null)
            .map((c) => c.score!)
            .fold(0, (a, b) => a + b) /
        (consultations.where((c) => c.score != null).length.clamp(1, 999));

    final typeCount = <String, int>{};
    for (final c in consultations) {
      typeCount[c.fortuneType.displayName] =
          (typeCount[c.fortuneType.displayName] ?? 0) + 1;
    }

    final worries = consultations.take(5).map((c) => '・${c.worry}').join('\n');

    final userPrompt = '''
【${profile.nickname}さんの$monthKeyの占い記録】
総相談回数：${consultations.length}回
平均スコア：${avgScore.round()}点
占術内訳：${typeCount.entries.map((e) => '${e.key}${e.value}回').join('、')}

主な悩み：
$worries

上記の記録から、今月の傾向・パターン・来月へのアドバイスを300字程度で分析してください。
温かく前向きなトーンで、具体的なアドバイスを含めてください。
''';

    return await _callAi(
      systemPrompt:
          'あなたは占い記録を分析する専門家AIです。ユーザーの月間記録から洞察とアドバイスを提供してください。日本語で温かく応答してください。',
      userPrompt: userPrompt,
      maxTokens: 1000,
    );
  }

  // ── 汎用フル占い（夢・血液型・ルーン・前世・ホロスコープ・四柱推命・縁起） ──
  Future<FortuneResult> generateSimpleReading({
    required UserProfile profile,
    required FortuneType type,
    required String input, // 悩み or 夢の内容 or 血液型など
    required List<Consultation> recentConsultations,
    String? fortuneSummary,
    String? extraContext, // 四柱推命の出生時刻など
  }) async {
    // タロット以外はmajor arcanaを除外してトークン節約・混乱防止
    final systemPrompt = _buildFortuneSystemPrompt(
        profile, recentConsultations,
        fortuneSummary: fortuneSummary,
        includeTarot: false);

    final typeGuide = _getTypeGuide(type, profile, input, extraContext);

    final userPrompt = '''
$typeGuide

回答は必ず下記の形式のみで出力し、余計な前置きは一切不要です：

SCORE:XX
ACTION:アクション1（完結した文で）
ACTION:アクション2（完結した文で）
ACTION:アクション3（完結した文で）
READING:
（【前半 250〜350字】今回の占術（カード・数字・星座など）の内容を軸に、${profile.nickname}さんの相談テーマを丁寧に読み解く。占術固有の解釈を具体的に展開すること。
【後半 150〜200字】${profile.nickname}さんの特性・過去の占いパターンを踏まえ、「なぜ今この状況が続いているのか」「どんな傾向があるのか」を温かく一言添える。過去履歴や特性がない場合はこのパートは省略可。）
''';

    final text = await _callAi(
      systemPrompt: systemPrompt,
      userPrompt: userPrompt,
      maxTokens: 2200,
    );
    return _parseFortuneResult(text);
  }

  // ── おみくじ ───────────────────────────────────
  Future<String> generateOmikuji({
    required UserProfile profile,
  }) async {
    final now = DateTime.now();
    // 時刻・日付をシードに使ってランダム性を確保
    final seed = now.millisecondsSinceEpoch % 1000;
    final userPrompt = '''
${profile.nickname}さんへ今日のおみくじを引いてください。
シード値: $seed（このシードをもとにランダムな結果を選んでください）

【ランク選択の確率分布に従ってください】
大吉: 15% / 吉: 25% / 中吉: 25% / 小吉: 20% / 末吉: 10% / 凶: 5%
大吉が続くことなく、必ずこの分布に従って選択してください。

以下の形式のみで出力してください（日本語のみ使用）：

RANK:（大吉/吉/中吉/小吉/末吉/凶のいずれか）
MESSAGE:
（今日への短いメッセージを3〜5行で。ランクに合わせたトーンで。温かく、具体的な言葉で。全て日本語で。）

重要：全ての回答は必ず日本語で記述してください。英語は一切使用しないでください。
''';
    return await _callAi(
      systemPrompt:
          'あなたは日本の伝統的なおみくじを引く占い師AIです。指定された確率分布に従ってランクを選び、毎回異なる内容のメッセージを生成してください。【重要】全ての応答は必ず日本語のみで、英語を使わないでください。',
      userPrompt: userPrompt,
      maxTokens: 400,
    );
  }

  /// 占術ごとのユーザープロンプト組み立て
  String _getTypeGuide(
    FortuneType type,
    UserProfile profile,
    String input,
    String? extra,
  ) {
    final name = profile.nickname;
    final b = profile.birthdate;
    final zodiac = profile.zodiacSign;
    final lifeNum = _calcLifeNumber(b);

    switch (type) {
      case FortuneType.dream:
        return '''名前：$name

【見た夢の内容（必ずこの内容を鑑定に使うこと）】
$input

上記の夢の内容を夢占いで鑑定してください。
夢に登場した具体的な要素（場所・人物・行動・感情など）を必ず取り上げ、
それぞれが持つ潜在意識のメッセージを読み解いてください。
夢の内容に触れずに一般論だけを述べることは絶対に避けてください。''';

      case FortuneType.bloodType:
        return '名前：$name\n血液型：$input\n星座：$zodiac\n\n血液型と星座の組み合わせで今のあなたを占ってください。';

      case FortuneType.rune:
        // ルーンを3つランダムに選ぶ（AI任せ）
        return '名前：$name\n悩み：$input\n星座：$zodiac\n\n古代北欧のルーン占いで3つのルーン石を引き、鑑定してください。各ルーンの名前と意味も含めてください。';

      case FortuneType.pastLife:
        return '名前：$name\n生年月日：${b.year}年${b.month}月${b.day}日\n\n前世占いで${name}さんの前世の姿・時代・使命、そして今世への影響を鑑定してください。';

      case FortuneType.horoscope:
        return '名前：$name\n星座：$zodiac\nライフパスナンバー：$lifeNum\n悩み：$input\n\nホロスコープで天体の配置を踏まえた詳しい星座鑑定をしてください。';

      case FortuneType.fourPillars:
        final timeStr = (extra != null && extra.isNotEmpty) ? extra : '不明';
        return '''名前：$name
生年月日：${b.year}年${b.month}月${b.day}日（${b.year - 1}年干支で換算）
出生時刻：$timeStr
星座：$zodiac

四柱推命で以下を鑑定してください：
1. 命式（年柱・月柱・日柱・時柱）
2. 五行バランスと本命卦
3. 今年の運気の流れ
4. ${name}さんへの具体的なアドバイス''';

      case FortuneType.auspiciousCalendar:
        final now = DateTime.now();
        return '名前：$name\n星座：$zodiac\n対象月：${now.year}年${now.month}月\n\n今月の六曜・吉日・凶日・行動の吉方位を縁起カレンダーとして提示してください。';

      default:
        return '名前：$name\n悩み：$input\n\n鑑定してください。';
    }
  }

  // ── 内部：プロバイダー設定 ───────────────────────
  String get _deepseekKey => (dotenv.env['DEEPSEEK_API_KEY'] ?? '').trim();
  String get _deepseekModel =>
      (dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-v4-flash').trim().isEmpty
          ? 'deepseek-v4-flash'
          : (dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-v4-flash').trim();

  String get _geminiKey => (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  String get _geminiModel =>
      (dotenv.env['GEMINI_MODEL'] ?? 'gemini-3.1-flash-lite').trim().isEmpty
          ? 'gemini-3.1-flash-lite'
          : (dotenv.env['GEMINI_MODEL'] ?? 'gemini-3.1-flash-lite').trim();

  // ── 内部：AIフォールバックチェーン ──────────────
  // 優先順位: DeepSeek → Gemini → Claude
  // キーが空のプロバイダーはスキップ
  Future<String> _callAi({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 1000,
  }) async {
    if (kIsWeb) {
      throw Exception('Web環境ではAI APIは利用できません。Androidアプリをご使用ください。');
    }

    // 1. DeepSeek
    if (_deepseekKey.isNotEmpty) {
      try {
        debugPrint('[AI] DeepSeek ($_deepseekModel)');
        return await _callOpenAiCompatible(
          baseUrl: 'https://api.deepseek.com',
          apiKey: _deepseekKey,
          model: _deepseekModel,
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          maxTokens: maxTokens,
          providerName: 'DeepSeek',
        );
      } catch (e) {
        debugPrint('[AI] DeepSeek failed → Gemini: $e');
      }
    }

    // 2. Gemini
    if (_geminiKey.isNotEmpty) {
      try {
        debugPrint('[AI] Gemini ($_geminiModel)');
        return await _callOpenAiCompatible(
          baseUrl:
              'https://generativelanguage.googleapis.com/v1beta/openai',
          apiKey: _geminiKey,
          model: _geminiModel,
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          maxTokens: maxTokens,
          providerName: 'Gemini',
        );
      } catch (e) {
        debugPrint('[AI] Gemini failed → Claude Haiku: $e');
      }
    }

    // 3. Claude Haiku フォールバック（最後の手段）
    if (_apiKey.isNotEmpty) {
      try {
        debugPrint('[AI] Claude Haiku ($_model)');
        return await _callClaude(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
          maxTokens: maxTokens,
        );
      } catch (e) {
        debugPrint('[AI] Claude Haiku failed: $e');
      }
    }

    throw Exception('AI APIが利用できません。DeepSeek、Gemini、またはClaudeのAPIキーを設定してください。');
  }

  // ── 内部：AI応答のXMLタグ除去 ────────────────────────────
  String _cleanResponse(String text) {
    return text
        .replaceAll(
            RegExp(
                r'</?(?:final_response|response|answer|output|result|thinking|antThinking)>',
                caseSensitive: false),
            '')
        .trim();
  }

  // ── 内部：OpenAI互換API共通呼び出し（DeepSeek・Gemini） ──
  Future<String> _callOpenAiCompatible({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String systemPrompt,
    required String userPrompt,
    required int maxTokens,
    required String providerName,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
        ),
        data: {
          'model': model,
          'max_tokens': maxTokens,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
        },
      );
      final choices = response.data['choices'] as List;
      return _cleanResponse(choices.first['message']['content'] as String);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data?.toString() ?? '';
      debugPrint('$providerName API error: status=$status body=$body');
      // 429 / 503 は一時的なので再試行ではなく次プロバイダーへ
      throw Exception('$providerName error($status): $body');
    }
  }

  // ── 内部：Claude APIコール（フォールバック用） ───
  Future<String> _callClaude({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 1000,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('APIキーが設定されていません (.env未読込)');
    }

    try {
      final response = await _dio.post(
        _apiUrl,
        options: Options(
          headers: {
            'x-api-key': _apiKey,
            'anthropic-version': '2023-06-01',
            'content-type': 'application/json',
            'anthropic-beta': 'prompt-caching-2024-07-31',
          },
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 90),
        ),
        data: {
          'model': _model,
          'max_tokens': maxTokens,
          'system': [
            {
              'type': 'text',
              'text': systemPrompt,
              'cache_control': {'type': 'ephemeral'},
            }
          ],
          'messages': [
            {'role': 'user', 'content': userPrompt}
          ],
        },
      );

      final content = response.data['content'] as List;
      return _cleanResponse(content.first['text'] as String);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data?.toString() ?? '';
      debugPrint('Claude API DioError: status=$status body=$body');
      if (status == 401) throw Exception('APIキー認証エラー(401): キーを確認してください');
      if (status == 404) throw Exception('APIエンドポイント/モデルが見つかりません(404)\nURL: $_apiUrl\nModel: $_model');
      if (status == 429) throw Exception('レート制限超過(429) しばらく待ってください');
      if (status == 400) throw Exception('リクエストエラー(400): $body');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('接続タイムアウト: ネット接続を確認してください');
      }
      if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('受信タイムアウト: AIの応答が遅延しています');
      }
      if (e.type == DioExceptionType.connectionError) {
        throw Exception('接続エラー: インターネット接続を確認してください');
      }
      throw Exception('通信エラー(${e.type.name}): ${e.message}');
    }
  }

  // ── 相性システムプロンプト ────────────────────────
  String _buildCompatibilitySystemPrompt(
    UserProfile profile,
    List<Consultation> history,
  ) {
    final personaStyle = profile.persona.systemPromptStyle;
    return '''
あなたは相性占いの専門家AIです。
$personaStyle

星座・数秘術・心理学的観点を組み合わせて、二人の相性を深く分析してください。
良い点・課題点・具体的なアドバイスをバランスよく伝えてください。
日本語で温かく、希望を持てる形で分析してください。
''';
  }

  // ── システムプロンプト ────────────────────────────
  String _buildDailySystemPrompt() => '''
あなたは毎日の星座運勢を生成するAIです。
以下の形式で、5秒で読める簡潔な運勢を日本語で生成してください：

総合運：★X☆（X/5）
恋愛運：★X☆（X/5）
仕事運：★X☆（X/5）
金運：★X☆（X/5）

【今日のメッセージ】
2-3行のメッセージ

【注意】
1行の注意事項

【スコア総合】XX点
【スコア恋愛】XX点
【スコア仕事】XX点
【スコア金運】XX点
''';

  String _buildFortuneSystemPrompt(
    UserProfile profile,
    List<Consultation> history, {
    String? fortuneSummary,
    bool includeTarot = true,
  }) {
    final personaStyle = profile.persona.systemPromptStyle;

    // 直近5件の履歴（詳細）
    final historyText = history.isEmpty
        ? 'なし'
        : history
            .take(5)
            .map((c) {
              final base = '- ${c.createdAt.month}/${c.createdAt.day}'
                  '（${c.fortuneType.displayName}）'
                  '「${c.worry}」'
                  ' スコア${c.score ?? "?"}点';
              final decision = c.decision != null ? ' → 実行：${c.decision}' : '';
              return base + decision;
            })
            .join('\n');

    // 繰り返し悩みパターンを検出
    final worryFreq = <String, int>{};
    for (final c in history.take(7)) {
      final key = c.worry.length > 10 ? c.worry.substring(0, 10) : c.worry;
      worryFreq[key] = (worryFreq[key] ?? 0) + 1;
    }
    final repeatedWorries = worryFreq.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();
    final patternNote = repeatedWorries.isEmpty
        ? ''
        : '\n【継続テーマ】${repeatedWorries.join('、')} → 進展や変化に言及してください。';

    // 過去サマリー（あれば）
    final summarySection = fortuneSummary != null && fortuneSummary.isNotEmpty
        ? '\n$fortuneSummary'
        : '';

    // 性格・ライフスタイル特性
    final traitsSection = profile.personalityTraits.isNotEmpty
        ? '\n【ユーザーの特性】${profile.personalityTraits.join('、')}'
        : '';

    return '''
あなたは記憶型AI占いアプリ「マイフォーチューン」の専属占い師です。
$personaStyle

【ユーザー情報】
名前：${profile.nickname}さん
星座：${profile.zodiacSign}
生年月日：${profile.birthdate.year}年${profile.birthdate.month}月${profile.birthdate.day}日$traitsSection

【直近の相談履歴】
$historyText$patternNote$summarySection

${includeTarot ? '''【大アルカナの意味】
${majorArcana.map((c) => '${c.nameJp}：${c.meaning} / 逆：${c.reversedMeaning}').join('\n')}''' : ''}

【出力形式の厳守】
回答は必ずユーザープロンプトで指定された形式（SCORE:, ACTION:, READING:）で出力してください。
前置き・見出し・装飾は一切不要です。SCORE:の数値から始めてください。
スコアは相談内容・カードの組み合わせ・過去傾向を総合的に判断した1〜100の整数（毎回異なる値を出力）。

【鑑定スタイル】
READING は必ず「前半」→「後半」の流れで書いてください。

■ 前半（占術の読み解き）
- 今回の占術の内容（カード・数字・星座・ルーンなど）を正面から丁寧に読み解く
- 抽象的な励ましではなく、占術固有の意味・配置・数値から導かれる具体的な解釈を展開する
- ${profile.nickname}さんの相談テーマと占術の結果を結びつけてください
- 良い点だけでなく、注意点や課題もやわらかく正直に伝えてください

■ 後半（パーソナルコメント）
- 上記の特性・過去履歴・継続テーマを活かして、${profile.nickname}さんだけへの一言を添える
- 「なぜ今この状況が続いているのか」「どんな行動パターンがあるのか」を根本から優しく指摘する
- 過去の相談と繋がる場合は「以前〜とのことでしたが」などと自然に言及してください
- 過去履歴・特性が存在しない場合はこのパートは省略する（無理に作らない）
- ${profile.nickname}さん自身が答えを見つけられるよう、短い問いかけで締めくくる
''';
  }

  // ── パーサー ─────────────────────────────────────

  /// 複数パターンで数値スコアを抽出。見つからなければ null。
  int? _tryParseScore(String text, List<RegExp> patterns) {
    for (final re in patterns) {
      final m = re.firstMatch(text);
      if (m != null) {
        final v = int.tryParse(m.group(1)!);
        if (v != null && v >= 0 && v <= 100) return v;
      }
    }
    return null;
  }

  /// 文章が途中で切れていないか判定（日本語中途半端終わり = false）
  bool _isCompleteAction(String s) {
    final t = s.trim();
    if (t.length < 5) return false;
    // 助詞・接続詞・読点で終わる場合は不完全
    const midEndings = ['が', 'を', 'に', 'で', 'は', 'と', 'の', 'も', 'て', 'し', '、', 'な'];
    for (final e in midEndings) {
      if (t.endsWith(e)) return false;
    }
    return true;
  }

  /// 行頭の箇条書き記号を除去してアクションリストを抽出（不完全文を除外）。
  List<String> _extractActions(String text) {
    final sectionPatterns = [
      RegExp(r'【推奨アクション】\n?([\s\S]+?)(?=【|$)'),
      RegExp(r'推奨アクション[：:]\n?([\s\S]+?)(?=【|$)'),
      RegExp(r'アドバイス[：:]\n?([\s\S]+?)(?=【|$)'),
    ];
    for (final re in sectionPatterns) {
      final m = re.firstMatch(text);
      if (m != null) {
        final raw = m.group(1) ?? '';
        final lines = raw
            .split('\n')
            .map((l) => l.replaceAll(RegExp(r'^[\s✓・\-\*•\d\.]+'), '').trim())
            .where((l) => l.length > 3)
            .where(_isCompleteAction) // 不完全文を除外
            .take(3)
            .toList();
        if (lines.isNotEmpty) return lines;
      }
    }
    return [];
  }

  DailyFortuneResult _parseDailyFortune(String text) {
    int extractScore(String label, List<String> altLabels) {
      final patterns = [
        RegExp('【スコア$label】\\s*(\\d+)\\s*点'),
        for (final al in altLabels) RegExp('【スコア$al】\\s*(\\d+)\\s*点'),
        RegExp('$label.*?(\\d+)\\s*点'),
      ];
      return _tryParseScore(text, patterns) ?? 60;
    }

    final warning = RegExp(r'【注意】\s*(.+)').firstMatch(text)?.group(1)?.trim() ?? '';
    return DailyFortuneResult(
      content: text,
      overallScore: extractScore('総合', ['全体', 'overall']),
      loveScore: extractScore('恋愛', ['love', 'ラブ']),
      workScore: extractScore('仕事', ['work', 'キャリア']),
      moneyScore: extractScore('金運', ['money', 'お金']),
      warning: warning,
    );
  }

  FortuneResult _parseFortuneResult(String text) {
    debugPrint('=== AI raw output ===\n$text\n====================');

    // 新形式: SCORE:XX, ACTION:..., READING:
    int score = 0;
    final actions = <String>[];
    String reading = '';

    // SCORE: 行を抽出
    final scoreMatch = RegExp(r'^SCORE:(\d+)', multiLine: true).firstMatch(text);
    if (scoreMatch != null) {
      final v = int.tryParse(scoreMatch.group(1)!);
      if (v != null && v >= 1 && v <= 100) score = v;
    }

    // ACTION: 行を抽出（最大3つ）
    final actionMatches = RegExp(r'^ACTION:(.+)', multiLine: true).allMatches(text);
    for (final m in actionMatches) {
      final action = m.group(1)!.trim();
      if (_isCompleteAction(action) && actions.length < 3) {
        actions.add(action);
      }
    }

    // READING: 以降を鑑定文として取得
    final readingIdx = text.indexOf('READING:');
    if (readingIdx >= 0) {
      reading = text.substring(readingIdx + 8).trim();
    }

    // --- フォールバック（旧形式・不正形式対応） ---
    if (score == 0) {
      // 旧形式パターン
      final scorePatterns = [
        RegExp(r'【スコア】\s*(\d+)\s*点'),
        RegExp(r'スコア[：:]\s*(\d+)\s*点'),
        RegExp(r'(\d+)\s*点\s*$'),
      ];
      score = _tryParseScore(text, scorePatterns) ?? _defaultScore();
    }

    if (actions.isEmpty) {
      actions.addAll(_extractActions(text));
    }

    if (reading.isEmpty) {
      // 旧形式フォールバック
      final kanteiIdx = text.indexOf('【鑑定】');
      final actionIdx = text.indexOf('【推奨アクション】');
      if (kanteiIdx >= 0) {
        reading = text.substring(kanteiIdx + 4).trim();
      } else if (actionIdx > 0) {
        reading = text
            .substring(0, actionIdx)
            .replaceAll(RegExp(r'【スコア[^】]*】[^\n]*\n?'), '')
            .trim();
      } else {
        reading = text
            .replaceAll(RegExp(r'^SCORE:\d+\n?', multiLine: true), '')
            .replaceAll(RegExp(r'^ACTION:.+\n?', multiLine: true), '')
            .trim();
      }
    }

    if (reading.isEmpty) reading = text;

    return FortuneResult(
      reading: reading,
      score: score,
      suggestedActions: actions,
    );
  }

  /// スコアが取れなかった場合のデフォルト（毎回異なる値）
  int _defaultScore() {
    final now = DateTime.now();
    // 時刻の秒・分を使って 50〜85 の範囲で変動させる
    return 50 + (now.second + now.minute) % 36;
  }

  CompatibilityResult _parseCompatibilityResult(
      String text, String partnerName, String partnerZodiac) {
    // 新形式: OVERALL:XX, LOVE:XX, FRIEND:XX, WORK:XX, ACTION:..., READING:
    int overallScore = 0, loveScore = 0, friendScore = 0, workScore = 0;
    final actions = <String>[];
    String reading = '';

    int extractInt(String key) {
      final m = RegExp('^$key:(\\d+)', multiLine: true).firstMatch(text);
      if (m != null) {
        final v = int.tryParse(m.group(1)!);
        if (v != null && v >= 1 && v <= 100) return v;
      }
      return 0;
    }

    overallScore = extractInt('OVERALL');
    loveScore = extractInt('LOVE');
    friendScore = extractInt('FRIEND');
    workScore = extractInt('WORK');

    final actionMatches = RegExp(r'^ACTION:(.+)', multiLine: true).allMatches(text);
    for (final m in actionMatches) {
      final action = m.group(1)!.trim();
      if (_isCompleteAction(action) && actions.length < 3) {
        actions.add(action);
      }
    }

    final readingIdx = text.indexOf('READING:');
    if (readingIdx >= 0) {
      reading = text.substring(readingIdx + 8).trim();
    }

    // フォールバック
    if (overallScore == 0) {
      int extractOld(String label, List<String> alts) {
        final patterns = [
          RegExp('【$label】\\s*(\\d+)\\s*点'),
          for (final al in alts) RegExp('【$al】\\s*(\\d+)\\s*点'),
          RegExp('$label[：:]\\s*(\\d+)\\s*点'),
        ];
        return _tryParseScore(text, patterns) ?? _defaultScore();
      }
      overallScore = extractOld('総合相性', ['総合', '相性']);
      loveScore = extractOld('恋愛相性', ['恋愛']);
      friendScore = extractOld('友情相性', ['友情']);
      workScore = extractOld('仕事相性', ['仕事']);
    }
    if (actions.isEmpty) actions.addAll(_extractActions(text));
    if (reading.isEmpty) {
      final cutIdx = text.indexOf('【総合相性】');
      if (cutIdx > 0) {
        reading = text.substring(0, cutIdx).trim();
      } else {
        reading = text
            .replaceAll(RegExp(r'^(OVERALL|LOVE|FRIEND|WORK|ACTION):.+\n?', multiLine: true), '')
            .trim();
      }
    }
    if (reading.isEmpty) reading = text;

    return CompatibilityResult(
      reading: reading,
      partnerName: partnerName,
      partnerZodiac: partnerZodiac,
      overallScore: overallScore,
      loveScore: loveScore,
      friendshipScore: friendScore,
      workScore: workScore,
      suggestedActions: actions,
    );
  }

  String _getZodiacSign(DateTime birth) {
    final m = birth.month;
    final d = birth.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return '牡羊座';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return '牡牛座';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 21)) return '双子座';
    if ((m == 6 && d >= 22) || (m == 7 && d <= 22)) return '蟹座';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return '獅子座';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return '乙女座';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 23)) return '天秤座';
    if ((m == 10 && d >= 24) || (m == 11 && d <= 22)) return '蠍座';
    if ((m == 11 && d >= 23) || (m == 12 && d <= 21)) return '射手座';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return '山羊座';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return '水瓶座';
    return '魚座';
  }

  int _calcLifeNumber(DateTime birth) {
    final digits = '${birth.year}${birth.month}${birth.day}'
        .split('')
        .map(int.parse)
        .reduce((a, b) => a + b);
    var n = digits;
    while (n > 9 && n != 11 && n != 22 && n != 33) {
      n = n.toString().split('').map(int.parse).reduce((a, b) => a + b);
    }
    return n;
  }

  String _today() {
    final now = DateTime.now();
    return '${now.year}年${now.month}月${now.day}日';
  }
}
