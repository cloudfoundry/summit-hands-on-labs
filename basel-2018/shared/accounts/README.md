## Managing student sessions
To automate student account interactions we need to prepare a sqlite database with active login sessions.
Since the login flow uses a browser and can't be scripted.

### Login to all accounts
First use the `accounts/login.sh` which will use the `gcloud` cli to open a browser to login.
The password is `training` and on OSX `pbcopy` is used to copy the email address to the clipboard.
So just past the email in the form and enter the password.

### List active sessions
To to list active sessions the `gcloud` cli knows about use `accounts/sessions.sh`.

### Dump sessions
These active sessions can be exported using `accounts/dump.sh` (uses pbcopy).
To use in concourse use a secret gist and use like this:
```
config_path=$(gcloud info --format json | jq -r '.config.paths.global_config_dir')
curl ${ACCOUNT_SESSIONS_URL} | sqlite3 ${config_path}/credentials.db
```
