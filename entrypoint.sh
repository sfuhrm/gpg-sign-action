#!/bin/sh -le

# https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-docker-container-action#accessing-files-created-by-a-container-action

# start GPG agent
gpg-agent --daemon --batch --disable-scdaemon

# check and import GPG key
echo "${GPG_KEY_VAR}"  | gpg --batch --import

# find all files
find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
    gpg --pinentry-mode=loopback --passphrase "$1" --armor --detach-sign "$file"
done

# stop GPG agent
killall gpg-agent

# remove GPG dir from container
rm -fr ~/.gnupg
