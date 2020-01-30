#!/bin/sh

echo
echo ">> init.sh"
echo

BASE=$(dirname $(realpath $0))
cd ${BASE}
. ./common.sh

# sudo pkg update
# sudo pkg install -y devel/powerpc64-xtoolchain-gcc || exit 1

# XXX: Need to build default and i386 toolchains?
# cd /usr/src || exit 1
# sudo make -s -j${NCPU} kernel-toolchain || exit 1
# sudo make -s -j${NCPU} kernel-toolchain TARGET_ARCH=i386 || exit 1
# sudo make -s -j${NCPU} kernel-toolchain TARGET_ARCH=aarch64 || exit 1

# Override variables from common.sh and remove default branches
FREEBSD_BRANCHES="stable/11 stable/12 release/11.3.0 release/12.0.0 releng/12.1"
DRM_BRANCHES="drm-v4.11-fbsd11.2 drm-v4.16-fbsd12.0 drm-v5.0-fbsd12.1 drm-v4.16"

cd ${BASE}
mkdir -p source || exit 1

#
# FreeBSD source
#
cd source || exit 1

if [ ! -e "freebsd-master" ]; then
	git clone --config remote.origin.fetch='+refs/notes/*:refs/notes/*' https://github.com/freebsd/freebsd freebsd-master || exit 1
fi

cd freebsd-master || exit 1
for branch in ${FREEBSD_BRANCHES}
do
	branch_file=$(echo ${branch} | sed 's/\//_/')
	if [ ! -e "../freebsd-${branch_file}" ]; then
		git worktree add --track -b ${branch} ../freebsd-${branch_file} origin/${branch} || exit 1
	fi
done

#
# DRM source
#
cd ${BASE}/source || exit 1

if [ ! -e "drm-v5.0" ]; then
	git clone https://github.com/FreeBSDDesktop/kms-drm.git --branch drm-v5.0 drm-v5.0  || exit 1
fi

cd drm-v5.0 || exit 1
for branch in ${DRM_BRANCHES}
do
	if [ ! -e "../${branch}" ]; then
		git worktree add --track -b ${branch} ../${branch} origin/${branch} || exit 1
	fi
done

#
# DRM legacy source
#
cd ${BASE}/source || exit 1
if [ ! -e "drm-legacy" ]; then
	git clone https://github.com/FreeBSDDesktop/drm-legacy.git drm-legacy  || exit 1
fi

exit 0
