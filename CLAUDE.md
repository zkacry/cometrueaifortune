---
name: myfortune
description: マイ占いアプリ
---

# myfortune - 開発ガイド

## 概要
カスタム占い・運勢アプリ。

## 技術スタック
- **Flutter**: 3.11.5+
- **状態管理**: Riverpod 2.6.x
- **永続化**: SharedPreferences / SQLite (sqflite)

## 開発コマンド

```bash
rtk flutter pub get
rtk flutter run
rtk flutter test
```

## ビルドコマンド

```powershell
# メモリ節約のため java/msedge を先に終了してからビルド
Get-Process -Name "java","msedge" -ErrorAction SilentlyContinue | Stop-Process -Force
$env:DART_VM_OPTIONS="--old_gen_heap_size=200 --new_gen_semi_max_size=32"
flutter build apk --release --split-per-abi
```

## APKビルド後は必ずGoogle Driveにコピーすること

**APKビルドが完了したら、毎回必ず以下のコマンドで arm64 APK を Google Drive にコピーする。**
これは必須手順であり、省略しないこと。

```powershell
Copy-Item `
  "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk" `
  "G:\マイドライブ\apk\myfortune-arm64-v8a-release.apk" `
  -Force
```

コピー先: `G:\マイドライブ\apk\myfortune-arm64-v8a-release.apk`

---

リリース: `python ../../.claude/skills/flutter-release-complete/scripts/orchestrator.py . both 10`
