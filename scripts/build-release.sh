#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${VERSION:-1.0.2}"
export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"

BUILD_DIR="$ROOT_DIR/build"
DERIVED_DATA="$BUILD_DIR/DerivedData"
STAGING_DIR="$BUILD_DIR/dmg-staging"
DIST_DIR="$ROOT_DIR/dist"
APP_PATH="$DERIVED_DATA/Build/Products/Release/止界.app"
EXECUTABLE_PATH="$APP_PATH/Contents/MacOS/止界"
DMG_NAME="Jiezhi-v${VERSION}.dmg"
DMG_PATH="$DIST_DIR/$DMG_NAME"

command -v xcodegen >/dev/null || {
    echo "错误：未找到 xcodegen。请先安装 XcodeGen。" >&2
    exit 1
}

for tool in xcodebuild codesign lipo hdiutil shasum ditto; do
    command -v "$tool" >/dev/null || {
        echo "错误：未找到 $tool。" >&2
        exit 1
    }
done

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$BUILD_DIR" "$DIST_DIR"

cd "$ROOT_DIR"
xcodegen generate

xcodebuild \
    -project Jiezhi.xcodeproj \
    -scheme Jiezhi \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$DERIVED_DATA" \
    ARCHS='arm64 x86_64' \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGNING_ALLOWED=NO \
    build

test -d "$APP_PATH" || {
    echo "错误：未生成 $APP_PATH" >&2
    exit 1
}

/usr/bin/codesign --force --deep --sign - --timestamp=none "$APP_PATH"
/usr/bin/codesign --verify --deep --strict --verbose=2 "$APP_PATH"

ARCHITECTURES="$(/usr/bin/lipo -archs "$EXECUTABLE_PATH")"
for architecture in arm64 x86_64; do
    if [[ " $ARCHITECTURES " != *" $architecture "* ]]; then
        echo "错误：可执行文件缺少 $architecture 架构（当前：$ARCHITECTURES）。" >&2
        exit 1
    fi
done
/usr/bin/lipo -info "$EXECUTABLE_PATH"

rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
/usr/bin/ditto "$APP_PATH" "$STAGING_DIR/止界.app"
ln -s /Applications "$STAGING_DIR/Applications"

/usr/bin/hdiutil create \
    -volname "止界" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDZO \
    "$DMG_PATH"
/usr/bin/hdiutil verify "$DMG_PATH"

(
    cd "$DIST_DIR"
    /usr/bin/shasum -a 256 "$DMG_NAME" > "$DMG_NAME.sha256"
)

echo "发布构建完成："
echo "  App: $APP_PATH"
echo "  DMG: $DMG_PATH"
echo "  SHA: $DMG_PATH.sha256"
