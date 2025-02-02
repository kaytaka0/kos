#/bin/bash

set -e

KOS_ROOTDIR="$(cd "$( dirname $0 )" && pwd -P)"

# Build kernel
echo "\\n====[Build kernel]====="
cd "$KOS_ROOTDIR/kernel"
make


# Build the boot loader
echo "\\n====[Setup boot loader]========"
EDK2_PATH="$HOME/src/github.com/tianocore/edk2"
LOADER_PATH="$EDK2_PATH/Build/KosLoaderX64/DEBUG_CLANGPDB/X64/KosLoaderPkg/Loader/OUTPUT/Loader.efi"

if [ -f $LOADER_PATH ]; then
    LOADER_UPDATED_AT=`date -r $LOADER_PATH`

    echo "Boot loader already exists. "
    echo "$LOADER_PATH: updated at $LOADER_UPDATED_AT"
    cp $LOADER_PATH $KOS_ROOTDIR/DISK/EFI/BOOT/Loader.efi
else
    echo "Building boot loader..."
    cd $EDK2_PATH
    pwd
    build
    cp $LOADER_PATH $KOS_ROOTDIR/DISK/EFI/BOOT/Loader.efi
fi


# Run QEMU
echo "\\n====[Run QEMU]======"
cd "$KOS_ROOTDIR"
$HOME/src/github.com/uchan-nos/mikanos-build/devenv/run_qemu.sh \
    $KOS_ROOTDIR/DISK/EFI/BOOT/Loader.efi \
    $KOS_ROOTDIR/kernel/kernel.elf
