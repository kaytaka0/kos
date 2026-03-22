#!/bin/sh -ex

DEVENV_DIR=$(dirname "$0")
MOUNT_POINT=./mnt

if [ "$DISK_IMG" = "" ]
then
    DISK_IMG="./disk.img"
fi

if [ "$KOS_DIR" = "" ]
then
    KOS_DIR="$HOME/src/github.com/kaytaka0/kos"
fi

LOADER_EFI="$KOS_DIR/DISK/EFI/BOOT/Loader.efi"
KERNEL_ELF="$KOS_DIR/kernel/kernel.elf"

$DEVENV_DIR/make_image.sh $DISK_IMG $MOUNT_POINT $LOADER_EFI $KERNEL_ELF
$DEVENV_DIR/mount_image.sh $DISK_IMG $MOUNT_POINT

if [ $APPS_DIR  != "" ]
then
    sudo mkdir $MOUNT_POINT/$APPS_DIR
fi

for APP in $(ls "$KOS_DIR/apps")
do
    if [ -f $KOS_DIR/apps/$APP/$APP ]
    then
        sudo cp $KOS_DIR/apps/$APP/$APP $MOUNT_POINT/$APPS_DIR
    fi
done

if [ "$RECURSE_DIR" != "" ]
then
    sudo cp $KOS_DIR/$RECURSE_DIR/* $MOUNT_POINT/
fi

sleep 0.5
sudo umount $MOUNT_POINT