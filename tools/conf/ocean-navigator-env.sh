# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('LOCATION/dorval/tools/miniconda/3/amd64/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
 eval "$__conda_setup"
else
 if [ -f "LOCATION/dorval/tools/miniconda/3/amd64/etc/profile.d/conda.sh" ] ; then
     . "LOCATION/dorval/tools/miniconda/3/amd64/etc/profile.d/conda.sh"
 else
     export PATH="LOCATION/tools/miniconda/3/amd64/bin:$PATH"
 fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda activate navigator

export PATH=LOCATION/dorval/tools/netcdf-timestamp-mapper/build:$PATH
