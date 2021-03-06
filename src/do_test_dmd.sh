#!/usr/bin/env bash

# set -x

# args:
#    1) directory for build
#    2) os
#    3) runmode (master, pull)

. src/setup_env.sh "$2"

# expose a prebuilt dmd
if [ "${2:0:7}" == "Darwin_" -o "${2:0:6}" == "Win_32" ]; then
    BINDIR=bin
else
    BINDIR=bin$COMPILER_MODEL
fi
DMDVER=2.079.0
HOST_DC=`ls -1 $PWD/release-build/dmd-$DMDVER/*/$BINDIR/dmd$EXE`
echo "HOST_DC=$HOST_DC" >> $1/dmd-unittest.log 2>&1

if [[ ! -z "$HOST_DC" && ( "$2" == "Win_32" || "$2" == "Win_32_64" ) ]]; then
    HOST_DC=`cygpath -w $HOST_DC`
    echo "HOST_DC=$HOST_DC" >> $1/dmd-unittest.log 2>&1
fi

export HOST_DC

echo -e "\ttesting dmd"

case "$2" in
    stub)
        exit 0
        ;;
    Win_32)
        export PARALLELISM
        ;;
    Win_32_64)
        makefile=win32.mak
        export PARALLELISM
        ;;
esac

if [ "$3" == "pull" ]; then
    ARGS="-O -inline -release"
fi

cd $1/dmd

DMD_PATH=`ls -1 $PWD/generated/*/release/$COMPILER_MODEL/dmd$EXE`

if [ ! -z "$ARGS" ]; then
    $makecmd DMD=$DMD_PATH MODEL=$OUTPUT_MODEL $EXTRA_ARGS RESULTS_DIR=generated ARGS="$ARGS" -f $makefile auto-tester-test >> ../dmd-unittest.log 2>&1
else
    $makecmd DMD=$DMD_PATH MODEL=$OUTPUT_MODEL $EXTRA_ARGS RESULTS_DIR=generated -f $makefile auto-tester-test >> ../dmd-unittest.log 2>&1
fi

if [ $? -ne 0 ]; then
    echo -e "\tdmd tests had failures"
    exit 1
fi

