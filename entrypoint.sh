#!/bin/sh -l

# https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-docker-container-action#accessing-files-created-by-a-container-action

# import GPG key
gpg --batch --import "/github/workspace/${GPG_KEY_VAR}"

# find all files
find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
    gpg --pinentry-mode=loopback --passphrase "$1" --armor --detach-sign hosts
done
