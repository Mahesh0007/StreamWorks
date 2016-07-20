#!/bin/sh
. ./burrow_stats_functions.sh

no_cache=$1

if [ ! -d 'burrow-stats' ]; then
  git clone https://github.com/tulios/burrow-stats
fi

build_segments

cp -vf configs.json burrow-stats/configs.json

# docker build $no_cache -t="streamworks/burrow-stats" burrow-stats/
