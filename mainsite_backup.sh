#!/bin/bash
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

#Call external PHP script to read wp-config.php and evaluate as bash variables
eval_wp-config() {
    #Use a function, since for some reason assigning to a function-local variable is the only way to get the return code from a subshell
    local configDump 
    set +o errexit
    set -x
    #config_dump.php reads wp-config.php and prints the wordpress DB connection PHP constants as shell variables.
    configDump=$( php "${SCRIPT_PATH}/config_dump.php" "${SCRIPT_PATH}/${SCFG_PATH_TO_WP_ROOT}" )
    PHP_RC="$?"
    set +x
    set -o errexit
    if [ ! "$PHP_RC" -eq 0 ]; then
        echo "PHP config dump tool failed with error: $configDump"
        exit "$PHP_RC"
    fi
    #read bash-reformatted wordpress config in as variables (they all start with DB_ prefix)
    eval "$configDump"
}
eval_wp-config

TIMESTAMP=`date "+%y%m%d_%H%M%s"`
DESTFILE="${HOME}backup/mainsite.sql.$TIMESTAMP.gz"

#Make 3 a descriptor to DESTFILE:
exec 3>${DESTFILE}

set -x
mysqldump --add-drop-table -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" | gzip >&3
set +x
echo "=====Wordpress database backup complete to $DESTFILE"
