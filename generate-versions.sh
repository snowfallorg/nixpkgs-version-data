#!/usr/bin/env bash
for Line in $(cat versions)
do
    mkdir -p $Line
    cd $Line
    if [[ -f "history" ]]; then
        rm history
    fi
    wget "https://raw.githubusercontent.com/grahamc/nix-channel-monitor/main/data/${Line}/history"
    for version in $(cat history | rev | cut -c12- | rev | tail -300)
    do
        if [[ ! -f "${version}.json.br" ]]; then
            ../versions.sh $version
        fi
    done
    rm history
    cd ..
done
