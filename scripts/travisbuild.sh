#!/bin/sh

cd ~

git config --global user.email "travis@ci.com"
git config --global user.name "Travis"
#git clone --depth=1 -b maint/v0.26 https://github.com/libgit2/libgit2.git
#cd libgit2/
#
#mkdir build && cd build
#cmake .. -DCMAKE_INSTALL_PREFIX=../_install -DBUILD_CLAR=OFF
#cmake --build . --target install
#
#ls -la ..
