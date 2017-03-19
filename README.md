# forestfrag3d

[![Build Status](https://travis-ci.org/wenzeslaus/forestfrag3d.svg?branch=master)](https://travis-ci.org/wenzeslaus/forestfrag3d)

## Running

### Build directly from the remote repository

Build based on the content of the Git repository:

    docker build -t forestfrag3d https://github.com/wenzeslaus/forestfrag3d.git

Start the processing (you need an existing empty directory):

    docker run --rm -v /home/.../ffdata:/data -it forestfrag3d /code/run.sh

### Get the repository content

Either download ZIP from the GitHub repository website or use Git:

    git clone https://github.com/wenzeslaus/forestfrag3d.git

### Build and run from local code

In the command line, enter into the repository directory (there should
be a Dockerfile), for example:

    cd /home/.../forestfrag3d

Build the content using Docker:

    docker build -t forestfrag3d .

The time to build it for the first time is about 12 minutes
plus the time to download the basic parts.
You will need to build it again after every change of the scripts
(or of the Dockerfile) but these builds will usually take just few
seconds depending on the changes you did.

The outputs will be stored in a directory, create an empty directory
on your machine, for example:

    mkdir /home/.../ffdata

To run the processing, set the volume `/data` to the empty you just
created and execute:

    docker run --rm -v /home/.../ffdata:/data -it forestfrag3d /code/run.sh

The time run on the full study area is about 20 minutes. For testing
purposes, there is a small area which takes about 5 minutes to compute.

To run just the test area, add `test` parameter to the main script:

    docker run ... /code/run.sh test

### Run part of the processing

To run just a part of the processing, call the specific script instead
of the main one. If you change the script you are running, you need to
build the Docker image (this should take around 2 seconds) and than
run the script (use `&&` for executing both commands in one line).
For some scripts like the ones creating images, you many need to change
the working directory with `-w`. Unless you delete the output files
ahead, you will need to set the global overwrite flag using
environmental variable. Here is a complete example:

    docker build -t forestfrag3d . \
        && docker run --rm \
            -v /home/.../ffdata:/data \
            -e GRASS_OVERWRITE=1 \
            -w /data/images \
            -it forestfrag3d \
            grass /data/grassdata/nc_location/PERMANENT --exec \
                /code/comparison_images.sh

For testing purposes, you can change computational region to
the predefined `test_region` or any other region settings:

    docker run --rm \
        -v /home/.../ffdata:/data \
        -it forestfrag3d \
        grass /data/grassdata/nc_location/PERMANENT --exec \
            g.region region=test_region

Then you can run the analysis. Alternatively, you can use environmental
variable to change the region just for the specific process:

    docker run --rm \
        -v /home/.../ffdata:/data \
        -e GRASS_OVERWRITE=1 \
        -e WIND_OVERRIDE=test_region \
        -it forestfrag3d \
        grass /data/grassdata/nc_location/PERMANENT --exec \
            /code/ground.sh

Note that sometimes, you may need to delete some of the generated files
or run more steps one by one to ensure smooth run without errors,
for example the text files with data for plots should be deleted when
changing the zones:

    rm -r /home/.../ffdata/images/*.txt

## Inspecting results

There is a lot of additional images in the directory `images`.
Furthermore, if you have GRASS GIS installed locally, you can open
the created GRASS GIS mapset and explore all the data, for example,
using the following command:

    grass7 /home/../ffdata/grassdata/nc_location/PERMANENT

## Files

### Point cloud

The lidar point cloud is derived from a North Carolina Phase 3 lidar
mapping, tile `LA_37_20079303_20160228.las`.
The `points.las.7z` file was created from the original tile by cropping
it using `las2las` from libLAS:

    las2las points.las --output points_clip.las \
        --extent "2090835 730212 2092347 731322"

and compressed using `7zr`:

    7zr a points.las.7z points.las

Note that `7zr` from the `p7zip` package is in this case equivalent
with the `7z` tool from the `p7zip-full` package on Ubuntu.

### Orthophoto

The orthophoto was obtained from NC OneMap web service:

    http://services.nconemap.com/arcgis/services/Imagery/Orthoimagery_All/ImageServer/WMSServer

The ortophoto raster map in GRASS GIS was compressed using BZIP2:

    GRASS_COMPRESSOR=BZIP2 r.compress map=ortho

and exported in (native) GRASS GIS pack format:

    r.pack input=ortho output=ortho.grpack

### Zones

Manually selected and digitized polygons for zonal analysis were
exported from GRASS GIS in a (native) ASCII format using:

    v.out.ascii input=zones layer=-1 type=boundary,centroid \
        format=standard precision=2 output=zones.txt

Trailing spaces were removed using:

    sed -i 's/\s*$//g' zones.txt

The header was edited and cleaned up manually.

### Computational regions

The repository include two computational regions for GRASS GIS which can
be copied into GRASS GIS spatial database and used as *saved regions*.
The `study_region` file stores the extent of the study area and
the `test_region` files stores a very small extent meant for
testing the processing chain.

### 3D visualization

The `main_cat_3d.png` file is a manually created using GRASS GIS 3D view
(NVIZ). Theoretically, same image can be obtained using *m.nviz.image*
module.

## Dependencies

### GRASS GIS

A custom build of GRASS GIS is compiled from source code obtained
directly from GRASS GIS Subversion repository. The version
is specified in the Dockerfile.

There is a bug in the r3.null module which causes a certain 3D tile
to contain NULL values only (see #2992 in GRASS GIS bug tracker).
The patch with a workaround is included in the file `r3.null.patch`
and applied during compilation. The patch was created against trunk,
revision number 69871 from July 7, 2016.
