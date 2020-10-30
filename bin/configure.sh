#!/usr/bin/env bash

cd bin
if [ ! -e .configuration.updated ] ; then
   sed "s#LOCATION#$HOME#g" -i ../Ocean-Data-Map-Project/oceannavigator/oceannavigator.cfg
   sed "s#LOCATION#$HOME#g" -i ../tools/conf/ocean-navigator-env.sh
   touch .configuration.updated
fi
