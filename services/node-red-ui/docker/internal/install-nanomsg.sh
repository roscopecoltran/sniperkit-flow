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
export NANOMSG_VCS_REPO=https://github.com/nanomsg/nanomsg.git
export NANOMSG_VCS_CLONE_BRANCH=${NANOMSG_VCS_BRANCH:-"v1.0.0"}
export NANOMSG_VCS_CLONE_PATH=/tmp/nanomsg
export NANOMSG_VCS_CLONE_DEPTH=${NANOMSG_VCS_CLONE_DEPTH:-"1"}

apk add --no-cache --no-progress --update --virtual .deps.nanomsg cmake

# Compile & Install
git clone -b ${NANOMSG_VCS_CLONE_BRANCH} --depth ${NANOMSG_VCS_CLONE_DEPTH} -- ${NANOMSG_VCS_REPO} ${NANOMSG_VCS_CLONE_PATH}

mkdir -p ${NANOMSG_VCS_PATH}/build
cd ${NANOMSG_VCS_PATH}/build
cmake .. -DBUILD_CLAR=off
cmake --build . --target install

# Cleanup
rm -r ${NANOMSG_VCS_PATH}
apl del --no-cache .deps.nanomsg

echo 
