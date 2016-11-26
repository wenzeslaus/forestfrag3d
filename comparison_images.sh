#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"
eval `g.region -g`

DESIRED_WIDTH=2000
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

START=50.3
END=49.7

START_WIDTH_PX=`python -c "print round($START / 100. * float($DESIRED_WIDTH))"`
END_WIDTH_PX=`python -c "print round($END / 100. * float($DESIRED_WIDTH))"`

HEIGHT_OFFSET_3D=10
START_HEIGHT_3D_PX=`python -c "print round(($START + $HEIGHT_OFFSET_3D) / 100. * float($DESIRED_HEIGHT))"`

BAR_LENGTH=200
FONT_SIZE_PT=30
LABEL_SIZE_PX=30
LINE_WIDTH=8
CONTOUR_WIDTH=3
BRIGHTEN_SHADE=40
ZONES_COLOR="red"
PROFILE_COLOR="#00AED1"
SYMBOL_SIZE=85

cat > legend_zones_profile.txt <<EOF
zones|legend/area|50|lf|$ZONES_COLOR|none|$LINE_WIDTH|line|1
profile|legend/line|50|ps|$PROFILE_COLOR|none|$LINE_WIDTH|line|1
EOF

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
d.legend -c raster=${FF} at=20,100,5,15 fontsize=${FONT_SIZE_PT}
d.legend -s -f raster=${DENSITY} at=20,90,75,85 fontsize=${FONT_SIZE_PT} \
    label_values=0,5,10,15 range=0,20
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,20 fontsize=${FONT_SIZE_PT}
d.mon stop=cairo

d.mon start=cairo output=comparison_ortho.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${ORTHO}
d.vect map=${PROFILE_LINE} display=shape,dir color=${PROFILE_COLOR} fill_color=none width=${LINE_WIDTH}
d.vect map=${ZONES} display=shape,cat color=${ZONES_COLOR} fill_color=none width=${LINE_WIDTH} \
    label_color=black label_bgcolor=#CBCBCB label_size=${LABEL_SIZE_PX} xref=left yref=top
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${DENSITY}
d.frame -c frame=f_bl at=0,$END,0,$END
d.shade shade=${SHADE} color=${FF} brighten=${BRIGHTEN_SHADE}
d.vect map=contours color=white width=${CONTOUR_WIDTH}
d.frame -c frame=f_br at=0,$END,$START,100
d.legend -c raster=${FF} at=20,72,8,18 fontsize=${FONT_SIZE_PT}
    # title="Dominant fragmentation class"
d.legend -s -f raster=${DENSITY} at=15,90,65,72 fontsize=${FONT_SIZE_PT} \
    label_values=0,5,10,15 range=0,20 \
    title="Point count"
d.legend.vect at=8,97 input=legend_zones_profile.txt \
    fontsize=${FONT_SIZE_PT} symbol_size=${SYMBOL_SIZE}
    # title="Orthophoto"
d.barscale units=meters style=solid length=${BAR_LENGTH} at=5,7 fontsize=${FONT_SIZE_PT}
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

# no whitespace that the computational region fits
mogrify -trim ${IMAGE_3D}

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

DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

d.mon start=cairo output=elevation_3d_empty.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.vect map=contours color=white width=1
# since the region is the same as for 3D, the scale bar should be right
# for the front in the right-to-left direction
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,50 fontsize=${FONT_SIZE_PT}
d.mon stop=cairo

# compose with image from 3D using ImageMagic
convert elevation_3d_empty.png \
    \( ${IMAGE_3D} -resize ${DESIRED_WIDTH}x \) \
    -geometry +0+0 \
    -composite elevation_3d.png

mogrify -trim elevation_3d.png
