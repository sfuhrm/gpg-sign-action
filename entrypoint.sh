#!/bin/sh -l

# exit code file for passing codes from subshell
export EXITCODE_FILE=/tmp/exitcode.$$
echo 0 > $EXITCODE_FILE
DEBUG=1
debug()
{
    if [ $DEBUG -eq 1 ]; then
        echo $@
    fi
}

cleanup()
{
    # stop GPG agent
    killall gpg-agent

    # remove GPG dir from container
    rm -fr ~/.gnupg
}


# https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-docker-container-action#accessing-files-created-by-a-container-action

# start GPG agent
debug "Starting agent"
gpg-agent --daemon --disable-scdaemon

# import GPG key
debug "Import key"
echo "${GPG_KEY_VAR}"  | gpg --batch --no-tty --import
debug "Imported key"

SECKEYLINES=$(gpg --list-secret-keys | grep -c -E "^sec ")
debug "Seckeys: $SECKEYLINES"
if [ "$SECKEYLINES" -gt 0 ]; then
    # find all files
    find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
        debug "Signing file: $file"
        gpg --batch --no-tty --pinentry-mode=loopback --passphrase "$1" --armor --detach-sign "$file"

        EXITCODE=$?
        if [ $EXITCODE -ne 0 ]; then
            echo $EXITCODE > $EXITCODE_FILE
            echo "❌ GPG detach sign of file failed with exitcode $EXITCODE for: $file"
            echo "   Passphrase length was: $(echo -n $1 | wc -c) chars"
            echo "   Keyfile length was:    $(echo -n $GPG_KEY_VAR | wc -c) chars"
            break
        fi
    done
else
    echo "❌ The GPG import failed, expected at least 1, but got ${SECKEYLINES} seckeys."
    echo "   Keyfile length was:    $(echo -n $GPG_KEY_VAR | wc -c) chars"
    echo "   Please ensure that the GPG key you passed is valid."
    echo 5 > $EXITCODE_FILE
fi

cleanup

EXITCODE=$(cat $EXITCODE_FILE)
if [ $EXITCODE -eq 0 ]; then
    echo "✅ Success"
else
    echo "❌ Failure exit code $EXITCODE"
fi

exit $EXITCODE