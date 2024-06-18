#!/usr/bin/env bash

echo "-- Database of Babel Backup START --"

timestamp=$(date +%Y_%m_%d_%H_%M_%S)
backup_to_dropbox="python3 /root/backup/backup_to_dropbox.py"
backups_dir="/root/backup/backups"
dump_file="dob_dump_$timestamp.sql"
backup_file="$dump_file.gz"

mkdir -p "${backups_dir}"
cd "$backups_dir"

if ! pg_dumpall -U $POSTGRES_USER --no-password >$dump_file; then
	echo "pgdump failure!"
	exit 1
fi

gzip $dump_file

# Backup to Dropbox
if ! $backup_to_dropbox $backup_file; then
	echo "Dropbox backup failure!"
	# Notify Slack
	if [[ -n "$SLACK_INCIDENTS_WH_URL" ]]; then
		curl -s -H 'content-type: application/json' \
			-d "{ \"text\": \"🔴DoB Dropbox backup failure\nCould not upload \`${backup_file}\`.\" }" \
			"$SLACK_INCIDENTS_WH_URL"
	fi
	exit 1
fi

# Delete local backups older than one week
for file in ./*.gz; do
	if [ $(($(date +%s) - $(date -r $file +%s))) -gt 604800 ]; then
		rm "$file"
	fi
done

echo "-- Database of Babel Backup END --"