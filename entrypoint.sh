#!/bin/sh -le

DEBUG=1

# https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-docker-container-action#accessing-files-created-by-a-container-action

# start GPG agent
[ $DEBUG == 1] || echo "Starting agent"
gpg-agent --daemon --batch --disable-scdaemon

[ $DEBUG == 1] || echo "Counting blocklines"
BLOCKLINES=$(echo "${GPG_KEY_VAR}" | grep -c "PRIVATE KEY BLOCK")
[ $DEBUG == 1] || echo "Blocklines: $BLOCKLINES"

if [ $BLOCKLINES != "2" ]; then
    echo "The GPG key does not contain two PRIVATE KEY BLOCk markers, but ${BLOCKLINES}."
    echo "Please ensure your key is in ASCII ARMOR (--armor) format."
    exit 1
fi

# check and import GPG key
[ $DEBUG == 1] || echo "Import key"
echo "${GPG_KEY_VAR}"  | gpg --batch --import
[ $DEBUG == 1] || echo "Imported key"

PUBKEYLINES=$(gpg --list-keys|grep -c -E "^pub")
[ $DEBUG == 1] || echo "Pubkeys: $PUBKEYLINES"
if [ $PUBKEYLINES == "0" ]; then
    echo "The GPG import failed, expected at least 1, but got ${PUBKEYLINES} pubkeys."
    exit 2
fi

# find all files
find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
    [ $DEBUG == 1] || echo "Signing file: $file"
    gpg --pinentry-mode=loopback --passphrase "$1" --armor --detach-sign "$file"
done

# stop GPG agent
killall gpg-agent

# remove GPG dir from container
rm -fr ~/.gnupg
