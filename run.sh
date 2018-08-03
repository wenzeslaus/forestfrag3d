#!/bin/bash

if [ -z "$1" ]
then
    REGION=study_region
elif [ $1 = "test" ]
then
    REGION=test_region
else
    >&2 echo "Invalid parameter: $1"
    exit 1
fi

if ! [ -w /data ]
    >&2 echo "Directory is not writable: /data"
    >&2 echo "See the permissions:"
    >&2 ls -la /data
    exit 1
fi

GRASSDATA=/data/grassdata/nc_location/PERMANENT

# create GRASS GIS location
grass -c EPSG:6543 /data/grassdata/nc_location -e
#grass $GRASSDATA --exec g.region -p

# uncompress the point cloud
cd /data
7zr e -y /code/points.las.7z

mkdir $GRASSDATA/windows
cp /code/study_region $GRASSDATA/windows/
cp /code/test_region $GRASSDATA/windows/

grass $GRASSDATA --exec g.region region=$REGION

grass $GRASSDATA --exec /code/import_zones.sh /code/zones.txt

grass $GRASSDATA --exec \
    r.unpack input=/code/ortho.grpack output=ortho

# fine resolution for the surfaces
grass $GRASSDATA --exec g.region res=1 -a

grass $GRASSDATA --exec /code/ground.sh
grass $GRASSDATA --exec /code/contours.sh
grass $GRASSDATA --exec /code/veg_surface.sh

# we changed the region, change it back
# 2D and 3D resolution same, same in all directions, and coarser
grass $GRASSDATA --exec g.region region=$REGION

grass $GRASSDATA --exec /code/density.sh
grass $GRASSDATA --exec /code/lidar3d.sh
grass $GRASSDATA --exec /code/ff.py
grass $GRASSDATA --exec /code/category_counts.sh
grass $GRASSDATA --exec /code/slice.sh
grass $GRASSDATA --exec /code/count_series.sh
grass $GRASSDATA --exec /code/zonal.sh
grass $GRASSDATA --exec /code/ffiness.sh
grass $GRASSDATA --exec /code/ffiness_zonal.sh
grass $GRASSDATA --exec /code/profiles.sh

mkdir /data/images
cd /data/images

cp /code/main_cat_3d.png /data/images

grass $GRASSDATA --exec /code/images.sh
grass $GRASSDATA --exec /code/plot_zonal.sh
grass $GRASSDATA --exec /code/ffiness_images.sh
grass $GRASSDATA --exec /code/comparison_images.sh
grass $GRASSDATA --exec /code/profile_images.sh
grass $GRASSDATA --exec /code/count_cats_figure.sh

#grass $GRASSDATA --exec g.list rast,rast3,vect
