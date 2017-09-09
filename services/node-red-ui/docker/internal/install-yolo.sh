#!/bin/sh
set -x
set -e

clear
echo

DIR=$(dirname "$0")
echo "$DIR"
cd /scripts
if [ -f ${DIR}/common.sh ]; then
	. ${DIR}/common.sh
fi

if [ -f ${DIR}/aliases.sh ]; then
	. ${DIR}/aliases.sh
fi

## #################################################################
## global env variables
## #################################################################

# Set temp environment vars
export YOLO_VCS_REPO=https://github.com/OrKoN/darknet.git
export YOLO_VCS_CLONE_BRANCH=${YOLO_VCS_BRANCH:-"master"}
export YOLO_VCS_CLONE_PATH=/tmp/yolo
export YOLO_VCS_CLONE_DEPTH=${YOLO_VCS_CLONE_DEPTH:-"1"}

# for alpine edge
apk add --no-cache --no-progress --update --virtual .deps.build.yolo opencv-dev
apk add --no-cache --no-progress --update --virtual .deps.runtime.yolo opencv-libs # opencv

# Compile & Install
git clone -b ${YOLO_VCS_CLONE_BRANCH} --depth ${YOLO_VCS_CLONE_DEPTH} -- ${YOLO_VCS_REPO} ${YOLO_VCS_CLONE_PATH}

cd ${YOLO_VCS_PATH}
make OPENCV=1 # optionally GPU=1
make install # by default installed to /usr/local

# Cleanup
rm -r ${YOLO_VCS_PATH}
apl del --no-cache .deps.build.yolo

echo 