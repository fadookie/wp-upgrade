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
    local PROMPT_PREFIX="$1"
    #$2/cmdArray is a bash array of strings that will be safely expanded into the resulting command
    local cmdArray=("${!2}")
    local readPrompt="${PROMPT_PREFIX} via '${cmdArray[@]}'? [yn]"
    read -p "${readPrompt}" answer
    if [[ ! $answer = y ]] ; then
        halt
    fi
    set -x
    "${cmdArray[@]}"
    set +x
}

CMD=( "${SCRIPT_PATH}/wp_db_backup.sh" )
confirmAndPerform "Back up DB" CMD[@]

set -x
git fetch --tag --unshallow "${SCFG_REMOTE_NAME}" "${NEWVERSION}"
set +x

CMD=( git rebase --onto "${NEWVERSION}" "${OLDVERSION}" HEAD ) 
confirmAndPerform "Rebase" CMD[@]

# You will now be in a "detached head" state.

NEWBRANCH="${SCFG_BRANCH_PREFIX}${NEWVERSION}"

CMD=( git co -b "${NEWBRANCH}" )
confirmAndPerform "Make branch" CMD[@]

CMD=( chown "${SCFG_CHOWN_OWNER}" "${SCFG_PATH_TO_WP_ROOT}/${SCFG_CHOWN_DIR}" )
confirmAndPerform "Change file ownership" CMD[@]

# Log in to admin, run DB upgrade script

CMD=( git push -u origin "${NEWBRANCH}" )
confirmAndPerform "Push to git remote" CMD[@]

CMD=( git gc )
confirmAndPerform "Cleanup" CMD[@]
