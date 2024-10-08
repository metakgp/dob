#!/usr/bin/env python3

import dropbox
import os
import traceback
import sys
import datetime

app_key = os.environ["DROPBOX_APP_KEY"]
app_secret = os.environ["DROPBOX_APP_SECRET"]
access_token = os.environ["DROPBOX_ACCESS_TOKEN"]
refresh_token = os.environ["DROPBOX_REFRESH_TOKEN"]
client = dropbox.Dropbox(
    app_key=app_key,
    app_secret=app_secret,
    oauth2_access_token=access_token,
    oauth2_refresh_token=refresh_token,
)

BACKUP_FOLDER_PATH = ""
has_more_files = True
cursor = None
result = None
files = []
now = datetime.datetime.now()
counter = 0

try:
    print("Fetching files from Dropbox...")
    while has_more_files:
        if cursor is None:
            result = client.files_list_folder(BACKUP_FOLDER_PATH)
        else:
            result = client.files_list_folder_continue(cursor=cursor)
        cursor = result.cursor

        for file in result.entries:
            if file.name.find("dob_dump") == 0:
                files.append(file)

        has_more_files = result.has_more

    number_of_files = len(files)
    print(f"{number_of_files} backup files found.")

    print("Starting rotation")
    for file in files:
        file_timestamp = file.client_modified
        days_old = (now - file_timestamp).days
        if days_old > 30 and (number_of_files - counter) > 30:
            client.files_delete(file.path_display)
            counter += 1

    print(f"{counter} backup file(s) successfully deleted.")
except Exception as e:
    sys.exit(traceback.format_exc())
