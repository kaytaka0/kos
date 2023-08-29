#/bin/bash

set -eo pipefail

DIR="$(cd "$( dirname $0 )" && pwd -P)"

# Build kernel
echo "====[Build kernel]================================"
echo "cd $DIR/kernel"
cd "$DIR/kernel"
make


# Build the boot loader
echo "====[Build boot loader]==========================="
echo "cd $HOME/edk2/"
cd "$HOME/edk2/"

echo "source edksetup.sh && build"
source edksetup.sh && build

cp ./Build/KosLoaderX64/DEBUG_CLANG38/X64/Loader.efi $DIR/BOOTX64.EFI
echo -e "copy BOOTX64.EFI done!!! \n"


# Run QEMU
echo "====[Run QEMU]===================================="
echo "cd $DIR"
cd "$DIR"
$HOME/osbook/devenv/run_qemu.sh ./BOOTX64.EFI $HOME/kos/kernel/kernel.elf
