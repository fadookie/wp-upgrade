#Relative path from this script to wordpress root (containing wp-config.php, etc.)
SCFG_PATH_TO_WP_ROOT=".."

set -o nounset #disallow unset vars
set -o errexit #strict error checking
set -o pipefail #commands in pipes can cause fatal errors
