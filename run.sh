#!/bin/bash

set -e

ARCH=`uname -m`
TOOLS_ROOT_PATH="$HOME/src/github.com"
EDK2_PATH="$TOOLS_ROOT_PATH/tianocore/edk2"
BUILDKIT_PATH="$TOOLS_ROOT_PATH/uchan-nos/mikanos-build"

KOS_ROOT_PATH="$(cd "$( dirname $0 )" && pwd -P)"

. $BUILDKIT_PATH/devenv/buildenv.sh # setup ENV vars

cd $EDK2_PATH
. ./edksetup.sh # setup "build" command


# Build kernel
echo "\\n====[Build kernel]====="
cd "$KOS_ROOT_PATH/kernel"
make


# Check if the boot loader exists
echo "\\n====[Setup boot loader]========"

LOADER_PATH="$KOS_ROOT_PATH/BOOTX64.EFI"

if [ -f $LOADER_PATH ]; then
    LOADER_UPDATED_AT=`date -r $LOADER_PATH`

    echo "Boot loader already exists. "
    echo "$LOADER_PATH: updated at $LOADER_UPDATED_AT"
    mkdir -p $KOS_ROOT_PATH/DISK/EFI/BOOT && cp -r $LOADER_PATH $KOS_ROOT_PATH/DISK/EFI/BOOT/Loader.efi
else
    echo "Boot loader does not exists. exit..."
    # TODO: build boot loader
    exit
fi


# Run QEMU
echo "\\n====[Run QEMU]======"
cd "$KOS_ROOT_PATH"
$HOME/src/github.com/uchan-nos/mikanos-build/devenv/run_qemu.sh \
    $KOS_ROOT_PATH/DISK/EFI/BOOT/Loader.efi \
    $KOS_ROOT_PATH/kernel/kernel.elf
