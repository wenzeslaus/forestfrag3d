#!/bin/bash

GRASSDATA=/data/grassdata/nc_location/PERMANENT

# create GRASS GIS location
grass -c EPSG:6543 /data/grassdata/nc_location -e
#grass $GRASSDATA --exec g.region -p

# uncompress the point cloud
cd /data
7zr e -y /code/points.las.7z

mkdir $GRASSDATA/windows
cp /code/study_region $GRASSDATA/windows/study_region

grass $GRASSDATA --exec \
    v.in.ascii input=/code/zones.txt output=zones_full format=standard

grass $GRASSDATA --exec g.region region=study_region

grass $GRASSDATA --exec v.in.region output=region
grass $GRASSDATA --exec \
    v.overlay ainput=zones_full binput=region operator=and output=zones

grass $GRASSDATA --exec \
    r.unpack input=/code/ortho.grpack output=ortho

grass $GRASSDATA --exec /code/process_lidar.sh
grass $GRASSDATA --exec /code/contours.sh
grass $GRASSDATA --exec /code/veg_surface.sh
grass $GRASSDATA --exec /code/ff.py
grass $GRASSDATA --exec /code/category_counts.sh
grass $GRASSDATA --exec /code/slice.sh
grass $GRASSDATA --exec /code/count_series.sh
grass $GRASSDATA --exec /code/zonal.sh
grass $GRASSDATA --exec /code/ffiness.sh
grass $GRASSDATA --exec /code/ffiness_zonal.sh

mkdir /data/images
cd /data/images

cp /code/main_cat_3d.png /data/images

grass $GRASSDATA --exec /code/images.sh
grass $GRASSDATA --exec /code/plot_zonal.sh
grass $GRASSDATA --exec /code/ffiness_images.sh
grass $GRASSDATA --exec /code/comparison_images.sh

#grass $GRASSDATA --exec g.list rast,rast3,vect
