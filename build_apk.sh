#!/bin/bash
# Shiry Kids — Build release APK
set -e

cd "$(dirname "$0")"

echo "📦 Getting dependencies..."
flutter pub get

echo "🔨 Building release APK..."
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
  echo ""
  echo "✅ APK ready: $(pwd)/$APK_PATH"
  open "$(dirname "$APK_PATH")"   # opens Finder at the APK location
else
  echo "❌ Build failed — check output above"
fi
