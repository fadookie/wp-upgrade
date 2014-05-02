#!/bin/sh
set -e #strict error checking
set -u #disallow unset vars
TIMESTAMP=`date "+%y%m%d_%H%M%s"`
DESTFILE="${HOME}backup/mainsite.sql.$TIMESTAMP.gz"
#Make 3 a descriptor to DESTFILE:
exec 3>${DESTFILE}

set -x
mysqldump --add-drop-table -h HOSTNAME -u USERNAME -pPASSWORD DATABASE | gzip >&3
set +x
echo "=====Wordpress database backup complete to $DESTFILE"
