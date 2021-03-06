#!/usr/bin/env bash

# set -x

# args:
#    1) directory for build
#    2) os

. src/setup_env.sh "$2"

if [ "${2:0:7}" == "Darwin_" -o "${2:0:6}" == "Win_32" ]; then
    BINDIR=bin
else
    BINDIR=bin$COMPILER_MODEL
fi

echo -e "\tbuilding dmd"

top=$PWD
cd $1/dmd

# expose a prebuilt dmd
DMDVER=2.079.0
HOST_DC=`ls -1 $top/release-build/dmd-$DMDVER/*/$BINDIR/dmd$EXE`
echo "HOST_DC=$HOST_DC" >> ../dmd-build.log 2>&1

if [[ ! -z "$HOST_DC" && ( "$2" == "Win_32" || "$2" == "Win_32_64" ) ]]; then
    HOST_DC=`cygpath -w $HOST_DC`
    echo "HOST_DC=$HOST_DC" >> ../dmd-build.log 2>&1
fi

if [ "$makefile" == "win64.mak" ]; then
    makefile=win32.mak
fi

export HOST_DC

$makecmd MAKE=$makecmd MODEL=$COMPILER_MODEL $EXTRA_ARGS -f $makefile auto-tester-build >> ../dmd-build.log 2>&1
if [ $? -ne 0 ]; then
    echo -e "\tfailed to build dmd"
    exit 1
fi

if [ "$2" != "Win_32" -a "$2" != "Win_32_64" ]; then
    $makecmd MODEL=$COMPILER_MODEL $EXTRA_ARGS -f $makefile install >> ../dmd-build.log 2>&1
    if [ $? -ne 0 ]; then
	echo -e "\tfailed to install $repo"
	exit 1
    fi
fi
