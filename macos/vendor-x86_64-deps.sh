#!/bin/bash
set -e

# This script reproduces a working build environment for master that matches the 
# original v2.4.2 binary's behavior and dependencies (Qt 5.14.1, OpenSSL 1.1).
# We avoid Homebrew for these because Homebrew only keeps the latest Qt5 (5.15),
# dropped openssl@1.1 completely when it reached EOL, and defaults to arm64.

VENDOR="$HOME/git/labs/eiskaltdcpp/vendor/x86_64"
NCPU=$(sysctl -n hw.ncpu)

export CC="clang -arch x86_64"
export CXX="clang++ -arch x86_64"
export CFLAGS="-mmacosx-version-min=10.15"
export CXXFLAGS="-mmacosx-version-min=10.15"
export LDFLAGS="-mmacosx-version-min=10.15"

echo "=== Vendoring Qt 5.14.1 ==="
mkdir -p "$VENDOR/qt-src"
cd "$VENDOR/qt-src"
if [ ! -d "5.14.1" ]; then
    uvx --from aqtinstall aqt install-qt mac desktop 5.14.1 clang_64 --outputdir .
else
    echo "Qt 5.14.1 already downloaded."
fi

mkdir -p "$VENDOR/src"
cd "$VENDOR/src"

echo "=== Vendoring OpenSSL 1.1.1w ==="
if [ ! -d "openssl-1.1.1w" ]; then
    curl -fsSL -o openssl-1.1.1w.tar.gz https://www.openssl.org/source/openssl-1.1.1w.tar.gz
    tar xzf openssl-1.1.1w.tar.gz
    cd openssl-1.1.1w
    ./Configure darwin64-x86_64-cc shared no-tests --prefix="$VENDOR"
    make -j$NCPU && make install_sw
    cd ..
else
    echo "OpenSSL already built."
fi

echo "=== Vendoring libintl (Gettext 0.22.5) ==="
if [ ! -d "gettext-0.22.5" ]; then
    curl -fsSL -o gettext-0.22.5.tar.gz https://ftp.gnu.org/pub/gnu/gettext/gettext-0.22.5.tar.gz
    tar xzf gettext-0.22.5.tar.gz
    cd gettext-0.22.5/gettext-runtime/intl
    ./configure --prefix="$VENDOR" --enable-shared --disable-static --host=x86_64-apple-darwin
    make -j$NCPU && make install
    cd ../../..
else
    echo "Gettext already built."
fi

echo "=== Vendoring Lua 5.4.6 ==="
if [ ! -d "lua-5.4.6" ]; then
    curl -fsSL -o lua-5.4.6.tar.gz https://www.lua.org/ftp/lua-5.4.6.tar.gz
    tar xzf lua-5.4.6.tar.gz
    cd lua-5.4.6
    make macosx CC="clang -arch x86_64" -j$NCPU
    make install INSTALL_TOP="$VENDOR"
    cd ..
else
    echo "Lua already built."
fi

echo "=== Vendoring PCRE2 10.42 ==="
if [ ! -d "pcre2-10.42" ]; then
    curl -fsSL -L -o pcre2-10.42.tar.gz https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz
    tar xzf pcre2-10.42.tar.gz
    cd pcre2-10.42
    ./configure --prefix="$VENDOR" --host=x86_64-apple-darwin --enable-shared --disable-static
    make -j$NCPU && make install
    cd ..
else
    echo "PCRE2 already built."
fi

echo "=== Vendoring miniupnpc 2.2.8 ==="
if [ ! -d "miniupnpc-2.2.8" ]; then
    curl -fsSL -o miniupnpc-2.2.8.tar.gz https://miniupnp.tuxfamily.org/files/miniupnpc-2.2.8.tar.gz
    tar xzf miniupnpc-2.2.8.tar.gz
    cd miniupnpc-2.2.8
    rm -rf build && mkdir build && cd build
    cmake .. -DCMAKE_INSTALL_PREFIX="$VENDOR" -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 -DUPNPC_BUILD_SHARED=ON -DUPNPC_BUILD_STATIC=OFF
    make -j$NCPU && make install
    cd ../..
else
    echo "miniupnpc already built."
fi

echo "=== Vendoring libidn2 2.3.4 ==="
if [ ! -d "libidn2-2.3.4" ]; then
    curl -fsSL -o libidn2-2.3.4.tar.gz https://ftp.gnu.org/gnu/libidn/libidn2-2.3.4.tar.gz
    tar xzf libidn2-2.3.4.tar.gz
    cd libidn2-2.3.4
    ./configure --prefix="$VENDOR" --host=x86_64-apple-darwin --enable-shared --disable-static
    make -j$NCPU && make install
    cd ..
else
    echo "libidn2 already built."
fi

echo "=== Vendoring Aspell 0.60.8.2 ==="
if [ ! -d "aspell-0.60.8.2" ]; then
    curl -fsSL -o aspell-0.60.8.2.tar.gz https://ftp.gnu.org/gnu/aspell/aspell-0.60.8.2.tar.gz
    tar xzf aspell-0.60.8.2.tar.gz
    cd aspell-0.60.8.2
    ./configure --prefix="$VENDOR" --host=x86_64-apple-darwin
    make -j$NCPU && make install
    cd ..
else
    echo "Aspell already built."
fi

echo "=== All dependencies successfully vendored to $VENDOR ==="
