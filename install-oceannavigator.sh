#!/usr/bin/env bash

printf "Where do you wish to install the Ocean Navigator software?\n\n" 
read LOCATION

printf "\nInstalling into.... %s\n\n" ${LOCATION}

if [ ! -d ${LOCATION} ] ; then 
   mkdir -p ${LOCATION}
   if [ $? -ne 0 ] ; then
      printf "It appears you do not have permission to write into %s. Exiting!\n\n" ${LOCATION}
      exit 1
   fi
else
   printf "This directory exists. Exiting!\n"
   exit 1
fi


[ ! -d ${LOCATION}/.tmp ] && mkdir -p ${LOCATION}/.tmp
[ ! -e ${LOCATION}/.tmp/Miniconda3-latest-Linux-x86_64.sh ] && wget --quiet -O ${LOCATION}/.tmp/Miniconda3-latest-Linux-x86_64.sh http://navigator.oceansdata.ca/conda/Miniconda3-latest-Linux-x86_64.sh

if [ ! -d ${LOCATION}/tools/miniconda/3/amd64 ] ; then
   mkdir ${LOCATION}/tools
   printf "\nInstalling the Miniconda software to %s.\n\n" ${LOCATION}/tools/miniconda/3/amd64
   bash ${LOCATION}/.tmp/Miniconda3-latest-Linux-x86_64.sh -b -p ${LOCATION}/tools/miniconda/3/amd64
else
   printf "\nAn instance of the Ocean Navigator exists. Exiting!\n"
   exit 1
fi

export PATH=${LOCATION}/tools/miniconda/3/amd64/bin:${PATH}

if [ -d ${LOCATION}/conf ] ; then
   printf "\nAn instance of the Ocean Navigator exists. Exiting!"\n
   exit 1
else
   printf "\nCreating the %s directory.\n" ${LOCATION}/conf
   mkdir -p ${LOCATION}/conf
fi

if [ -e ${LOCATION}/conf/onav-env.sh ] ; then
   printf "\nAn instance of the Ocean Navigator exists. Exiting!\n"
   exit 1
else
   printf "\nSetting up an Ocean Navigator SHELL environment file located at %s.\n" ${LOCATION}/conf/onav-env.sh
   printf "# >>> conda initialize >>>\n" >> ${LOCATION}/conf/onav-env.sh
   printf "# !! Contents within this block are managed by \'conda init\' !!\n" >> ${LOCATION}/conf/onav-env.sh
   printf "__conda_setup=\"\$(\'$(printf ${LOCATION})/tools/miniconda/3/amd64/bin/conda\' \'shell.bash\' \'hook\' 2> /dev/null)\"\n" >> ${LOCATION}/conf/onav-env.sh
   printf "if [ \$? -eq 0 ]; then\n" >> ${LOCATION}/conf/onav-env.sh
   printf " eval \"\$__conda_setup\"\n" >> ${LOCATION}/conf/onav-env.sh
   printf "else\n" >> ${LOCATION}/conf/onav-env.sh
   printf " if [ -f \"$(printf ${LOCATION})/tools/miniconda/3/amd64/etc/profile.d/conda.sh\" ] ; then\n" >> ${LOCATION}/conf/onav-env.sh
   printf "     . \"$(printf ${LOCATION})/tools/miniconda/3/amd64/etc/profile.d/conda.sh\"\n" >> ${LOCATION}/conf/onav-env.sh
   printf " else\n" >> ${LOCATION}/conf/onav-env.sh
   printf "     export PATH=\"$(printf ${LOCATION})/tools/miniconda/3/amd64/bin:\$PATH\"\n" >> ${LOCATION}/conf/onav-env.sh
   printf " fi\n" >> ${LOCATION}/conf/onav-env.sh
   printf "fi\n" >>${LOCATION}/conf/onav-env.sh
   printf "unset __conda_setup\n" >> ${LOCATION}/conf/onav-env.sh
   printf "# <<< conda initialize <<<\n\n" >> ${LOCATION}/conf/onav-env.sh
   printf "conda activate navigator\n\n" >> ${LOCATION}/conf/onav-env.sh
   printf "export NVM_DIR=\"LOCATION/tools/nvm\"\n" >> ${LOCATION}/conf/onav-env.sh
   printf "[ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm\n" >> ${LOCATION}/conf/onav-env.sh
   printf "[ -s \"\$NVM_DIR/bash_completion\" ] && \\. \"\$NVM_DIR/bash_completion\"  # This loads nvm bash_completion\n" >> ${LOCATION}/conf/onav-env.sh

fi

if [ -d ${LOCATION}/Ocean-Data-Map-Project ] ; then
   printf "\nAn instance of the Ocean Navigator exists. Exiting!\n"
   exit 1
