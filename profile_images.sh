#!/bin/bash

# set up temporary region
WIND_OVERRIDE=profile_images_tmp_region
g.region -u save=$WIND_OVERRIDE
export WIND_OVERRIDE

# set region to profiles
g.region raster=n_profile

export GRASS_FONT=sans
eval `g.region -g`

DESIRED_WIDTH=1000
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

START=50.2
END=49.8

START_WIDTH_PX=`python -c "print round($START / 100. * float($DESIRED_WIDTH))"`
END_WIDTH_PX=`python -c "print round($END / 100. * float($DESIRED_WIDTH))"`

HEIGHT_OFFSET_3D=10
START_HEIGHT_3D_PX=`python -c "print round(($START + $HEIGHT_OFFSET_3D) / 100. * float($DESIRED_HEIGHT))"`

BAR_LENGTH=50
FONT_SIZE_PT=19
LABEL_SIZE_PX=15

d.mon start=cairo output=structure_profile.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=reconstructed_01_profile
d.rast map=n_profile values=1-inf
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100 fontsize=${FONT_SIZE_PT} \
    bgcolor=none
d.mon stop=cairo

d.mon start=cairo output=ff_profile.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=ff_profile
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100 fontsize=${FONT_SIZE_PT} \
    bgcolor=none
d.mon stop=cairo

# remove temporary region
g.remove -f type=region name=$WIND_OVERRIDE
unset WIND_OVERRIDE
