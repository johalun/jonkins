#!/bin/sh

echo
echo ">> report.sh"
echo

BASE=$(dirname $(realpath $0))
cd ${BASE}
. ./common.sh

FREEFALL_USER=username-here

NOW=`date`
HTML=${DSTDIR}/log.html
EMAILBODY=${DSTDIR}/email.txt
HAVE_FAILS=false

HEAD_DIR=${BASE}/source/freebsd-master
STABLE11_DIR=${BASE}/source/freebsd-stable_11
STABLE12_DIR=${BASE}/source/freebsd-stable_12

HEAD_REV=`cd ${HEAD_DIR} && git log -n1 | grep "svn path" | cut -d'=' -f3`
HEAD_VER=`awk '/^\#define[[:blank:]]__FreeBSD_version/ {print $3}' < ${HEAD_DIR}/sys/sys/param.h`

STABLE11_REV=`cd ${STABLE11_DIR} && git log -n1 | grep "svn path" | cut -d'=' -f3`
STABLE11_VER=`awk '/^\#define[[:blank:]]__FreeBSD_version/ {print $3}' < ${STABLE11_DIR}/sys/sys/param.h`

STABLE12_REV=`cd ${STABLE12_DIR} && git log -n1 | grep "svn path" | cut -d'=' -f3`
STABLE12_VER=`awk '/^\#define[[:blank:]]__FreeBSD_version/ {print $3}' < ${STABLE12_DIR}/sys/sys/param.h`


cat <<'EOF' >${HTML} || exit 1
<!DOCTYPE html>
<html>
<style>
  * {
      font-family: monospace;
    }
</style>
<head>
  <title>FreeBSD DRM Drivers Build Results</title>
</head>
<body>
  <h1>FreeBSD DRM Drivers Build Results</h1>
  <h2>Versions</h2>
EOF

echo "<p style='font-weight=bold'>STABLE-11: Version ${STABLE11_VER}. Revision ${STABLE11_REV}.</p>" >> ${HTML}
echo "<p style='font-weight=bold'>STABLE-12: Version ${STABLE12_VER}. Revision ${STABLE12_REV}.</p>" >> ${HTML}
echo "<p style='font-weight=bold'>HEAD:      Version ${HEAD_VER}. Revision ${HEAD_REV}.</p>" >> ${HTML}

echo "  <h2>Failed</h2>" >>${HTML}
for log in `ls ${LOGDIR} | grep ERROR-`
do
	name=$(echo ${log} | sed 's/ERROR-//')
	echo "  <p>${NOW} <a href='${log}'>${name}</a></p>" >> ${HTML}
	HAVE_FAILS=true
done

echo "  <h2>Success</h2>" >>${HTML}
for log in `ls ${LOGDIR} | grep OK-`
do
	name=$(echo ${log} | sed 's/OK-//')
	echo "  <p>${NOW} <a href='${log}'>${name}</a></p>" >> ${HTML}
done

cat <<'EOF' >>${HTML} 
</body>
</html>
EOF

echo "Uploading ${HTML}"
scp ${HTML} ${FREEFALL_USER}@freefall.freebsd.org:/home/${FREEFALL_USER}/public_html/drmlogs/index.html || exit 1

echo
for file in `ls ${LOGDIR}`
do
	echo "Uploading ${file}"
	scp ${LOGDIR}/${file} ${FREEFALL_USER}@freefall.freebsd.org:/home/${FREEFALL_USER}/public_html/drmlogs/ || exit 1
done


if [ "${HAVE_FAILS}" == "true" ]
then
	echo
	echo "Sending report email"
	echo "FreeBSD DRM Drivers Build Results" > ${EMAILBODY} || exit 1
	echo "" >> ${EMAILBODY}
	echo "STABLE-11: Version ${STABLE11_VER}. Revision ${STABLE11_REV}." >> ${EMAILBODY}
	echo "STABLE-12: Version ${STABLE12_VER}. Revision ${STABLE12_REV}." >> ${EMAILBODY}
	echo "HEAD:      Version ${HEAD_VER}. Revision ${HEAD_REV}." >> ${EMAILBODY}
	echo "" >> ${EMAILBODY}
	echo "" >> ${EMAILBODY}
	echo "Failed on ${NOW}:" >>${EMAILBODY}
	echo "" >> ${EMAILBODY}
	for log in `ls ${LOGDIR} | grep ERROR-`
	do
		echo "https://people.freebsd.org/~${FREEFALL_USER}/drmlogs/${log}" >> ${EMAILBODY}
	done
	echo "" >> ${EMAILBODY}
	echo "" >> ${EMAILBODY}
	echo "Full report here: https://people.freebsd.org/~${FREEFALL_USER}/drmlogs" >> ${EMAILBODY}

	mail -s "DRM driver build fail" x11@freebsd.org < ${EMAILBODY}
fi

exit 0
