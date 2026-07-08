if(DEFINED ENV{VENDOR})
    set(VENDOR "$ENV{VENDOR}")
else()
    set(VENDOR "${CMAKE_CURRENT_LIST_DIR}/x86_64")
endif()

if(DEFINED ENV{QTDIR})
    set(QTDIR "$ENV{QTDIR}")
else()
    set(QTDIR "${VENDOR}/qt-src/5.14.1/clang_64")
endif()

if(DEFINED ENV{HOMEBREW})
    set(HOMEBREW "$ENV{HOMEBREW}")
else()
    set(HOMEBREW "/opt/homebrew")
endif()

if(DEFINED ENV{OSX_DEPLOYMENT_TARGET})
    set(OSX_DEPLOYMENT_TARGET "$ENV{OSX_DEPLOYMENT_TARGET}")
else()
    set(OSX_DEPLOYMENT_TARGET "10.15")
endif()

set(OSX_ARCHITECTURES "x86_64")

# Qt and OpenSSL come ONLY from the vendored x86_64 copies -- deliberately not
# adding the bare ${HOMEBREW} prefix here, since that would also expose
# Homebrew's Qt 5.15 headers via its generic /opt/homebrew/include/QtCore
# symlink, causing both Qt versions' headers to collide in the same build.
set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${QTDIR}")
set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${VENDOR}")

# jsoncpp is handled via LOCAL_JSONCPP=ON.
# aspell, lua, miniupnpc, libidn2, and pcre2 are now vendored locally.

set(Qt5_DIR "${QTDIR}/lib/cmake/Qt5" CACHE PATH "Qt5_DIR")

# gettext/libintl: vendored static x86_64 build (Homebrew's is arm64-only)
set(GETTEXT_SEARCH_PATH "${VENDOR}" CACHE PATH "GETTEXT_SEARCH_PATH")
set(GETTEXT_INCLUDE_DIR "${VENDOR}/include" CACHE PATH "GETTEXT_INCLUDE_DIR")
set(GETTEXT_LIBRARIES "${VENDOR}/lib/libintl.dylib" CACHE FILEPATH "GETTEXT_LIBRARIES")
set(GETTEXT_INTL_LIBRARY "${VENDOR}/lib/libintl.dylib" CACHE FILEPATH "GETTEXT_INTL_LIBRARY")
set(GETTEXT_MSGMERGE_EXECUTABLE "${HOMEBREW}/bin/msgmerge" CACHE FILEPATH "msgmerge")
set(GETTEXT_MSGFMT_EXECUTABLE "${HOMEBREW}/bin/msgfmt" CACHE FILEPATH "msgfmt")
set(GETTEXT_XGETTEXT_EXECUTABLE "${HOMEBREW}/bin/xgettext" CACHE FILEPATH "xgettext")
set(GETTEXT_MSGINIT_EXECUTABLE "${HOMEBREW}/bin/msginit" CACHE FILEPATH "msginit")
set(GETTEXT_MSGCAT_EXECUTABLE "${HOMEBREW}/bin/msgcat" CACHE FILEPATH "msgcat")
set(GETTEXT_MSGCONV_EXECUTABLE "${HOMEBREW}/bin/msgconv" CACHE FILEPATH "msgconv")

set(OPENSSL_ROOT_DIR "${VENDOR}" CACHE PATH "OPENSSL_ROOT_DIR")
set(OPENSSL_INCLUDE_DIR "${VENDOR}/include" CACHE PATH "OPENSSL_INCLUDE_DIR")
set(OPENSSL_SSL_LIBRARY "${VENDOR}/lib/libssl.dylib" CACHE FILEPATH "OPENSSL_SSL_LIBRARY")
set(OPENSSL_CRYPTO_LIBRARY "${VENDOR}/lib/libcrypto.dylib" CACHE FILEPATH "OPENSSL_CRYPTO_LIBRARY")

set(CMAKE_C_COMPILER   "clang")
set(CMAKE_CXX_COMPILER "clang++")

set(CMAKE_OSX_ARCHITECTURES "${OSX_ARCHITECTURES}"
    CACHE STRING "CMAKE_OSX_ARCHITECTURES")
set(CMAKE_OSX_DEPLOYMENT_TARGET "${OSX_DEPLOYMENT_TARGET}"
    CACHE STRING "CMAKE_OSX_DEPLOYMENT_TARGET")

set(CMAKE_INSTALL_PREFIX "${HOMEBREW}" CACHE PATH "Installation Prefix")
