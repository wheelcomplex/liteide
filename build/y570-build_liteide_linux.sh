#!/bin/sh

exedir=`dirname $0`
cd $exedir

export BUILD_ROOT=$PWD

if [ -z $LITEIDE_ROOT ]; then
	export LITEIDE_ROOT=$PWD/../liteidex
fi

echo build liteide
echo QTDIR=$QTDIR
echo GOROOT=$GOROOT
echo BUILD_ROOT=$BUILD_ROOT
echo LITEIDE_ROOT=$LITEIDE_ROOT
echo .

if [ -z $QTDIR ]; then
	echo 'error, QTDIR is null'
	exit 1
fi

export PATH=$QTDIR/bin:$PATH

echo qmake liteide ...
echo .
qmake $LITEIDE_ROOT -spec linux-g++ "CONFIG+=release"

if [ $? -ge 1 ]; then
	echo 'error, qmake fail'
	exit 1
fi

echo make liteide ...
echo .
make -j8

if [ $? -ge 1 ]; then
	echo 'error, make fail'
	env | grep LIBRARY_PATH
	exit 1
fi

go version
if [ $? -ge 1 ]; then
	echo 'error, not find go in PATH'
	exit 1
fi

echo build liteide tools ...
cd $LITEIDE_ROOT

if [ -z $GOPATH]; then
	export GOPATH=$PWD
else
	export GOPATH=$PWD:$GOPATH
fi

go get -t -v github.com/visualfc/gotools && go install -ldflags "-s" -v github.com/visualfc/gotools

if [ $? -ge 1 ]; then
	echo 'error, go install github.com/visualfc/gotoolss fail'
	exit 1
fi
go get -t github.com/nsf/gocode && go install -ldflags "-s" -v github.com/nsf/gocode

if [ $? -ge 1 ]; then
	echo 'error, go install fail'
	exit 1
fi

echo deploy ...

cd $BUILD_ROOT

rm -rf liteide
mkdir -p liteide
mkdir -p liteide/bin
mkdir -p liteide/share/liteide
mkdir -p liteide/lib/liteide/plugins
if [ $? -ge 1 ]; then
	echo 'error, mkdir fail'
	exit 1
fi

cp -a -v $LITEIDE_ROOT/LICENSE.LGPL liteide
cp -a -v $LITEIDE_ROOT/LGPL_EXCEPTION.TXT liteide
cp -a -v $LITEIDE_ROOT/../README.md liteide
cp -a -v $LITEIDE_ROOT/../CONTRIBUTORS liteide

cp -a -v $LITEIDE_ROOT/liteide/bin/* liteide/bin/
cp -a -v $LITEIDE_ROOT/bin/gotools liteide/bin/
cp -a -v $LITEIDE_ROOT/bin/gocode liteide/bin/
cp -a -v $LITEIDE_ROOT/liteide/lib/liteide/libliteapp.* liteide/lib/liteide
cp -a -v $LITEIDE_ROOT/liteide/lib/liteide/plugins/*.so liteide/lib/liteide/plugins

cp -r -v $LITEIDE_ROOT/deploy/* liteide/share/liteide/
cp -r -v $LITEIDE_ROOT/os_deploy/linux/* liteide/share/liteide/

export BUILD_ROOT=$PWD

if [ -z $LITEIDE_ROOT ]; then
	export LITEIDE_ROOT=$PWD/../liteidex
fi

echo build liteide 
echo QTDIR=$QTDIR
echo GOROOT=$GOROOT
echo BUILD_ROOT=$BUILD_ROOT
echo LITEIDE_ROOT=$LITEIDE_ROOT
echo .

if [ -z $QTDIR ]; then
	echo 'error, QTDIR is null'
	exit 1
fi

cp -a -v $QTDIR/lib/x86_64-linux-gnu/libQtCore.so* liteide/lib/liteide
cp -a -v $QTDIR/lib/x86_64-linux-gnu/libQtGui.so* liteide/lib/liteide
cp -a -v $QTDIR/lib/x86_64-linux-gnu/libQtXml.so* liteide/lib/liteide

cp -a -v $QTDIR/lib/x86_64-linux-gnu/libQtNetwork.so* liteide/lib/liteide
cp -a -v $QTDIR/lib/x86_64-linux-gnu/libQtWebKit.so* liteide/lib/liteide
