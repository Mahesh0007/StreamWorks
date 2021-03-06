#!/bin/sh

# stop project containers
for each in $(docker ps -a|grep 'streamworks_'|awk 'NF>1{print $NF}'); do
  cmd="docker stop $each"
  echo $cmd
  eval "$cmd"
done

# start project containers
for each in $(docker ps -a|grep 'streamworks_'|awk 'NF>1{print $NF}'); do
  cmd="docker start $each"
  echo $cmd
  eval "$cmd"
done
