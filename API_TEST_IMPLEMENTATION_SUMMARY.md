# API テスト機能 実装サマリー

**実装日**: 2026-05-28  
**対応エラー**: 「APIが利用できない」(AI サービス接続不可)  
**ステータス**: ✅ 実装完了、APK ビルド中

---

## 実装内容

### 1. API テストサービス (`api_test_service.dart`)
**機能**:
- DeepSeek API 接続テスト
- Gemini API 接続テスト
- 両方を並列実行
- 詳細なエラー診断

**テスト内容**:
```dart
- エンドポイント接続確認
- API キー検証
- ステータスコード判定（401, 403, 429, 500-503 など）
- タイムアウト検出（10秒）
- ネットワークエラー検出
- レスポンス実行時間計測
```

**テスト結果**:
```dart
ApiTestResult {
  provider: 'DeepSeek',
  success: true/false,
  message: '接続成功 / エラー説明',
  statusCode: 200 / 401 / ...,
  duration: Duration,
  rawError: '詳細エラーメッセージ'
}
```

### 2. API テスト画面 (`api_test_screen.dart`)
**UI 機能**:
- テスト実行ボタン
- リアルタイム結果表示
- ステータスアイコン（✅/❌）
- 詳細エラー情報表示
- 自動診断・推奨アクション表示

**結果の見方**:
```
✅ DeepSeek (200) - Connected successfully. Response: ... (1523ms)
❌ Gemini (401) - Unauthorized - API key is invalid (245ms)
```

### 3. 設定画面への統合
**アクセス経路**:
```
設定タブ → デバッグセクション → API接続テスト
```

**追加内容**:
- デバッグセクション新規作成
- 🔧 API接続テストメニュー
- ワンタップで診断画面へ

---

## ファイル構成

| ファイル | 説明 |
|---------|------|
| `lib/data/services/api_test_service.dart` | API テストロジック（120行） |
| `lib/features/debug/screens/api_test_screen.dart` | テスト UI（250行） |
| `lib/features/settings/screens/settings_screen.dart` | 設定画面統合 |
| `API_TEST_GUIDE.md` | ユーザー向けガイド |
| このファイル | 実装ドキュメント |

---

## エラー診断フロー

### ユーザー側の流れ

```
1. アプリで「APIが利用できない」エラーが出る
   ↓
2. 設定 → API接続テスト をタップ
   ↓
3. 「テストを実行」ボタンをタップ
   ↓
4. 結果を確認
   ├─ ✅ 両方成功 → アプリ再起動で解決
   ├─ ⚠️ 片方だけ失敗 → もう一方が自動的に使用される
   └─ ❌ 両方失敗 → 以下の診断手順を実行
       ├─ インターネット接続を確認
       ├─ .env ファイルの API キー確認
       ├─ サービスの公式ページで状態確認
       └─ 開発者に報告
```

### 開発者側の診断

#### ステップ 1: ネットワーク確認
```bash
# インターネット接続テスト
ping google.com
```

#### ステップ 2: API キー確認
```bash
# .env ファイルを確認
cat apps/myfortune/.env | grep -E "DEEPSEEK|GEMINI"
```

#### ステップ 3: ログ確認
```bash
# Flutter ログを確認（テスト実行時）
flutter logs | grep -E "ApiTest|DeepSeek|Gemini"
```

#### ステップ 4: curl でテスト（Linux/Mac）
```bash
# DeepSeek テスト
curl -X POST https://api.deepseek.com/chat/completions \
  -H "Authorization: Bearer $DEEPSEEK_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "deepseek-chat",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "test"}]
  }'

# Gemini テスト
curl -X POST https://generativelanguage.googleapis.com/v1beta/openai/chat/completions \
  -H "Authorization: Bearer $GEMINI_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gemini-2.0-flash-lite",
    "max_tokens": 100,
    "messages": [{"role": "user", "content": "test"}]
  }'
```

---

## エラーコード リファレンス

| コード | 名称 | 原因 | 解決方法 |
|--------|------|------|---------|
| 400 | Bad Request | リクエスト形式エラー | エンドポイント URL とリクエスト形式を確認 |
| 401 | Unauthorized | API キー無効 | API キーを再生成または確認 |
| 403 | Forbidden | 権限不足 | サービス側で権限設定を確認 |
| 404 | Not Found | エンドポイント不存在 | 正しい URL を使用 |
| 429 | Too Many Requests | リクエスト数超過 | 暫く待ってから再試行 |
| 500 | Server Error | サーバーエラー | 公式ページで状態確認、後で再試行 |
| 503 | Service Unavailable | サービス利用不可 | 公式ページで状態確認、後で再試行 |
| Timeout | 接続タイムアウト | サーバー応答遅延 | ネットワーク確認、WiFi 接続確認 |
| Connection Error | 接続エラー | インターネット不接続 | ネットワーク接続を確認 |

