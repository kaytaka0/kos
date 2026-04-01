#!/bin/sh -eu

. ./devenv/buildenv.sh # setup ENV vars

make ${MAKE_OPTS:-} -C kernel kernel.elf

for MK in $(ls apps/*/Makefile)
do
    APP_DIR=$(dirname $MK)
    APP=$(basename $APP_DIR)
    make ${MAKE_OPTS:-} -C $APP_DIR $APP
done

if [ "${1:-}" = "run" ]
then
    KOS_DIR=$PWD $PWD/devenv/run_kos.sh
fi