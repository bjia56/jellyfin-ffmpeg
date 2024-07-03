#!/bin/bash

SCRIPT_VERSION="6.3.0"
SCRIPT_SHA512="e85a0dab5195889948a3462189f0e0598d331d3457612e2d3350799dba2e244316d256f8161df5219538eb003e4b5343f989aaa00f96321559063ed8c8f29fd2"
SCRIPT_URL="https://mirrors.kernel.org/gnu/gmp/gmp-${SCRIPT_VERSION}.tar.xz"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    retry-tool check-wget "gmp.tar.xz" "$SCRIPT_URL" "$SCRIPT_SHA512"

    if [[ $TARGET == mac* ]]; then
        gtar xaf "gmp.tar.xz"
    else
        tar xaf "gmp.tar.xz"
    fi
    cd "gmp-$SCRIPT_VERSION"

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-maintainer-mode
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    elif [[ $TARGET == mac* ]]; then
        myconf+=(
            --enable-cxx
        )
        # The shipped configure script relies on an outdated libtool version
        # which causes linker errors due to name collisions on macOS
        # leads to wrongly compiled libraries
        # regenerate the configure ourselves as a workaroud
        autoreconf -i -s
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-gmp
}

ffbuild_unconfigure() {
    echo --disable-gmp
}
