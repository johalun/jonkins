#!/bin/sh

#
# Shared variables
#
DSTDIR=/tmp/jonkins
OBJDIRPREFIX=${DSTDIR}/build
LOGDIR=${DSTDIR}/log
SCRIPTLOG=${DSTDIR}/jonkins.log

mkdir -p ${DSTDIR}

NCPU=`sysctl -n hw.ncpu`

FREEBSD_BRANCHES="stable/11 stable/12 release/11.3.0 release/12.0.0 releng/12.1 master"
DRM_BRANCHES="drm-v4.11-fbsd11.2 drm-v4.16-fbsd12.0 drm-v5.0-fbsd12.1 drm-v4.16 drm-v5.0"
DRM_LEGACY="drm-legacy/master"

TARGETS="amd64__stable/11__drm-v4.11-fbsd11.2 \
       amd64__release/11.3.0__drm-v4.11-fbsd11.2 \
       amd64__release/12.0.0__drm-v4.16-fbsd12.0 \
       amd64__stable/12__drm-v4.16-fbsd12.0 \
       amd64__stable/12__drm-v5.0-fbsd12.1 \
       amd64__releng/12.1__drm-v4.16-fbsd12.0 \
       amd64__releng/12.1__drm-v5.0-fbsd12.1 \
       amd64__master__drm-v4.16 \
       amd64__master__drm-v5.0 \
       amd64__master__drm-legacy \
       i386__release/12.0.0__drm-v4.16-fbsd12.0 \
       i386__stable/12__drm-v5.0-fbsd12.1 \
       i386__stable/12__drm-v4.16-fbsd12.0 \
       i386__releng/12.1__drm-v4.16-fbsd12.0 \
       i386__releng/12.1__drm-v5.0-fbsd12.1 \
       i386__master__drm-v4.16 \
       i386__master__drm-v5.0 \
       i386__master__drm-legacy \
       aarch64__master__drm-v5.0 \
       powerpc64__master__drm-v5.0"
