#!/bin/bash
set -e

# 1. Ensure dependencies are vendored
echo "==> Step 1: Vendoring dependencies..."
bash macos/vendor-x86_64-deps.sh

# 2. Build the project
echo "==> Step 2: Configuring and building project..."
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:${PATH}"
export HOMEBREW=/opt/homebrew
export VENDOR="${VENDOR:-$REPO_ROOT/vendor/x86_64}"
export QTDIR="$VENDOR/qt-src/5.14.1/clang_64"
export OSX_DEPLOYMENT_TARGET=10.15

# Go to project root
cd "$REPO_ROOT"

rm -rf builddir-x64 && mkdir builddir-x64 && cd builddir-x64

# -Wl,-platform_version,macos,10.13,10.14 forces the executable's declared SDK to match
# the original (10.13 min / 10.14 SDK) instead of whatever SDK is currently installed. This
# is required for correct native widget styling: macOS AppKit picks its control-rendering
# compatibility era from the executable's declared SDK version — without this flag spinboxes
# render as flat modern boxes instead of the classic macOS blue rounded stepper.
cmake .. \
  -DCMAKE_TOOLCHAIN_FILE="$REPO_ROOT/vendor/x86_64-toolchain.cmake" \
  -DCMAKE_BUILD_TYPE=Release \
  -DUSE_QT=OFF -DUSE_QT5=ON -DUSE_QT_SQLITE=ON \
  -DUSE_MINIUPNP=ON -DUSE_ASPELL=ON -DUSE_PROGRESS_BARS=OFF \
  -DNO_UI_DAEMON=OFF -DJSONRPC_DAEMON=OFF -DPERL_REGEX=ON \
  -DLUA_SCRIPT=ON -DWITH_SOUNDS=ON -DWITH_LUASCRIPTS=ON \
  -DUSE_IDN2=ON \
  -DLOCAL_ASPELL_DATA=OFF -DLOCAL_JSONCPP=ON \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
  -DCMAKE_EXE_LINKER_FLAGS="-Wl,-platform_version,macos,10.13,10.14"

cmake --build . --target all -- -j$(sysctl -n hw.ncpu)

# 3. Create DMG
echo "==> Step 3: Packaging DMG with cpack..."
cpack -G DragNDrop

# 4. Deploy and install
echo "==> Step 4: Installing to /Applications and fixing library rpaths..."
TARGET="/Applications/EiskaltDC++.app"

hdiutil attach EiskaltDC++-*.dmg -nobrowse -mountpoint /tmp/eiskalt_x64

# Suppress errors if not running
pkill -f "EiskaltDC\+\+.app/Contents/MacOS" || true

rm -rf "$TARGET"
cp -a "/tmp/eiskalt_x64/EiskaltDC++.app" "$TARGET"
hdiutil detach /tmp/eiskalt_x64

# Clear any Gatekeeper quarantine attributes added during DMG extraction
# so macOS doesn't block the ad-hoc signed app on first launch.
xattr -cr "$TARGET"

# macdeployqt bundles the Qt frameworks but doesn't add the rpath needed to find
# them -- without this the app crashes on launch with "Library not loaded:
# @rpath/QtWidgets.framework ... no LC_RPATH's found".
install_name_tool -add_rpath "@executable_path/../Frameworks" "$TARGET/Contents/MacOS/EiskaltDC++"

# macdeployqt (via cpack) misses our custom vendored dylibs (like miniupnpc, pcre2) 
# because of how their install names are configured. We manually copy them here.
cp -L "$VENDOR/lib/"*.dylib "$TARGET/Contents/Frameworks/" 2>/dev/null || true

# cpack's ad-hoc signature goes stale the moment frameworks/resources are added
# after the fact, and install_name_tool above invalidates it again -- always
# re-sign last, after all bundle contents are final.
codesign --force --deep --sign - "$TARGET"
codesign --verify --deep --strict "$TARGET"

echo "==> Success! Application installed to $TARGET"
