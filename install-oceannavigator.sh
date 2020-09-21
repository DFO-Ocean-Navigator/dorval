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
   printf "\n" >> ${LOCATION}/conf/onav-env.sh
   echo "export PATH=${LOCATION}/tools/yarn/bin:\$PATH" >> ${LOCATION}/conf/onav-env.sh
   echo "export PATH=${LOCATION}/tools/bower/bin:\$PATH" >> ${LOCATION}/conf/onav-env.sh

fi

if [ -d ${LOCATION}/Ocean-Data-Map-Project ] ; then
   printf "\nAn instance of the Ocean Navigator exists. Exiting!\n"
   exit 1
else
   printf "\nDownloading the Ocean-Data-Map-Project.git repo and placing it in %s.\n" ${LOCATION}/Ocean-Data-Map-Project
   mkdir ${LOCATION}/Ocean-Data-Map-Project
   git clone https://github.com/DFO-Ocean-Navigator/Ocean-Data-Map-Project.git ${LOCATION}/Ocean-Data-Map-Project
   
   printf "Bringing in a site specific configuration file for Dorval.\n"
   cd ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs
   git checkout dorval

   printf "Creating a cache directory.\n"
   mkdir -p ${LOCATION}/cache/oceannavigator

   printf "Adjusting the %s configuration file.\n" ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg
   git clone https://github.com/DFO-Ocean-Navigator/dorval.git ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs
   cd ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs
   git checkout dorval
   cd -
   sed -i "s/LOCATION/${LOCATION}/" ${LOCATION}/Ocean-Data-Map-Project/oceannavigator/configs/oceannavigator.cfg

   printf "In order to configure your account to work with conda we need to know what\n"
   printf "shell you are using. Your choices are bash, fish, tcsh, xonsh, zsh, or\n"
   printf " powershell.\n"
   read SHELL_NAME
   printf "\n\n"
   conda init ${SHELL_NAME}

   printf "\n\nInstalling aand configuring the CONDA Python environments.\n"
   conda create --quiet --name navigator --file ${LOCATION}/Ocean-Data-Map-Project/config/conda/navigator-spec-file.txt
   conda create --quiet --name index-tool --file ${LOCATION}/Ocean-Data-Map-Project/config/conda/index-tool-spec-file.txt
   conda create --quiet --name nco-tools --file ${LOCATION}/Ocean-Data-Map-Project/config/conda/nco-tools-spec-file.txt

   printf "\nDownloading the NVM software in order to install Node.\n"
   git clone https://github.com/nvm-sh/nvm.git ${LOCATION}/tools/nvm
   printf "export NVM_DIR=\"${LOCATION}/tools/nvm\"\n" >> ${HOME}/.bashrc
   printf "[ -s "$NVM_DIR/nvm.sh" ] && \. \"$NVM_DIR/nvm.sh\"" >> ${HOME}.bashrc 
   printf "[ -s "$NVM_DIR/bash_completion" ] && \. \"$NVM_DIR/bash_completion\"" >> ${HOME}/.bashrc
   source .bashrc
   bash -c "nvm install v8.16.0"

   printf "\nDownloading YARN and unbundling the tarball and moving it to %s.\n" ${LOCATION}/tools/yarn
   wget --quiet -O ${LOCATION}/.tmp/yarn-v1.22.5.tar.gz http://navigator.oceansdata.ca/yarn/yarn-v1.22.5.tar.gz
   tar zxf ${LOCATION}/.tmp/yarn-v1.22.5.tar.gz -C ${LOCATION}/.tmp/
   mv ${LOCATION}/.tmp/yarn-v1.22.5 ${LOCATION}/tools/yarn
   export PATH=${LOCATION}/tools/yarn/bin:${PATH}

   printf "\nDownloading and installing BOWER.\n"
   yarn global add bower --prefix ${LOCATION}/tools/bower --global-folder 
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
