# gpg sign action

[![Docker Image CI](https://github.com/sfuhrm/gpg-sign-action/actions/workflows/docker-image.yml/badge.svg)](https://github.com/sfuhrm/gpg-sign-action/actions/workflows/docker-image.yml)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This action detach-signs files in a path using GPG (GNU Privacy Guard) in a filesystem path.
As a result you'll get `.asc` signatures in your path for every file. 

## Inputs

## `gpg-key`

**Required** The *private* asymmetric GPG key to sign the files with.
Typically has the form

```
-----BEGIN PGP PRIVATE KEY BLOCK-----
...
-----END PGP PRIVATE KEY BLOCK-----
```

This key should be stored in a *secret* variable.

## `gpg-passphrase`

**Required** The passphrase to unlock the `gpg-key`.

This key should be stored in a *secret* variable.

## `path`

**Required** The filesystem path where to gpg-sign the files.
Note that this path must be in your github working directory.

## Example usage

```
uses: sfuhrm/gpg-sign-action@main
with:
    path: my-file-path
    gpg-key: "${{ secrets.GPG_KEYFILE }}"
    gpg-passphrase: "${{ secrets.GPG_PASSPHRASE }}"
```
