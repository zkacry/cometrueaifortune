# Phase 2: 毎日の運勢通知システム - 完成レポート

## 実装完了日
2026-05-16

## 実装内容

### 1. NotificationService (`lib/data/services/notification_service.dart`)
**目的**: プッシュ通知のスケジューリングと管理

**実装内容**:
- ✅ `initialize()` - アプリ起動時にTimezoneとプラットフォーム別設定を初期化
  - Timezone初期化（timezone パッケージ）
  - Androidチャネル作成（Daily Fortune チャネルID: `daily_fortune`）
  - iOS権限リクエスト設定（alert, badge, sound）
  
- ✅ `scheduleDailyNotification(hour, title, body)` - 日次通知をスケジュール
  - タイムゾーン対応（timezone パッケージ）
  - 毎日指定時刻に同じ通知IDで再スケジュール
  - Android/iOS別の通知詳細設定
  - マッチング方式: `DateTimeComponents.time`（時分のみ比較）

- ✅ `cancelDailyNotification()` - 通知をキャンセル

- ✅ `requestPermissions()` - iOS通知権限のリクエスト

**技術仕様**:
- パッケージ: `flutter_local_notifications: ^17.2.4`
- Timezone対応: `timezone: ^0.9.4`
- エラーハンドリング: 全メソッドで try-catch対応
- Web対応: Web環境での無効化（例外処理）

---

### 2. UserProfile モデル拡張 (`lib/data/models/user_profile.dart`)
**目的**: ユーザーの通知設定を永続化

**追加フィールド**:
```dart
final bool notificationEnabled;        // デフォルト: true
final int notificationHour;            // 0-23, デフォルト: 9
```

**実装内容**:
- ✅ Firestore永続化
  - `toFirestore()` で両フィールドを保存
  - `fromFirestore()` で読み込み時にデフォルト値設定

- ✅ `copyWith()` メソッド対応
  - 他のフィールドと同時更新可能

---

### 3. SettingsScreen UI (`lib/features/settings/screens/settings_screen.dart`)
**目的**: ユーザーが通知設定を変更できるUI

**実装内容**:

#### 3.1 通知ON/OFFトグル
- Material Switch コンポーネント
- `notificationEnabled` 状態と連動
- トグル時にサブタイトルが「毎日HH:00に通知を受け取ります」 → 「通知はオフです」に変更

#### 3.2 時間選択ダイアログ
- **スライダー**: 0〜23時を自由に選択
- **クイック選択ボタン**: 9時, 12時, 18時, 21時のプリセット
- **リアルタイムプレビュー**: HH:00 形式で即座に表示
- **状態管理**: StatefulBuilder で dialog内の状態を独立管理

#### 3.3 保存ボタン
- Firestore に変更を保存
- NotificationService で通知を再スケジュール
- スナックバー で成功/失敗を通知
- ローディング状態を表示

**UI構成**:
```
+─ 通知設定セクション
   ├─ [トグル] 毎日の運勢通知
   ├─ 毎日HH:00に通知を受け取ります（トグルがONの場合のみ）
   ├─ [編集] 通知時間: HH:00（トグルがONの場合のみ）
   └─ [保存ボタン]
+─ ユーザー情報セクション（既存）
+─ サポートセクション（既存）
```

---

### 4. UserRepository 拡張 (`lib/data/repositories/user_repository.dart`)
**追加メソッド**:
```dart
Future<void> updateNotificationSettings(
  String uid, {
  required bool enabled,
  required int hour,
}) async {
  await _db.collection('users').doc(uid).update({
    'notificationEnabled': enabled,
    'notificationHour': hour,
  });
}
```

---

### 5. main.dart 初期化 (`lib/main.dart`)
**実装内容**:

#### 5.1 NotificationService の初期化
```dart
try {
  await NotificationService.initialize();
} catch (e) {
  debugPrint('NotificationService init error: $e');
}
```

#### 5.2 app起動時の通知リスケジュール
`_StartupRouter._resolve()` で:
- ユーザープロフィール読み込み後に通知設定を確認
- `notificationEnabled == true` の場合: 設定時刻で再スケジュール
- `notificationEnabled == false` の場合: キャンセル
- エラー時はログ出力のみで継続（アプリ起動を妨げない）

---

## ユーザー要件への対応表

| 要件 | 実装内容 | 完成度 |
|------|--------|--------|
| 毎日9時にして | `notificationHour = 9` (デフォルト) | ✅ 100% |
| 時間設定できること | SettingsScreen 時間ピッカーダイアログ | ✅ 100% |
| オフにできる | トグルスイッチ `notificationEnabled` | ✅ 100% |
| すべて実装 | UI + データモデル + 通知スケジュール + 永続化 | ✅ 100% |

---

## テスト方法

### Android での検証
```bash
flutter run -d emulator  # または実機
```
1. ホームスクリーン → 設定タブ
2. 「通知設定」セクションを確認
3. トグルをON → 時刻編集 → 設定を保存
4. アプリを再起動 → 設定が復元されることを確認

### iOS での検証
```bash
flutter run -d ios
```
1. 通知許可ダイアログが表示される
2. 「許可」を選択 → 設定が保存される
3. ホームスクリーン → 設定タブで時刻変更可能

### Web での注意
- Web 環境では native notifications がサポートされていません
- `flutter_local_notifications` は Android/iOS のみ対応
- Web での実行時はエラーハンドリングで gracefully 対応

---

## ファイル変更一覧

```
M  pubspec.yaml
   - flutter_local_notifications: ^17.1.3 追加
   - timezone: ^0.9.4 追加 (pubspec.lock に自動追加)

M  lib/main.dart
   + NotificationService import
   + NotificationService.initialize() in main()
   + _StartupRouter で通知リスケジュール

M  lib/data/models/user_profile.dart
   + notificationEnabled field
   + notificationHour field
   ~ toFirestore() / fromFirestore() / copyWith() 更新

A  lib/data/services/notification_service.dart
   + NotificationService class (新規)

M  lib/data/repositories/user_repository.dart
   + updateNotificationSettings() メソッド

M  lib/features/settings/screens/settings_screen.dart
   + 通知設定UI セクション
   + _showTimePickerDialog() メソッド
   + _QuickHourButton widget
```

---

## 実装完了

すべての機能が実装完了し、Android/iOS でのテスト準備が整いました。
