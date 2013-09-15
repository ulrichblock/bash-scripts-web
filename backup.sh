#!/bin/bash

#  Author Ulrich Block
#  Contact: www.ulrich-block.de
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# Login data
mysqlRootPassword='SecureMysqlPassword'
backupDir='/root/backups'
ftpAddress='127.0.0.1'
ftpPassword='SecureFTPPassowrd'
ftpPort='21'
ftpUser='YourFTPUser'

# Define the web spaces and their database. If no DB exists, leave value blank.
declare -A backup
backup[mydomain.tld]='theDatabaseName'
backup[sub.domain.tld]=''
backup[mydomain2.tld]='theDatabaseName2'


for key in ${!backup[@]}; do
	if [ ! -d "$backupDir/$key/" ]; then
		mkdir -p "$backupDir/$key/"
	fi
	if [ -f "$backupDir/$key/files.tar.gz" ]; then
		mkdir -p "$backupDir/$key/`date +'%Y-%m-%d'`/"
		mv "$backupDir/$key/files.tar.gz"  "$backupDir/$key/`date +'%Y-%m-%d'`/"
		if [ -f "$backupDir/$key/backup.sql.gz" ]; then
			mv "$backupDir/$key/backup.sql.gz"  "$backupDir/$key/`date +'%Y-%m-%d'`/"
		fi
	fi
	if [ -d "/var/www/$key/htdocs/" ]; then
		cd "/var/www/$key/htdocs/"
		tar cfvz "$backupDir/$key/files.tar.gz" . &> /dev/null
		wput -q -o /dev/null --basename="$backupDir/$key" "$backupDir/$key/files.tar.gz" "ftp://$ftpUser:$ftpPassword@$ftpAddress:$ftpPort/$key/`date +'%Y-%m-%d'`/files.tar.gz"
	fi
	if [ "${backup[$key]}" != "" ]; then
		mysqldump -u root -h localhost -p$mysqlRootPassword --databases "${backup[$key]}" | gzip -9 > "$backupDir/$key/backup.sql.gz"
		wput -q -o /dev/null --basename="$backupDir/$key" "$backupDir/$key/backup.sql.gz" "ftp://$ftpUser:$ftpPassword@$ftpAddress:$ftpPort/$key/`date +'%Y-%m-%d'`/backup.sql.gz"
	fi
done