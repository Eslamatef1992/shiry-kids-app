#!/bin/bash
cd "$(dirname "$0")"
echo "Running flutter pub get..."
flutter pub get
echo "Running pod install..."
cd ios
pod install
cd ..
echo "DONE - you can close this window."
