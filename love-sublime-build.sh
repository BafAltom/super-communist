#!/bin/bash

NAME=Super-Communist
AUTHOR=Altom
LOVE_VERSION=0.9.1

mkdir -p gen_love

if [ -d "src/lib" ] || [ -d "thirdparty/lib" ]; then
    mkdir -p gen_love/lib
    if [ -d "src/lib" ]; then
        cp -ru ./src/lib ./gen_love
    fi

    if [ -d "thirdparty/lib" ]; then
        cp -ru thirdparty/lib ./gen_love
    fi
fi

if [ -d "res" ]; then
    mkdir -p gen_love/res
    cp -ru ./res ./gen_love
fi

cd ./src
moonc -t ../gen_love .

cd ../gen_love
../thirdparty/love-release.sh -l -r build -n $NAME -u $AUTHOR -v0.9.1

love build/$LOVE_VERSION/$NAME.love
