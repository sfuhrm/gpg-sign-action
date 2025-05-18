#!/bin/sh -le


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

debug "GPG key lines: $(echo $GPG_KEY_VAR | wc -l)"
debug "Counting blocklines"
BLOCKLINES=$(echo "${GPG_KEY_VAR}" | grep -c "PRIVATE KEY BLOCK")
debug "Blocklines: $BLOCKLINES"

if [ $BLOCKLINES -ne 2 ]; then
    echo "The GPG key does not contain two PRIVATE KEY BLOCk markers, but ${BLOCKLINES}."
    echo "Please ensure your key is in ASCII ARMOR (--armor) format."
    exit 1
fi

# check and import GPG key
debug "Import key"
echo "${GPG_KEY_VAR}"  | gpg --batch --import
debug "Imported key"

PUBKEYLINES=$(gpg --list-keys|grep -c -E "^pub")
debug "Pubkeys: $PUBKEYLINES"
if [ $PUBKEYLINES -eq 0 ]; then
    echo "The GPG import failed, expected at least 1, but got ${PUBKEYLINES} pubkeys."
    exit 2
fi

# find all files
find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
    debug "Signing file: $file"
    gpg --pinentry-mode=loopback --passphrase "$1" --armor --detach-sign "$file"
done

# stop GPG agent
killall gpg-agent

# remove GPG dir from container
rm -fr ~/.gnupg
