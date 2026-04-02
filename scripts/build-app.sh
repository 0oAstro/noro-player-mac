#!/bin/bash
set -e

PRODUCT="NoroPlayer"
APP_NAME="$PRODUCT.app"
BUILD_DIR=".build/release"
BUNDLE_DIR="$APP_NAME/Contents"
ENTITLEMENTS="Sources/NoroPlayerMain/NoroPlayer.entitlements"

swift build -c release

rm -rf "$APP_NAME"
mkdir -p "$BUNDLE_DIR/MacOS"
mkdir -p "$BUNDLE_DIR/Resources"

cp "$BUILD_DIR/$PRODUCT" "$BUNDLE_DIR/MacOS/$PRODUCT"
cp -r "$BUILD_DIR/${PRODUCT}_NoroPlayerLib.bundle" "$BUNDLE_DIR/Resources/"
cp "Sources/NoroPlayerMain/Info.plist" "$BUNDLE_DIR/Info.plist"
chmod +x "$BUNDLE_DIR/MacOS/$PRODUCT"

codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_NAME"

echo "Built and signed $APP_NAME"
