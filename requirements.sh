#!/bin/sh

if ! [ -x /usr/local/bin/brew ]; then
  echo "Install homebrew first"
  exit 1
fi

brew install ansible direnv ipcalc jq kubectl pinentry \
  sops terraform prettier kustomize \
  go-task/tap/go-task fluxcd/tap/flux

#Use gpg keychain because I'm lame like that
brew install --cask gpg-suite-no-mail