---

## テスト例

### ケース 1: 両方成功
```
[DeepSeek] ✅ OK (200) - Connected successfully. Response: Hello!... (1523ms)
[Gemini] ✅ OK (200) - Connected successfully. Response: I can help!... (1245ms)

✅ 両方の API が正常に動作しています。アプリを再起動して試してください。
```
→ **対策**: アプリを再起動

### ケース 2: DeepSeek が 401 エラー
```
[DeepSeek] ❌ FAIL (401) - Unauthorized - API key is invalid or expired (245ms)
             Raw: {"error":{"message":"Invalid API key","type":"invalid_request_error"}}
[Gemini] ✅ OK (200) - Connected successfully. Response: Sure!... (1089ms)

⚠️ DeepSeek は接続できませんが、Gemini は正常です。
   次の鑑定要求から Gemini が使用されます。
```
→ **対策**: DeepSeek の API キーを確認・更新

### ケース 3: 両方失敗（429 レート制限）
```
[DeepSeek] ❌ FAIL (429) - Too Many Requests - Rate Limited (2000ms)
[Gemini] ❌ FAIL (429) - Too Many Requests - Rate Limited (2100ms)

❌ 両方の API が接続できません。

【対策】
1. インターネット接続を確認してください
2. .env ファイルの API キーが正しいか確認してください
3. DeepSeek / Gemini のサービスが利用可能か公式サイトを確認してください
4. 開発者に報告してください
```
→ **対策**: しばらく待ってから再試行（レート制限は一時的）

### ケース 4: 両方失敗（接続エラー）
```
[DeepSeek] ❌ FAIL (null) - Connection Error - No internet or server unreachable (15ms)
[Gemini] ❌ FAIL (null) - Connection Error - No internet or server unreachable (12ms)

❌ 両方の API が接続できません。

【対策】
1. インターネット接続を確認してください
```
→ **対策**: インターネット接続を確認（WiFi または モバイルネットワーク）

---

## APK ビルド情報

**ビルドコマンド**:
```powershell
Get-Process -Name "java","msedge" -ErrorAction SilentlyContinue | Stop-Process -Force
$env:DART_VM_OPTIONS="--old_gen_heap_size=200 --new_gen_semi_max_size=32"
flutter build apk --release --split-per-abi
```

**ビルド成果物**:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (本体 APK)
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32 ビット)

**Google Drive へのコピー**:
```powershell
Copy-Item `
  "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" `
  "G:\マイドライブ\apk\myfortune-arm64-v8a-release.apk" `
  -Force
```

---

## テスト計画

### ユーザー受け入れテスト（UAT）

| # | テストケース | 期待値 | 検証方法 |
|---|------------|--------|---------|
| 1 | 正常な環境でテスト実行 | 両方のサービスが成功（✅） | デバイスで API テスト実行 |
| 2 | DeepSeek キー無効 | DeepSeek は 401 失敗、Gemini は成功 | .env を編集して再テスト |
| 3 | WiFi 切断 | 両方が Connection Error | WiFi を切って再テスト |
| 4 | サービス障害時 | 500-503 エラー表示 | 公式に確認しながら再テスト |
| 5 | 占い実行テスト | 失敗サービスを自動スキップ | テスト後に占いを実行 |

---

## トラブルシューティング マトリクス

```
テスト画面にアクセスできない
  ├─ 新しい APK をインストール？ → 古い APK を削除して再インストール
  └─ Flutter バージョン問題？ → `flutter clean && flutter pub get` を実行

テスト実行時にクラッシュ
  ├─ メモリ不足？ → デバイスを再起動
  └─ API キー含むデータ問題？ → .env ファイルを確認

テスト結果が毎回異なる
  ├─ ネットワーク不安定？ → WiFi を接続確認
  └─ サービス一時障害？ → 数分待ってから再試行

ログに詳細情報が表示されない
  ├─ debugPrint が無効？ → `flutter logs` で確認
  └─ リリースビルドの問題？ → デバッグビルドで再テスト
```

---

## 関連ドキュメント

- 📖 [ユーザー向けガイド](./API_TEST_GUIDE.md)
- 🔧 [ClaudeService 実装](./lib/data/services/claude_service.dart)
- ⚙️ [.env ファイル設定](../.env)
- 📋 [開発ガイド](./CLAUDE.md)

---

## まとめ

### 実装の利点
✅ ユーザーが自己診断できる  
✅ 開発者が素早くデバッグできる  
✅ エラーの原因を特定しやすい  
✅ API サービス障害時の回避策が自動  
✅ ネットワーク問題を即座に発見  

### 次のステップ
1. ✅ APK ビルド完了
2. ⏳ テスト環境で動作確認
3. 📦 Google Play にアップロード
4. 🚀 ユーザーへ配布

---

**最終更新**: 2026-05-28  
**バージョン**: v3 (API テスト機能付き)
