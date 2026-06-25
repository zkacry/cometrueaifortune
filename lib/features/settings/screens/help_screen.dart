import 'package:flutter/material.dart';
import 'package:myfortune/core/theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アプリの使い方'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // セクション 1: アプリについて
            _HelpSection(
              title: '📱 マイフォーチューンについて',
              content:
                  'マイフォーチューンは、AI占い師があなたの悩みや質問に答えるアプリです。\n\n'
                  '毎日の運勢から専門的な占術まで、11種類の占いから選べます。あなたの過去の占い結果を学習するAIペルソナが、より深い洞察を提供します。',
            ),
            const SizedBox(height: 20),

            // セクション 2: 基本的な使い方
            _HelpSection(
              title: '🎯 基本的な使い方',
              content:
                  '【1】ホーム画面\n'
                  '毎日の運勢を確認できます。タップすると詳しい解説が表示されます。\n\n'
                  '【2】占いを選ぶ\n'
                  '「占う」タブから11種類の占いから選択。あなたの悩みや質問を入力して占い結果を得ます。\n\n'
                  '【3】結果を確認\n'
                  '占い結果は「過去の占い」で時系列で保存されます。パターンを分析することで、あなたの傾向が見えてきます。',
            ),
            const SizedBox(height: 20),

            // セクション 3: プランについて
            _HelpSection(
              title: '💎 3つのプラン',
              content:
                  '【Free（無料）】\n'
                  '初月は毎月10回フル占いが無料。2回目以降は毎月3回。毎日の運勢は制限なし。\n\n'
                  '【Light（¥680/月）】\n'
                  '毎月50回フル占い。AIペルソナを選択でき、より詳しい分析が得られます。\n\n'
                  '【Pro（¥1,500/月）】\n'
                  '毎月300回フル占い。月間レポートでパターン分析を自動生成。AI占い師のカスタマイズも可能です。',
            ),
            const SizedBox(height: 20),

            // セクション 4: 占い種類
            _HelpSection(
              title: '🔮 11種類の占い',
              content:
                  '【Free で使える】\n'
                  '🃏 タロット・🔢 数秘術・💕 相性占い・🎋 おみくじ・🩸 血液型占い\n\n'
                  '【Light 以上】\n'
                  '᚛ ルーン占い・🌀 前世占い・⭐ ホロスコープ\n\n'
                  '【Pro 限定】\n'
                  '🏮 四柱推命・📅 縁起カレンダー\n\n'
                  '※ 夢占いは現在メンテナンス中です',
            ),
            const SizedBox(height: 20),

            // セクション 5: AIペルソナ
            _HelpSection(
              title: '🤖 AIペルソナ（Light以上）',
              content:
                  'Light プラン以上で、占い結果の分析スタイルを選べます。\n\n'
                  '【Logica（分析者）】\n'
                  'データと確率を重視した論理的な分析。パターン認識に強い。\n\n'
                  '【Insight（観察者）】\n'
                  '心理的背景と潜在意識を読み取る洞察的な分析。\n\n'
                  '【Strategy（戦略家）】\n'
                  '実践的で行動指向。次のステップを具体的に提案します。',
            ),
            const SizedBox(height: 20),

            // セクション 6: 占い履歴
            _HelpSection(
              title: '📖 占い履歴と分析',
              content:
                  '【占い履歴】\n'
                  '「過去の占い」から全ての占い記録を確認。テーマや日時で検索できます。\n\n'
                  '【月間レポート（Pro限定）】\n'
                  '毎月の占いパターンをAIが自動分析。傾向やアドバイスが自動生成されます。\n\n'
                  '【アクションリスト】\n'
                  '占い結果の提案を実行してチェック。実現の進捗を管理できます。',
            ),
            const SizedBox(height: 20),

            // セクション 7: よくある質問
            _HelpSection(
              title: '❓ よくある質問',
              content:
                  'Q. 占い結果は保存されますか？\n'
                  'A. はい。全ての占い結果は自動的に保存され、いつでも過去の占いを確認できます。\n\n'
                  'Q. プランはいつでも変更できますか？\n'
                  'A. はい。設定からプランを変更できます。\n\n'
                  'Q. 更新日前にキャンセルできますか？\n'
                  'A. はい。Google Play ストアの定期購入から24時間前までにキャンセルできます。\n\n'
                  'Q. より詳しく知りたい場合は？\n'
                  'A. 設定の「ご意見・ご要望」からお気軽にお問い合わせください。',
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  final String title;
  final String content;

  const _HelpSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.8,
            ),
          ),
        ),
      ],
    );
  }
}
