#!/bin/bash

set -e

TOOLS_ROOT_PATH="$HOME/src/github.com"
EDK2_PATH="$TOOLS_ROOT_PATH/tianocore/edk2" # not used
BUILDKIT_PATH="$TOOLS_ROOT_PATH/uchan-nos/mikanos-build"

KOS_ROOT_PATH="$(cd "$( dirname $0 )" && pwd -P)"

# Build kernel loader (the kernel loader will be output to $KOS_ROOT_PATH/DISK/EFI/BOOT/Loader.efi)
echo "\\n====[Build kernel loader]====="
docker compose up --build

. $BUILDKIT_PATH/devenv/buildenv.sh # setup ENV vars

# Build kernel
echo "\\n====[Build kernel]====="
cd "$KOS_ROOT_PATH/kernel"
make

# Run QEMU
echo "\\n====[Run QEMU]======"
cd "$KOS_ROOT_PATH"
$HOME/src/github.com/uchan-nos/mikanos-build/devenv/run_qemu.sh \
    $KOS_ROOT_PATH/DISK/EFI/BOOT/Loader.efi \
    $KOS_ROOT_PATH/kernel/kernel.elf
