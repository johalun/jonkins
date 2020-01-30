#!/bin/sh

echo
echo ">> update.sh"
echo

BASE=$(dirname $(realpath $0))
cd ${BASE}
. ./common.sh

SRCDIR=${BASE}/source/freebsd-master

#
# FreeBSD source
#
for branch in ${FREEBSD_BRANCHES}
do
	branch_file=$(echo ${branch} | sed 's/\//_/')
	echo "Updating FreeBSD: ${branch}"
	cd ${BASE}/source/freebsd-${branch_file}	
	git pull || exit 1
done

#
# DRM source
#
for branch in ${DRM_BRANCHES}
do
	echo "Updating DRM: ${branch}"
	cd ${BASE}/source/${branch}
	git pull || exit 1
done

#
# DRM legacy source
#
echo "Updating DRM: drm-legacy"
cd ${BASE}/source/drm-legacy || exit 1
git pull || exit 1


#
# Update toolchains
#

# Disabled... Let toolchains be managed manually by host?

#pkg update
#pkg install -y devel/powerpc64-xtoolchain-gcc || exit 1

# XXX: Need to build default and i386 toolchains?
#cd ${SRCDIR} || exit 1
#make -s -j${NCPU} kernel-toolchain MAKEOBJDIRPREFIX=${OBJDIRPREFIX} NO_CLEAN=1 || exit 1
#make -s -j${NCPU} kernel-toolchain TARGET_ARCH=i386 MAKEOBJDIRPREFIX=${OBJDIRPREFIX} NO_CLEAN=1 || exit 1
#make -s -j${NCPU} kernel-toolchain TARGET_ARCH=aarch64 MAKEOBJDIRPREFIX=${OBJDIRPREFIX} NO_CLEAN=1 || exit 1

exit 0
