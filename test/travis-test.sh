#!/bin/sh

set -eux

./build.sh 8.2

PACKAGE=emu-manager
REPO=xcp-emu-manager

git clone git://github.com/xcp-ng/$REPO /tmp/$REPO

cp \
    run.py \
    utils/travis-build-repo.sh \
    utils/travis-build-repo-internal.sh \
    /tmp/$REPO

cd /tmp/$REPO

REPO_PACKAGE_NAME=$PACKAGE \
    REPO_CONFIGURE_CMD=true \
    REPO_BUILD_CMD=make \
    REPO_TEST_CMD=true\
    bash travis-build-repo.sh
