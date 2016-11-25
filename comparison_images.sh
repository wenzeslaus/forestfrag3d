#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"
eval `g.region -g`

DESIRED_WIDTH=1000
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

START=50.3
END=49.7

START_WIDTH_PX=`python -c "print round($START / 100. * float($DESIRED_WIDTH))"`
END_WIDTH_PX=`python -c "print round($END / 100. * float($DESIRED_WIDTH))"`

HEIGHT_OFFSET_3D=10
START_HEIGHT_3D_PX=`python -c "print round(($START + $HEIGHT_OFFSET_3D) / 100. * float($DESIRED_HEIGHT))"`

BAR_LENGTH=200
FONT_SIZE_PT=15
LABEL_SIZE_PX=15
LINE_WIDTH=4
BRIGHTEN_SHADE=40

FF="ff_series_15_max_raster"
ORTHO="ortho"
DENSITY="n_3_4_5_3_f"
DEM="ground"
SHADE="relief"
CONTOURS="contours"
ZONES="zones"
PROFILE_POINTS="profile_points"
PROFILE_LINE="profile_line"

IMAGE_3D="main_cat_3d.png"

d.mon start=cairo output=comparison_ortho_simple.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${ORTHO}
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${DENSITY}
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=${FF}
d.frame -c frame=f_br at=0,$END,$START,100
d.legend -c raster=${FF} at=20,100,5,15  fontsize=${FONT_SIZE_PT}
d.legend -s raster=${DENSITY} at=10,90,75,85 fontsize=${FONT_SIZE_PT} range=0,20
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,20 fontsize=${FONT_SIZE_PT}
d.mon stop=cairo

d.mon start=cairo output=comparison_ortho.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${ORTHO}
d.vect map=${PROFILE_LINE} display=shape,dir color="#00AED1" fill_color=none width=${LINE_WIDTH}
d.vect map=${ZONES} display=shape,cat color=red fill_color=none width=${LINE_WIDTH} \
    label_color=black label_bgcolor="#CBCBCB" label_size=${LABEL_SIZE_PX} xref=left yref=top
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${DENSITY}
d.frame -c frame=f_bl at=0,$END,0,$END
d.shade shade=${SHADE} color=${FF} brighten=${BRIGHTEN_SHADE}
d.vect map=contours color=white width=1
d.frame -c frame=f_br at=0,$END,$START,100
d.legend -c raster=${FF} at=20,100,5,15  fontsize=${FONT_SIZE_PT}
d.legend -s raster=${DENSITY} at=10,90,75,85 fontsize=${FONT_SIZE_PT} range=0,20
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,20 fontsize=${FONT_SIZE_PT}
d.mon stop=cairo

d.mon start=cairo output=ortho_with_zones.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=${ORTHO}
d.vect map=${ZONES} display=shape,cat color=red fill_color=none width=${LINE_WIDTH} \
    label_color=black label_bgcolor="#CBCBCB" label_size=${LABEL_SIZE_PX} xref=left yref=top
d.barscale units=meters style=solid length=${BAR_LENGTH} at=40,100 fontsize=${FONT_SIZE_PT} \
    bgcolor=none
d.mon stop=cairo

d.mon start=cairo output=ortho_with_profiles.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=${ORTHO}
d.vect map=${PROFILE_LINE} display=shape,dir color="#00AED1" fill_color=none width=${LINE_WIDTH}
d.barscale units=meters style=solid length=${BAR_LENGTH} at=40,100 fontsize=${FONT_SIZE_PT} \
    bgcolor=none
d.mon stop=cairo

d.mon start=cairo output=comparison_elevation_2x2.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${DEM}
d.vect map=${CONTOURS} color="#1A1A1A" width=1
d.frame -c frame=f_tr at=$START,100,$START,100
d.shade shade=${SHADE} color=${FF} brighten=${BRIGHTEN_SHADE}
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=${SHADE}
d.frame -c frame=f_br at=0,$END,$START,100
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,20 fontsize=${FONT_SIZE_PT}
d.mon stop=cairo

# compose with image from 3D using ImageMagic
convert comparison_elevation_2x2.png \
    \( ${IMAGE_3D} -resize ${END_WIDTH_PX}x \) \
    -geometry +${START_WIDTH_PX}+${START_HEIGHT_3D_PX} \
    -composite comparison_elevation_2x2_3d.png

DESIRED_WIDTH=`python -c "print round($DESIRED_WIDTH / 2.)"`
#END_WIDTH_PX=`python -c "print $END_WIDTH_PX * 2"`
#HEIGHT_OFFSET_3D=5
#START_HEIGHT_3D_PX=`python -c "print round(($START + $HEIGHT_OFFSET_3D) / 100. * float($DESIRED_HEIGHT))"`

d.mon start=cairo output=comparison_elevation.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tr at=$START,100,0,100
d.shade shade=${SHADE} color=${FF} brighten=${BRIGHTEN_SHADE}
d.vect map=contours color=white width=1
d.frame -c frame=f_br at=0,$END,0,100
# d.erase "#FFAAXX" # TODO: 3D image is one pixel smaller
#d.legend -c raster=${FF} at=20,100,5,15 fontsize=10
#d.legend -s raster=${DEM} at=10,90,75,85 fontsize=10 range=0,20
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,30 fontsize=${FONT_SIZE_PT}
d.mon stop=cairo

# compose with image from 3D using ImageMagic
convert comparison_elevation.png \
    \( ${IMAGE_3D} -resize ${END_WIDTH_PX}x \) \
    -geometry +0+${START_HEIGHT_3D_PX} \
    -composite comparison_elevation_3d.png

mogrify -trim comparison_elevation_3d.png
