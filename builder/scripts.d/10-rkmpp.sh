#!/bin/bash

SCRIPT_REPO="https://github.com/nyanmisaka/mpp.git"
SCRIPT_COMMIT="jellyfin-mpp"

ffbuild_enabled() {
    [[ $TARGET == linux* ]] && [[ $TARGET == *arm64 ]] && return 0
    return -1
}

ffbuild_dockerbuild() {
    git clone "$SCRIPT_REPO" mpp
    cd mpp
    git checkout "$SCRIPT_COMMIT"

    mkdir rkmpp_build
    cmake \
        -DENABLE_RKMPP=ON \
        -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_SHARED=OFF \
        -DBUILD_TEST=OFF \
        ..

    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-rkmpp
}

ffbuild_unconfigure() {
    echo --disable-rkmpp
}
