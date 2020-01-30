#!/bin/sh

BASE=$(dirname $(realpath $0))
cd ${BASE}
. ./common.sh

/bin/sh ${BASE}/update.sh > ${SCRIPTLOG} 2>&1 || (echo "Update failed"; exit 1)
/bin/sh ${BASE}/run.sh >> ${SCRIPTLOG} 2>&1 || (echo "Run failed"; exit 1)

if [ -e "${BASE}/report.sh" ]
then
	/bin/sh ${BASE}/report.sh >> ${SCRIPTLOG} 2>&1 || (echo "Report failed"; exit 1)
fi

exit 0
