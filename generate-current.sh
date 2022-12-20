#!/usr/bin/env bash
for Line in $(cat versions)
do
    mkdir -p $Line
    cd $Line
    if [[ -f "git-revision" ]]; then
        rm git-revision
    fi
    wget "https://channels.nixos.org/${Line}/git-revision"
    version=$(cat git-revision)
    if [[ ! -f "${version}.json.br" ]]; then
        ../versions.sh $version
    fi
    rm git-revision
    cd ..
done
