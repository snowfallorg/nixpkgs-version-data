#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 [nixpkgs revision]"
    exit 1
fi

NIXPKGS=$(nix eval nixpkgs/$1#path)
NIXPKGS_ALLOW_UNFREE=1 \
NIXPKGS_ALLOW_INSECURE=1 \
NIXPKGS_ALLOW_BROKEN=1 \
nix-instantiate --eval -E "with import $NIXPKGS {}; builtins.listToAttrs (builtins.filter (pkg: pkg.value != \"N/A\") (map (name: { name = name; value = (
    if (builtins.tryEval (pkgs.\"\${name}\")).success
      then (if (lib.isDerivation (builtins.tryEval (pkgs.\"\${name}\")).value)
        then (if (lib.hasAttr \"version\"  (builtins.tryEval (pkgs.\"\${name}\")).value)
          then ((builtins.tryEval (pkgs.\"\${name}\")).value.version)
        else (
          if ((builtins.tryEval (pkgs.lib.getVersion pkgs.\"\${name}\")).success)
          then ((builtins.tryEval (pkgs.lib.getVersion pkgs.\"\${name}\")).value)
          else (\"N/A\")
        ))
      else (\"N/A\"))
    else \"N/A\"); }) (lib.attrNames pkgs)))" --strict --json --impure | jq 'del(.[] | nulls)' > $1.json
brotli ./$1.json
rm $1.json
