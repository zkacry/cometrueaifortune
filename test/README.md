# myfortune テストスイート

## テスト構成

### `unit/` - ユニットテスト
ビジネスロジック、モデル、サービスの単体テスト
- `models/` - Consultationなどデータモデルのテスト
- `services/` - AdService、DatabaseServiceなどのテスト
- `providers/` - Riverpod状態管理プロバイダのテスト

### `widget/` - ウィジェットテスト
UI要素の動作確認
- `result_screen_test.dart` - 占い結果画面の表示テスト
- その他のスクリーンやコンポーネントテスト

### `integration/` - 統合テスト
外部サービス統合のテスト
- **APIテストは無効化**（外部依存のため）
  - Claude API呼び出しテスト
  - Firebase認証テスト
  - これらはスキップ状態で定義

## 実行方法

### すべてのテストを実行
```bash
rtk flutter test
```

### 特定のテストファイルを実行
```bash
rtk flutter test test/unit/models/consultation_test.dart
```

### スキップされたテストを含める（オプション）
```bash
rtk flutter test --include-skipped
```

### 特定のテストグループを実行
```bash
rtk flutter test -k "AdService"
```

## テスト方針

### ✅ 実装対象
- **ユニットテスト**: モデル、ロジック、状態管理
- **ウィジェットテスト**: UI表示、ユーザーインタラクション
- **ローカル統合テスト**: Database、SharedPreferences

### ❌ スキップ対象
- **外部API呼び出し**: Claude API、Firebase（本番環境依存）
- **Google Mobile Ads**: AdMob（デバイステストで確認）

## カバレッジ

現在のテスト対象：
- [ ] Models (Consultation, ActionLog) - 実装済み
- [ ] Services (AdService, DatabaseService) - 実装済み
- [ ] Screens (ResultScreen) - 実装済み
- [ ] Action Item Widget - 計画中
- [ ] Repositories - 計画中

目標: **70%以上のコードカバレッジ**

## 実装予定

```
Priority 1 (必須)
- Action Item Repository テスト
- Subscription Provider テスト

Priority 2 (推奨)
- Action Item Widget テスト
- 占いプロバイダテスト

Priority 3 (optional)
- E2E エンドツーエンドテスト
- パフォーマンステスト
```

## 注意事項

- テストはローカルで完全実行可能である必要があります
- 外部API呼び出しは避けてください（フェイクデータを使用）
- テストは独立していて、実行順序に依存しないようにしてください
