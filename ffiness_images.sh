#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"

eval `g.region -g`

# we need more than 500 because of whitespace and trimming
DESIRED_WIDTH=560
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

# Paul Tol's Alternative Scheme for Qualitative Data
# main colors
C1=#4477AA
C2=#66CCEE
C3=#228833
C4=#CCBB44
C5=#EE6677
C6=#AA3377
# gray from the middle (also black suggested)
C7=#BBBBBB
# most different colors from the main palette
C8=#332288
C9=#44AA99
C10=#999933

LINE_WIDTH=3
YTICS="0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8"
LEGEND_POS=80,95

CATS=`v.category zones -g op=print | sort -g | uniq`

# zone colors according to category (max 10 categories)
ZONE_COLORS=""
> legend.txt  # ensures empty existing file
for C in ${COLORS//,/ }; do echo "1|legend/line|5|ps|$C|$C|$LINE_WIDTH|line|1"; done
for CAT in $CATS
do
    eval "COLOR=\$C$CAT"
    ZONE_COLORS+="$COLOR,"
    echo "$CAT|legend/line|5|ps|$COLOR|$COLOR|$LINE_WIDTH|line|1" >> legend.txt
done
ZONE_COLORS=${ZONE_COLORS%?}

seq 1 1 46 > x.txt

COMMON_OPTIONS="width=$LINE_WIDTH ytics=$YTICS" # y_range=0,0.6

for F in 0 1 2 3 4 5
do
    MAP=ff_${F}_slice
    for CAT in ${CATS}
    do
        v.db.select zones sep="\n" \
            col=`g.list rast p="${MAP}_*" sep=_average,`_average \
            -c where="cat = ${CAT}" > file_${MAP}_cat_${CAT}.txt
        d.mon start=cairo output=zonal_plot_${MAP}_${CAT}.png \
            width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
        d.erase  # previous image is not cleaned
        d.linegraph x_file=x.txt y_file=file_${MAP}_cat_${CAT}.txt $COMMON_OPTIONS
        d.mon stop=cairo
    done
    d.mon start=cairo output=zonal_plot_${MAP}.png \
        width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x.txt \
        y_file=`ls file_${MAP}_cat_*.txt -1v | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
        $COMMON_OPTIONS y_color=$ZONE_COLORS
    d.legend.vect at=$LEGEND_POS input=legend.txt
    d.mon stop=cairo
done

# combine images

GEOMETRY="+12+4"

# combine abs surface and rel into one
# trim white edges
mogrify -trim zonal_plot_ff_4_slice.png zonal_plot_ff_5_slice.png
montage zonal_plot_ff_4_slice.png zonal_plot_ff_5_slice.png \
    -geometry $GEOMETRY -tile 2x zonal_plot_ff_slice_percentage.png
