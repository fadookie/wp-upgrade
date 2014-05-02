#!/bin/bash
# run from wordpress site root:
# eliotbin/upgrade_wp_via_git.sh OLDVERSION NEWVERSION
set -o nounset
set -o errexit

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
    read -p "$PROMPT_PREFIX via '$CMD'? [yn]" answer
    if [[ ! $answer = y ]] ; then
        halt
    fi
    set -x
    $CMD
    set +x
}


confirmAndPerform "Back up DB" "eliotbin/mainsite_backup.sh"

set -x
git fetch wordpress --tags
set +x

confirmAndPerform "Rebase" "git rebase --onto $NEWVERSION $OLDVERSION HEAD"

# You will now be in a "detached head" state.

NEWBRANCH="mainsite/${NEWVERSION}"

confirmAndPerform "Make branch" "git co -b $NEWBRANCH"

set -x
chown :web wp-content/uploads/
set +x

# Log in to admin, run DB upgrade script

confirmAndPerform "Push to github" "git push -u origin $NEWBRANCH"

confirmAndPerform "Cleanup" "git gc"
