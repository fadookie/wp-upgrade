# wp-upgrade
Git-based upgrade toolchain for wordpress.

## Setup
 1. Have a git-based wordpress site (see below for instructions.)
 1. Clone this repo. I'd advise putting it outside of your webserver's document root for security purposes. Your user's home directory would probably be an okay place, unless you're on a dumb host that puts that inside the document root.
 1. Copy `shared_config.sh.sample` to `shared_config.sh`.
 1. Edit `shared_config.sh` and update the **User settings** to match your environment and preferences.

## Setup git-based wordpress
 1. Clone the wordpress git mirror. I use the older https://github.com/WordPress/WordPress, but you should be able to use the newer official one at `git://core.git.wordpress.org/`
 1. cd into the clone
 1. `git fetch --tags`
 1. `git tag` to see the tags. The latest stable version should be the highest version number in a tag, I'll call this `<current-wordpress-version>`.
 1. `git checkout -b mainsite/<current-wordpress-version>` (I use `mainsite/` as a prefix for my wordpress site branches, and it's followed by the version that my changes are based off of.)
 1. `git reset --hard refs/remotes/origin/<current-wordpress-version>` (This points the branch you just made at `<current-wordpress-version>`.)
 1. `git remote rename origin wordpress`
 1. Set up a git remote for backup purposes.
 1. `git remote add origin <url-of-remote>`
 1. Copy your wp-content over the one in the new clone.
 1. Create a `.gitignore` file to ignore stuff like caches, log files, temp files, etc. that shouldn't be in version control. You could try [this one](https://github.com/github/gitignore/blob/master/WordPress.gitignore).
 1. Commit your changes and push them to your backup remote:
   1. `git add -A .`
   1. `git commit`
   1. `git push -u origin mainsite/<current-wordpress-version>`

## Backing up your changes
When you make changes to your site code (adding plugins, modifying themes, etc.) back them up using `git add`, `git commit`, and `git push` to back them up to your remote.

## Upgrading wordpress via git
When a new release of Wordpress comes out, run `upgrade_wp_via_git.sh <old-wordpress-version> <new-wordpress-version>` and follow the prompts. If you don't type "y" at any prompt, the script will stop.

The script will back up your database, then perform a rebase of all of your commits onto the new wordpress version. If you have been doing your modifications properly (via plugins and themes rather than hacking the wordpress source code directly) you shouldn't get any conflicts. If you want to modify an existing theme, You may want to use a [child theme](http://codex.wordpress.org/Child_Themes) to make upgrading it in the future easier.

Once the upgrade is done, log in to your wordpress admin panel to check if a database upgrade is needed and execute it.
If you wish, you can also make another database backup at this point by running `wp_db_backup.sh`.

## Legal
Copyright (c) 2014 Eliot Lash.

This software is available for use under an MIT-style license, see [LICENSE.txt](/LICENSE.txt) for full details.
