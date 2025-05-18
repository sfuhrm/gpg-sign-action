#!/bin/sh -l

DEBUG=1
debug()
{
    if [ $DEBUG -eq 1 ]; then
        echo $@
    fi
}

# https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-docker-container-action#accessing-files-created-by-a-container-action

# start GPG agent
debug "Starting agent"
gpg-agent --daemon --batch --disable-scdaemon

# check and import GPG key
debug "Import key"
echo "${GPG_KEY_VAR}"  | gpg --batch --no-tty --import
debug "Imported key"

KEYID=$(gpg --list-secret-keys | grep -A1 -E "^sec "|tail -n 1)
debug "Secret key ID: $KEYID"

PUBKEYLINES=$(gpg --list-keys|grep -c -E "^pub ")
debug "Pubkeys: $PUBKEYLINES"
if [ $PUBKEYLINES -eq 0 ]; then
    echo "The GPG import failed, expected at least 1, but got ${PUBKEYLINES} pubkeys."
    echo "Please ensure that the GPG key you passed is valid."
    exit 2
fi

# find all files
find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
    debug "Signing file: $file"
    gpg --batch --no-tty --pinentry-mode=loopback --local-user $KEYID --passphrase "$1" --armor --detach-sign "$file"
    EXITCODE=$?
    if [ $EXITCODE -ne 0 ]; then
        echo "GPG detach sign of file failed with exitcode $EXITCODE for: $file"
    fi
done

# stop GPG agent
killall gpg-agent

# remove GPG dir from container
rm -fr ~/.gnupg
