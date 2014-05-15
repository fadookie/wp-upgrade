<?
/**
 * Reads wp-config.php and prints the wordpress DB connection PHP constants as shell variables.
 * Intended for use to inject these config variables into shell scripts.
 * Expects one argument: absolute path to wordpress installation root directory.
 */

$PATH_TO_WP_ROOT = (isset($argv[1])) ? $argv[1] : null;

if ($argc !== 2 || empty($PATH_TO_WP_ROOT)) {
    echo 'No root path provided.';
    exit(1);
}

//Load constants from wp-config.php
require_once(realpath("$PATH_TO_WP_ROOT") . '/wp-config.php');

echo 'DB_NAME="' . DB_NAME . '";';
echo 'DB_USER="' . DB_USER . '";';
echo 'DB_PASSWORD="' . DB_PASSWORD . '";';
echo 'DB_HOST="' . DB_HOST . '";';
