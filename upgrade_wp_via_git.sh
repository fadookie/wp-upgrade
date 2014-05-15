#!/bin/bash
# First, set path to wordpress site root in shared_config.sh.
# then run like so: PATH/TO/upgrade_wp_via_git.sh OLDVERSION NEWVERSION
#
# Copyright (c) 2014 Eliot Lash.
# This software is available for use under an MIT-style license, see LICENSE.txt for full details.

set -o nounset #disallow unset vars
set -o errexit #strict error checking
set -o pipefail #commands in pipes can cause fatal errors

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
cd "${SCFG_PATH_TO_WP_ROOT}"
set +x

set -x
OLDVERSION="$1"
NEWVERSION="$2"
set +x

function halt {
    echo "Stopping."
    exit 1
}

function confirmAndPerform {
    PROMPT_PREFIX="$1"
    CMD="$2"
    read -p "${PROMPT_PREFIX} via '${CMD}'? [yn]" answer
    if [[ ! $answer = y ]] ; then
        halt
    fi
    set -x
    $CMD
    set +x
}


confirmAndPerform "Back up DB" "${SCRIPT_PATH}/wp_db_backup.sh"

set -x
git fetch wordpress --tags
set +x

confirmAndPerform "Rebase" "git rebase --onto ${NEWVERSION} ${OLDVERSION} HEAD"

# You will now be in a "detached head" state.

NEWBRANCH="${SCFG_BRANCH_PREFIX}${NEWVERSION}"

confirmAndPerform "Make branch" "git co -b ${NEWBRANCH}"

set -x
chown "${SCFG_CHOWN_WEB}" wp-content/uploads/
set +x

# Log in to admin, run DB upgrade script

confirmAndPerform "Push to github" "git push -u origin ${NEWBRANCH}"

confirmAndPerform "Cleanup" "git gc"
