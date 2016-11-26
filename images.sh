#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"
eval `g.region -g`

#for SLICE in 05 15 25 35
#do
#    d.mon start=cairo output=hslice_$SLICE.png width=$(( $cols / 3 )) height=$(( $rows / 3 ))
#    d.erase  # previous image is not cleaned
#    d.rast map=ff_slice_000$SLICE
#    d.barscale units=meters
#    d.mon stop=cairo
#done

DESIRED_WIDTH=500
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

START=50.3
END=49.7

BAR_LENGTH=200
BAR_AT=0,16

# TODO: fix ff and slicing, so we already have a color table here
r.colors map=`g.list raster -e pattern="^ff_slice_[0-9]+" sep=comma` raster_3d=ff

d.mon start=cairo output=hslice.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=ff_slice_00005
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=ff_slice_00015
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=ff_slice_00025
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=ff_slice_00035
d.barscale units=meters style=solid bgcolor=none length=${BAR_LENGTH} at=30,16
d.mon stop=cairo

# in display_sw_smaller, it is 0-30
r.colors map=ff_count_1,ff_count_3,ff_count_4,ff_count_5 rules=- <<EOF
#0% 162:13:133
#0% 23:18:105
#10% 238:81:76
#20% 252:148:63
#100% 244:243:68
0 23:18:105
5 238:81:76
10 252:148:63
20 244:243:68
100% 244:243:68
EOF

d.mon start=cairo output=count.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
#d.rast map=ff_count_interior
d.rast map=ff_count_5
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=ff_count_4
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=ff_count_3
d.frame -c frame=f_br at=0,$END,$START,100
#d.rast map=ff_count_1
d.barscale units=meters style=solid length=${BAR_LENGTH} at=${BAR_AT}
# 24 is max for count 4 and 5
d.legend -s -f -b raster=ff_count_5 border_color=none at=4,95,79,89 label_values=0,10,20 range=0,24 fontsize=10
d.mon stop=cairo

r.colors map=`g.list rast pat="${MAP}_*" sep=,` rules=- <<EOF
0% 23:18:105
5% 238:81:76
10% 252:148:63
60% 244:243:68
100% 244:243:68
EOF

MAP=ff_surface_count
d.mon start=cairo output=surface_count.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${MAP}_5
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${MAP}_4
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=${MAP}_3
d.frame -c frame=f_br at=0,$END,$START,100
#d.rast map=${MAP}_1
d.barscale units=meters style=solid length=${BAR_LENGTH} at=${BAR_AT}
# 35 is max count
d.legend -s -b raster=${MAP}_5 border_color=none at=4,95,79,89 #label_values=0,.10,.20,.30 range=0,.30 fontsize=10
d.mon stop=cairo

MAP=ff_relative_count
d.mon start=cairo output=relative_count.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${MAP}_5
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${MAP}_4
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=${MAP}_3
d.frame -c frame=f_br at=0,$END,$START,100
#d.rast map=${MAP}_1
d.barscale units=meters style=solid length=${BAR_LENGTH} at=${BAR_AT}
# 35 is max count
d.legend -s -b raster=${MAP}_5 border_color=none at=4,95,77,87 label_values=0,0.1,0.2,0.3,0.4,0.5 range=0,.50 fontsize=10
d.mon stop=cairo

d.mon start=cairo output=main_category.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=ff_series_05_max_raster
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=ff_series_15_max_raster
d.frame -c frame=f_bl at=0,$END,0,$END
#d.rast map=ff_series_05_max_raster_neighbors
d.barscale units=meters style=solid length=${BAR_LENGTH} at=${BAR_AT}
d.legend -b -c raster=ff_series_05_max_raster border_color=none at=10,100,65,75 fontsize=10
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=ff_series_15_max_raster_neighbors
d.mon stop=cairo

# 2x3 (2x4) image

DESIRED_WIDTH=600
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

FONTSIZE=20
BAR_LENGTH=200
BAR_AT=0,5
LEGEND_AT=10,85,2,12

# maps
for CLASS in 3 4 5
do
    MAP=ff_count_${CLASS}
    d.mon start=cairo output=${MAP}.png \
        width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.rast map=${MAP}
    d.mon stop=cairo

    MAP=ff_relative_count_${CLASS}
    d.mon start=cairo output=${MAP}.png \
        width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.rast map=${MAP}
    d.mon stop=cairo
done

# surface legend
d.mon start=cairo output=count_legend.png \
        width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
#d.barscale units=meters style=solid length=${BAR_LENGTH} \
#    at=${BAR_AT} fontsize=${FONTSIZE}
# flipping the integer legend
d.legend -s -b -f raster=ff_count_5 border_color=none at=${LEGEND_AT} \
    label_values=0,5,10,15,20 fontsize=${FONTSIZE} \
    title="Absolute count"
d.mon stop=cairo

# relative surface legend
d.mon start=cairo output=relative_count_legend.png \
        width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.barscale units=meters style=solid length=${BAR_LENGTH} \
    at=${BAR_AT} fontsize=${FONTSIZE}
d.legend -s -b raster=ff_relative_count_5 border_color=none at=${LEGEND_AT} \
    label_values=0,0.1,0.2,0.3,0.4,0.5 range=0,.50 fontsize=${FONTSIZE} \
    title="Relative count"
d.mon stop=cairo

# combine images
GEOMETRY="+6+2"
montage ff_count_[0-9].png count_legend.png \
    -geometry $GEOMETRY -tile x1 count_all.png
montage ff_relative_count_[0-9].png relative_count_legend.png \
    -geometry $GEOMETRY -tile x1 relative_count_all.png
montage count_all.png relative_count_all.png \
    -geometry $GEOMETRY -tile 1x counts_all.png
mogrify -trim counts_all.png
