#!/bin/sh -l -e

# https://docs.github.com/en/actions/sharing-automations/creating-actions/creating-a-docker-container-action#accessing-files-created-by-a-container-action

# start GPG agent
gpg-agent --daemon --batch --disable-scdaemon

# check and import GPG key
KEY=/tmp/gpgkey

echo "${GPG_KEY_VAR}" > $KEY

grep "BEGIN PGP PRIVATE KEY BLOCK-----" $KEY || echo "Key needs to begin with: -----BEGIN PGP PRIVATE KEY BLOCK-----" >&2; exit 2)
grep "END PGP PRIVATE KEY BLOCK-----" $KEY || (echo "Key needs to end with: -----END PGP PRIVATE KEY BLOCK-----" >&2; exit 2)

chmod 0700 $KEY
gpg --batch --import $KEY
rm -f $KEY

# find all files
find "/github/workspace/${INPUT_PATH_VAR}" -type f | while read file; do
    gpg --pinentry-mode=loopback --passphrase "$1" --armor --detach-sign "$file"
done

# stop GPG agent
killall gpg-agent

# remove GPG dir from container
rm -fr ~/.gnupg
