#!/bin/sh
. ../../scripts/lib/docker_functions.sh

no_cache=$1

img_name='streamworks/base'

docker_build $no_cache
