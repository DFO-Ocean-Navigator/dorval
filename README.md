# dorval
This is a site specific repo.

## How to index a local or remotely accessible dataset for the Ocean Navigator
 1. Change your present working directory to netcdf-timestamp-mapper.
 
 2. Activate the index-tool conda virtual environment in order to setup your Linux environment variables.
 
 3. You can the run the command “./build/nc-timestamp-mapper --help” to see what options are available.
 
    For the purpose of this exercise. I will assume that there exists a local directory structure like “/data/dd.weather.gc.ca/model_giops/netcdf/lat_lon/2d/”. It contains subdirectories called {000, 003, …, 240} and in turn contain the various NetCDF files from ECCC.  We are only interested in indexing the 00 and 12 run time simulations to create a view of a 24 hour time period and saving the database in your home directory.
 4. We will need to generate a list of filenames matching the aforementioned criteria in order to instruct the nc-timestamp-mapper binary of what we wish to be included in the SQLite3 database. We’ll use the Linux find command and redirect its output to a text file. The command is,
 
    ```find /data/dd.weather.gc.ca/model_giops/netcdf/lat_lon/2d/{00,12}/{000,003,006,009,012} -type f > giops-2d-latlon.txt```
   
 5. The command to create this unique index is;
 
    ```./build/nc-timestamp-mapper -i /data/dd.weather.gc.ca/model_giops/netcdf/lat_lon/2d -n giops-2d-latlon -o ${HOME}/db --file-list giops-2d-latlon.txt -h```
  
    When the command is executed, you will be informed how many files will be indexed and a progress bar will be shown letting you now when it has completed

## How to update the Ocean Navigator datasetconfig.json file
 1. Change your current working directory to “[…]/Ocean-Data-Map-Project/oceannavigator/configs”. Replace the string “[…]” with the fully or relative path of your Ocean Navigator instance.
 
 2. Access the header information of a NetCDF file in order to determine what variables it contains along with grid dimensions and time definitions to name a few items of interest. This can be accomplished by activating the nco-tools conda environment and using the ncdump command with the “-h” option.
 
 3. Once you have the information you wish to be displayed. Use a simple text editor (such as emacs or vi) to open the datasetconfig.json file. This file is specially formatted and can be sensitive to how information is copied into the file causing the lexicon analyzer issues with parsing information. If the file is misconfigured the Ocean Navigator web services may not start or may partially work allowing the user to see the landing page of the Ocean Navigator but the application itself may no longer show the base map. Please refer to the launch-on-web-service.log file which should be located in the root of your home directory.
 
 4. Here is a sample entry that can be placed used in the datasetconfig.json file. Which would need to be placed within the first set of curly braces;

    ```"giops-3d-latlon": {
    "envtype": ["ocean", "ice"],
    "url": "/home/ubuntu/db/giops-3d-latlon.sqlit3",
    "name": " Time-averaged sea ice and ocean forecast fields",
    "quantum": "Options are hour, day, or month",
    "type": "forecast",
    "time_dim_units": "seconds since 1950-01-01 00:00:00",
    "enabled": true,
    "cache": 6,
    "climatology": "http://navigator.oceansdata.ca:8080/thredds/dodsC/climatology/Levitus98_PHC21/aggregated.ncml",
    "attribution": " The Canadian Centre for Meteorological and Environmental Prediction",
    "lat_var_key": "latitude",
    "lon_var_key": "longitude",
    "help": " This could contain a small blurb to let people know more",

     "variables": {
          "vozocrtx": { "name": "Water East Velocity", "envtype": "ocean", "unit": "m/s", "scale": [-3, 3], "zero_centered": "true" },
          "vomecrty": { "name": "Water North Velocity", "envtype": "ocean", "unit": "m/s", "scale": [-3, 3], "zero_centered": "true" },
          "magwatervel": { "name": "Water Velocity", "envtype": "ocean", "unit": "m/s", "scale": [0, 3], "equation": "magnitude(vozocrtx, vomecrty)",  "dims": ["time", "depth", "latitude", "longitude"], "east_vector_component": "vozocrtx", "north_vector_component": "vomecrty" },
           "votemper": { "name": "Temperature", "envtype": "ocean", "unit": "Celsius", "scale": [-5, 30], "equation": "votemper - 273.15", "dims": ["time", "depth", "latitude", "longitude"] },
           "vosaline": { "name": "Salinity", "envtype": "ocean", "unit": "PSU", "scale": [30, 40]}
     },

 In the above example, if you were to copy and paste this into your own configuration file. The text file may break the magwatervel variable definition over two lines instead of one continuous string. This would cause the Ocean Navigator to throw an error and fail to work properly.

 If you are using polar stereographic datasets the lat_var_key and lon_var_key would need to be updated accordingly and if you have a grid angle file to rotate the variables to a grid. You will need to use a definition like the following;

 ```"grid_angle_file_url": "/data/grids/ecc/giops/grid_angle_giops_ps5km60n.nc",```

 and the definition should be placed before the variable section. If this is the only dataset or is the last dataset to be defined in the configuration file you will need to remove the last comma to indicate that the datasets have ended. The use of the last variable definition should not contain a comma refer to the vosaline definition.

 You may note that the votemper variable to transformed from Kelvin to Celsius. If the dataset you are using already has this conversion. You will need to adjust the variable’s definition to the following;

 ```"votemper": { "name": "Temperature", "envtype": "ocean", "unit": "Celsius", "scale": [-5, 30], "dims": ["time", "depth", "latitude", "longitude"] },```
