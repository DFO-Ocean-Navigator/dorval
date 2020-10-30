#!/usr/bin/env bash

[ ! -d ${HOME}/dorval/Ocean-Data-Map-Project ] && tar zxf ${HOME}/dorval/Ocean-Data-Map-Project.tgz -C ${HOME}/dorval
[ -d ${HOME}/dorval/Ocean-Data-Map-Project ] && rm ${HOME}/dorval/Ocean-Data-Map-Project.tgz

cd bin

if [ ! -e .configuration.updated ] ; then
   sed "s#LOCATION#$HOME#g" -i ../Ocean-Data-Map-Project/oceannavigator/oceannavigator.cfg
   sed "s#LOCATION#$HOME#g" -i ../tools/conf/ocean-navigator-env.sh
   touch .configuration.updated
fi
