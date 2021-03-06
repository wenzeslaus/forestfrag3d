#!/bin/bash

# set up temporary region
WIND_OVERRIDE=profile_images_tmp_region
g.region -u save=$WIND_OVERRIDE
export WIND_OVERRIDE

# set region to profiles
g.region raster=n_profile

export GRASS_FONT="DejaVu Sans:Book"
eval `g.region -g`

DESIRED_WIDTH=1000
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

BAR_LENGTH=50
FONT_SIZE_PT=25

d.mon start=cairo output=structure_profile.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=reconstructed_01_profile
d.rast map=n_profile values=1-inf
# only one needs a scale bar when together
#d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100 fontsize=${FONT_SIZE_PT} \
#    bgcolor=none
d.mon stop=cairo

d.mon start=cairo output=ff_profile.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=ff_profile
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100 fontsize=${FONT_SIZE_PT} \
    bgcolor=none
d.mon stop=cairo

# combine images
GEOMETRY="+12+4"
montage structure_profile.png ff_profile.png \
    -geometry $GEOMETRY -tile x2 profiles.png

# remove temporary region
g.remove -f type=region name=$WIND_OVERRIDE
unset WIND_OVERRIDE
