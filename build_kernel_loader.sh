#!/bin/bash

set -e
set -x

cd edk2/

# create Conf/ directory
source edksetup.sh

# setup Conf/target.txt
cp /home/vscode/KosLoaderPkg/edk2_conf_target.txt /home/vscode/edk2/Conf/target.txt

# link KosLoaderPkg to /path/to/edk2/KosLoaderPkg if not linked
if [ ! -d "./KosLoaderPkg" ]; then
    ln -s /home/vscode/KosLoaderPkg/ ./
fi

build

# copy kernel loader file to host machine
sudo cp /home/vscode/edk2/Build/KosLoaderX64/DEBUG_CLANG38/X64/Loader.efi /home/vscode/output/Loader.efi