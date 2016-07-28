#!/bin/sh
cd $(dirname $0)

no_cache='--no-cache'

if [ ! -d 'burrow-stats' ]; then
  git clone https://github.com/tulios/burrow-stats
fi

if [ ! -f 'configs.json' ]; then
  cp configs.streamworks.json configs.json 
fi
cp -vf configs.json burrow-stats/configs.json

docker build $no_cache -t="streamworks/burrow-stats" burrow-stats/
