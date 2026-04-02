#!/bin/bash
set -e

PRODUCT="NoroPlayer"
APP_NAME="$PRODUCT.app"
BUILD_DIR=".build/release"
BUNDLE_DIR="$APP_NAME/Contents"
ENTITLEMENTS="Sources/NoroPlayerMain/NoroPlayer.entitlements"

swift build -c release --product NoroPlayer --product IconRenderer

rm -rf "$APP_NAME"
mkdir -p "$BUNDLE_DIR/MacOS"
mkdir -p "$BUNDLE_DIR/Resources"

cp "$BUILD_DIR/$PRODUCT" "$BUNDLE_DIR/MacOS/$PRODUCT"
cp -r "$BUILD_DIR/${PRODUCT}_NoroPlayerLib.bundle" "$BUNDLE_DIR/Resources/"
cp "Sources/NoroPlayerMain/Info.plist" "$BUNDLE_DIR/Info.plist"
chmod +x "$BUNDLE_DIR/MacOS/$PRODUCT"

# Generate app icon
ICONSET_DIR="$BUNDLE_DIR/Resources/AppIcon.iconset"
mkdir -p "$ICONSET_DIR"
"$BUILD_DIR/IconRenderer" /tmp/AppIcon-1024.png

for size in 16 32 128 256 512; do
    sips -z $size $size /tmp/AppIcon-1024.png --out "$ICONSET_DIR/icon_${size}x${size}.png"     > /dev/null
    sips -z $((size*2)) $((size*2)) /tmp/AppIcon-1024.png --out "$ICONSET_DIR/icon_${size}x${size}@2x.png" > /dev/null
done
iconutil -c icns "$ICONSET_DIR" -o "$BUNDLE_DIR/Resources/AppIcon.icns"
rm -rf "$ICONSET_DIR"

codesign --force --deep --sign - --entitlements "$ENTITLEMENTS" "$APP_NAME"

echo "Built and signed $APP_NAME"