else
   printf "\nDownloading the Ocean-Data-Map-Project.git repo and placing it in %s.\n" ${LOCATION}/Ocean-Data-Map-Project
   mkdir ${LOCATION}/Ocean-Data-Map-Project
   git clone https://github.com/DFO-Ocean-Navigator/Ocean-Data-Map-Project.git ${LOCATION}/Ocean-Data-Map-Project
   
   printf "Bringing in a site specific configuration file for Dorval.\n"
   mkdir ${LOCATION}/.tmp/dorval
   git clone https://github.com/DFO-Ocean-Navigator/dorval.git ${LOCATION}/.tmp/dorval
   mv ${LOCATION}/.tmp/dorval/configs/datasetconfig.json ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/datasetconfig.json

   printf "Creating a cache directory.\n"
   mkdir -p ${LOCATION}/cache/oceannavigator

   printf "Updating the %s configuration file.\n" ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "DEBUG = True\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "CACHE_DIR = \"${LOCATION}/cache/oceannavigator\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "TILE_CACHE_DIR = \"/home/sdfo504/cache/oceannavigator/tiles\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "BATHYMETRY_FILE = \"/home/sdfo504/ocean-nav/data/misc/ETOPO1_Bed_g_gmt4.grd\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "OVERLAY_KML_DIR = \"./kml\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "DRIFTER_AGG_URL = \"http://navigator.oceansdata.ca:8080/thredds/dodsC/Drifter/aggregated.ncml\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "DRIFTER_URL = \"http://navigator.oceansdata.ca:8080/thredds/dodsC/Drifter/%s.nc\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "DRIFTER_CATALOG_URL = \"http://navigator.oceansdata.ca:8080/thredds/catalog/Drifter/catalog.xml\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "CLASS4_FNAME_PATTERN = \"/home/sdfo504/ocean-nav/data/class4/%s/%s.nc\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "CLASS4_PATH = \"/home/sdfo504/ocean-data/data/class4\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "OBSERVATION_AGG_URL = \"http://navigator.oceansdata.ca:8080/thredds/dodsC/Misc/observations/aggregated.ncml\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "ETOPO_FILE = \"/home/sdfo504/ocean-nav/data/misc/etopo_%s_z%d.nc\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "SHAPE_FILE_DIR = \"/home/sdfo504/ocean-nav/data/misc/shapes\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "SQLALCHEMY_DATABASE_URI = \"mysql://nav-read:Z*E92oCqS9J9@127.0.0.1/navigator\"\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "SQLALCHEMY_ECHO = False\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "SQLALCHEMY_TRACK_MODIFICATIONS = False\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   printf "SQLALCHEMY_POOL_RECYCLE = 50\n" >> ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg

   printf "\nWhat SHELL environment are you using so that we may configure conda?\n"
   printf "Your choice is one of bash, fish, tcsh, xonsh, zsh, or powershell.\n"
   printf "\nTo find out what SHELL your using in a seperate terminal window run\n"
   printf "the command \"echo \$SHELL\" and use the returned value for your\n"
   printf "particular environment.\n\n"
   read SHELL_NAME
   printf "\n\n"
   conda init ${SHELL_NAME}

   printf "\n\nConfiguring the CONDA Python environments.\n"
   conda create --quiet --name navigator --file ${LOCATION}/Ocean-Data-Map-Project/config/conda/navigator-spec-file.txt
   awk '!/openssl/' ${LOCATION}/Ocean-Data-Map-Project/config/conda/index-tool-spec-file.txt > ${LOCATION}/Ocean-Data-Map-Project/config/conda/index-tool-spec-file.modified
   mv ${LOCATION}/Ocean-Data-Map-Project/config/conda/index-tool-spec-file.modified ${LOCATION}/Ocean-Data-Map-Project/config/conda/index-tool-spec-file.txt
   conda create --quiet --name index-tool --file ${LOCATION}/Ocean-Data-Map-Project/config/conda/index-tool-spec-file.txt
   conda create --quiet --name nco-tools --file ${LOCATION}/Ocean-Data-Map-Project/config/conda/nco-tools-spec-file.txt

   printf "\nDownloading the NVM software in order to install Node.\n"
   git clone https://github.com/nvm-sh/nvm.git ${LOCATION}/tools/nvm
   export NVM_DIR="${LOCATION}/tools/nvm"
   [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
   [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
   nvm install v8.16.0

   printf "\nDownloading YARN and unbundling the tarball and moving it to %s.\n" ${LOCATION}/tools/yarn
   wget --quiet -O ${LOCATION}/.tmp/yarn-v1.22.5.tar.gz http://navigator.oceansdata.ca/yarn/yarn-v1.22.5.tar.gz
   tar zxf ${LOCATION}/.tmp/yarn-v1.22.5.tar.gz -C ${LOCATION}/.tmp/
   mv ${LOCATION}/.tmp/yarn-v1.22.5 ${LOCATION}/tools/yarn
   export PATH=${LOCATION}/tools/yarn/bin:${PATH}

   printf "\nDownloading and installing BOWER.\n"
   yarn global add bower --prefix ${LOCATION}/tools/bower
   export PATH=${LOCATION}/tools/bower/bin:${PATH}

   printf "\nCompiling the Javascript frontend of the Ocean Navigator.\n"
   cd ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/frontend
   yarn install
   yarn build
   cd -

   printf "\nDownloading the indexing toolchain to %s.\n" ${LOCATION}/netcdf-timestamp-mapper
   mkdir ${LOCATION}/netcdf-timestamp-mapper
   git clone https://github.com/DFO-Ocean-Navigator/netcdf-timestamp-mapper.git ${LOCATION}/netcdf-timestamp-mapper
   cd ${LOCATION}/netcdf-timestamp-mapper
   git submodule update --init --recursive

   printf "\nNow that the installation has completed. You now need to source the\n"
   printf "Ocean Navigator environment configuration file by running the command...\n"
   printf "\tsource ${LOCATION}/conf/onav-env.sh\n" 
   printf "\nThe following pip files are needed.\n"
   printf "\tpip install defopt && pip install visvalingamwyatt\n"
   printf "\n\nAs well, the indexing tool needs to be built. Please use the following\n"
   printf "commands to compile the indexing toolchain.\n"
   printf "\tcd ${LOCATION}/netcdf-timestamp-mapper\n"
   printf "\tconda activate index-tool && make && conda deactivate\n"

fi
