#!/bin/bash

export GRASS_OVERWRITE=1
export GRASS_FONT=sans
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

BAR_LENGTH=200

# TODO: fix ff and slicing, so we have a color table here
r.colors map=`g.list raster -e pattern="^ff_slice_[0-9]+" sep=comma` rules=- <<EOF
#0 245:244:68
0 173:216:230
1 35:60:37
2 172:92:80
3 192:126:73
4 157:182:90
5 107:214:72
6 195:233:82
EOF


START=50.2
END=49.8

d.mon start=cairo output=hslice.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=ff_slice_00005
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=ff_slice_00015
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=ff_slice_00025
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=ff_slice_00035
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
START=50.2
END=49.8
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
#d.rast map=ff_count_interior
d.rast map=ff_count_5
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=ff_count_4
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=ff_count_3
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=ff_count_1
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

d.mon start=cairo output=surface_count.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
START=50.2
END=49.8
MAP=ff_surface_count
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${MAP}_5
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${MAP}_4
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=${MAP}_3
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=${MAP}_1
# 35 is max count
d.legend -s -b raster=${MAP}_5 border_color=none at=4,95,79,89 #label_values=0,.10,.20,.30 range=0,.30 fontsize=10
d.mon stop=cairo

d.mon start=cairo output=relative_count.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
START=50.2
END=49.8
MAP=ff_relative_count
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=${MAP}_5
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=${MAP}_4
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=${MAP}_3
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=${MAP}_1
# 35 is max count
d.legend -s -b raster=${MAP}_5 border_color=none at=4,95,77,87 label_values=0,0.1,0.2,0.3,0.4,0.5 range=0,.50 fontsize=10
d.mon stop=cairo

d.mon start=cairo output=main_category.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
START=50.2
END=49.8
d.erase  # previous image is not cleaned
d.frame -c frame=f_tl at=$START,100,0,$END
d.rast map=ff_series_05_max_raster
d.barscale units=meters style=solid length=${BAR_LENGTH} at=0,100
d.frame -c frame=f_tr at=$START,100,$START,100
d.rast map=ff_series_15_max_raster
d.frame -c frame=f_bl at=0,$END,0,$END
d.rast map=ff_series_05_max_raster_neighbors
d.legend -b -c raster=ff_series_05_max_raster border_color=none at=10,100,65,75 fontsize=10
d.frame -c frame=f_br at=0,$END,$START,100
d.rast map=ff_series_15_max_raster_neighbors
d.mon stop=cairo
