#!/bin/bash
# Database backup helper for upgrade_wp_via_git.sh. Can be run standalone to make a DB backup.
#
# Copyright (c) 2014 Eliot Lash.
# This software is available for use under an MIT-style license, see LICENSE.txt for full details.

#disallow unset vars
set -o nounset
#strict error checking
set -o errexit
#commands in pipes can cause fatal errors
set -o pipefail

#Jump through an astounding number of hoops to get the canonical path to this script
SCRIPT_PATH="${BASH_SOURCE[0]}";
if ([ -h "${SCRIPT_PATH}" ]) then
  while([ -h "${SCRIPT_PATH}" ]) do SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
pushd . > /dev/null
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

#Source shared config
source "${SCRIPT_PATH}/shared_config.sh"

#cd to wordpress root
set -x
cd -P "${SCFG_PATH_TO_WP_ROOT}"
set +x

set -x
chown "${SCFG_CHOWN_OWNER}" "${SCFG_PATH_TO_WP_ROOT}/${SCFG_CHOWN_DIR}"
find . -type d -exec chmod g+x {} +
set +x
