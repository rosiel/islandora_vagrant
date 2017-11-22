#!/bin/bash

for d in */ ; do
  if [  -d $d/.git ]; then
       echo "Updating " $d;
       cd $d;
       git checkout 7.x;
       git pull;
       cd ..
  fi
done
