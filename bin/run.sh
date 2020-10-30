#!/usr/bin/env bash

cd ${HOME}/dorval


./bin/configure.sh

source tools/conf/ocean-navigator-env.sh

cd Ocean-Data-Map-Project

printf "\n\n\tLogging information is available at ${HOME}/dorval/launch-on-web-service.log\n"
printf "\tthis information is useful to submit if a software bug was encountered.\n"

./launch-web-service.sh 
