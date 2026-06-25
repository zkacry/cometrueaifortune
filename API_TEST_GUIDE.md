# API テスト機能ガイド

## 目的
「APIが利用できない」というエラーを診断・解決するための機能です。

## アクセス方法
1. アプリを開く
2. 画面下の「設定」タブをタップ
3. 画面をスクロールして「デバッグ」セクションを見つける
4. 「API接続テスト」をタップ

## テスト実行手順
1. 「テストを実行」ボタンをタップ
2. 各 API サービスへの接続テストが開始されます
3. 結果は以下のように表示されます：

### テスト結果の見方

#### ✅ **成功** (緑表示)
```
[DeepSeek] ✅ OK (200) - Connected successfully. Response: ...
Time: 1523ms
```
**意味**: DeepSeek API に正常に接続でき、レスポンスを取得できた

#### ❌ **失敗** (赤表示)
```
[Gemini] ❌ FAIL (401) - 401 Unauthorized - API key is invalid or expired
Status: 401
Time: 245ms
```
**意味**: Gemini API キーが無効または期限切れ

## よくあるエラーと対策

| ステータス | エラーメッセージ | 対策 |
|-----------|----------------|------|
| 401 | `Unauthorized - API key is invalid` | API キーが間違っているか期限切れ。サービス側で再確認。 |
| 403 | `Forbidden - API key lacks permissions` | API キーに十分な権限がない。サービス側で設定確認。 |
| 429 | `Rate Limited - Too many requests` | リクエスト数制限に達した。暫く待ってから再試行。 |
| 500-503 | `Server Error - Service unavailable` | サービスが一時的にダウン。公式ページで状態確認。 |
| ⏱️ | `Connection Timeout` | インターネット接続が遅い。WiFi 接続を確認。 |
| 🌐 | `Connection Error - No internet` | インターネット接続がない。接続状態を確認。 |

## 両方のサービスが失敗した場合

### 原因の特定フロー
```
1. インターネット接続を確認
   → WiFi または モバイルネットワーク接続を確認

2. API キーの確認
   → .env ファイルに API キーが設定されているか確認
   → キーに空白やタイプミスがないか確認

3. サービス状態の確認
   → DeepSeek: https://www.deepseek.com/
   → Gemini: https://ai.google.dev/

4. アプリの再起動
   → アプリを完全に終了して再起動
```

## 1つのサービスが失敗した場合

⚠️ **問題なし** - もう一方のサービスがバックアップとして使用されます

次の占い要求から、**失敗したサービスをスキップして別のサービスが使用されます**。

### 優先順位
1. **DeepSeek** (第1優先)
2. **Gemini** (第2優先・フォールバック)

### 例
- DeepSeek が 401 エラー → Gemini が使用される
- Gemini が Timeout → DeepSeek が使用される

## テスト後の操作

### ✅ 両方成功した場合
1. 「テストを実行」の結果で確認
2. **アプリを再起動**してから占いを試す
3. エラーが解消されていたら問題解決

### ❌ 両方失敗した場合
1. 診断結果を確認
2. インターネット接続をチェック
3. API キーを確認（.env ファイル）
4. サービス公式ページで状態を確認
5. **開発者に以下の情報を報告**：
   - 両方のエラーメッセージ
   - ステータスコード
   - テスト実行時刻

## 技術詳細（開発者向け）

### テスト対象のエンドポイント
- **DeepSeek**: `https://api.deepseek.com/chat/completions`
- **Gemini**: `https://generativelanguage.googleapis.com/v1beta/openai/chat/completions`

### テスト内容
各サービスに対して以下を実行：
- 簡単なテストメッセージ（"Hello, test message"）を送信
- 最大トークン: 100
- タイムアウト: 10秒

### ログ出力
テスト実行時、debugPrint でログが出力されます：
```
[ApiTest] Starting API tests...
[DeepSeek] ✅ OK (200) - Connected successfully. Response: Hello! ...
[Gemini] ❌ FAIL (401) - 401 Unauthorized - API key is invalid
```

## トラブルシューティング

### Q: テストボタンが反応しない
**A**: テスト実行中の可能性があります。完了まで待ってください。

### Q: テスト実行時にアプリがクラッシュする
**A**: 次のログを確認して開発者に報告してください：
```
Logcat: flutter logs | grep -i "api\|deepseek\|gemini"
```

### Q: テスト結果が毎回異なる
**A**: ネットワーク状況が変わっている可能性があります：
- 同じネットワーク環境で複数回実行
- WiFi が不安定な場合は切り替えを試す

---

**最終更新**: 2026-05-28  
**バージョン**: 1.0  
**関連ファイル**: `lib/data/services/api_test_service.dart`, `lib/features/debug/screens/api_test_screen.dart`
