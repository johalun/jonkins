#!/bin/sh

echo
echo ">> run.sh"
echo

BASE=$(dirname $(realpath $0))
cd ${BASE}
. ./common.sh

SRCDIR=${BASE}/source/freebsd-master

mkdir -p ${LOGDIR} || exit 1
rm -f ${LOGDIR}/* || exit 1

SUCCESS=""
FAIL=""

dobuild()
{
	local target=$1
	local target_noslash=$(echo ${target} | sed 's/\//_/')

	local arch=`echo ${target_noslash} | awk -F'__' '{print $1}'`
	local freebsd=`echo ${target_noslash} | awk -F'__' '{print $2}'`
	local drm=`echo ${target_noslash} | awk -F'__' '{print $3}'`
	local sysdir="${BASE}/source/freebsd-${freebsd}/sys"
	local options="SYSDIR=${sysdir}"

	if [ "${arch}" == "powerpc64" ]; then
		options="${options} CROSS_TOOLCHAIN=powerpc64-gcc"
	fi

	CMD="/bin/sh -c 'cd ${BASE}/source/${drm}; make -s -j${NCPU} > ${LOGDIR}/${target_noslash}.log'"

	echo
	echo "Building:"
	echo "ARCH='${arch}'"
	echo "FREEBSD='${freebsd}'"
	echo "DRM='${drm}'"
	echo "OPTIONS='${options}'"
	echo "CMD='${CMD}'"
	echo
	
	(cd ${SRCDIR} && make buildenv MAKEOBJDIRPREFIX=${OBJDIRPREFIX}-${arch}-${freebsd}  \
		TARGET_ARCH=${arch} ${options} BUILDENV_SHELL="${CMD}") && \
		SUCCESS="${SUCCESS} ${target_noslash}" || FAIL="${FAIL} ${target_noslash}"
}

for target in ${TARGETS}
do
	dobuild ${target}
done

cd ${BASE}

echo
echo "SUCCESS:"
for e in ${SUCCESS}
do
	echo ${e}
	mv ${LOGDIR}/${e}.log ${LOGDIR}/OK-${e}.log
done

echo
echo "FAIL:"
for e in ${FAIL}
do
	echo "${e}"
	mv ${LOGDIR}/${e}.log ${LOGDIR}/ERROR-${e}.log
done

exit 0
