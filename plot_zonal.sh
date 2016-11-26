#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"

seq 1 1 46 > x.txt
seq 0 1 5 > x_count.txt

eval `g.region -g`

DESIRED_WIDTH=500
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
YTICS="0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0"

CATS=`v.category zones -g op=print | sort -g | uniq`

# zone colors according to category (max 10 categories)
ZONE_COLORS="y_color="
> legend.txt  # ensures empty existing file
for C in ${COLORS//,/ }; do echo "1|legend/line|5|ps|$C|$C|$LINE_WIDTH|line|1"; done
for CAT in $CATS
do
    eval "COLOR=\$C$CAT"
    ZONE_COLORS+="$COLOR,"
    echo "$CAT|legend/line|5|ps|$COLOR|$COLOR|$LINE_WIDTH|line|1" >> legend.txt
done
ZONE_COLORS=${ZONE_COLORS%?}

# order according to Paul Tol
COLORS4="y_color=$C1,$C5,$C3,$C4"

cat > legend_n_pf_pff.txt <<EOF
n|legend/line|5|ps|$C1|$C1|$LINE_WIDTH|line|1
pf|legend/line|5|ps|$C5|$C5|$LINE_WIDTH|line|1
pff|legend/line|5|ps|$C3|$C3|$LINE_WIDTH|line|1
EOF

COMMON_OPTIONS="width=$LINE_WIDTH ytics=$YTICS" # y_range=0,0.6

MAP="ff_slice"
OPTIONS="y_range=0,5 width=$LINE_WIDTH"

for CAT in ${CATS}
do
    v.db.select zones sep="\n" col=`g.list rast p="${MAP}_*" sep=_average,`_average -c where="cat = ${CAT}" > file_${MAP}_${CAT}.txt
    d.mon start=cairo output=zonal_plot_${MAP}_${CAT}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x.txt y_file=file_${MAP}_${CAT}.txt $OPTIONS
#    d.linegraph x_file=file_$CAT.txt y_file=x.txt # why this doesn't work?
    d.mon stop=cairo
done

# requires fix in d.linegraph for >10 colors
d.mon start=cairo output=zonal_plot_${MAP}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.linegraph x_file=x.txt \
    y_file=`ls file_ff_slice_*.txt -1v | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    ${ZONE_COLORS} $OPTIONS
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

MAP="ff_count"
OPTIONS="y_range=0,40 width=$LINE_WIDTH"

for CAT in ${CATS}
do
    v.db.select zones sep="\n" col=`g.list rast p="${MAP}_*" sep=_average,`_average -c where="cat = $CAT" > file_${MAP}_$CAT.txt
    d.mon start=cairo output=zonal_plot_${MAP}_$CAT.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x_count.txt y_file=file_${MAP}_$CAT.txt $OPTIONS
    d.mon stop=cairo
done

# requires fix in d.linegraph for >10 colors
d.mon start=cairo output=zonal_plot_${MAP}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.linegraph x_file=x_count.txt \
    y_file=`ls file_${MAP}_*.txt -1v | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $OPTIONS ${ZONE_COLORS}
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

MAP="ff_surface_count"
OPTIONS="y_range=0,20 width=$LINE_WIDTH"

for CAT in ${CATS}
do
    v.db.select zones sep="\n" col=`g.list rast p="${MAP}_*" sep=_average,`_average -c where="cat = $CAT" > file_${MAP}_$CAT.txt
    d.mon start=cairo output=zonal_plot_${MAP}_$CAT.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x_count.txt y_file=file_${MAP}_$CAT.txt $OPTIONS
    d.mon stop=cairo
done

# requires fix in d.linegraph for >10 colors
d.mon start=cairo output=zonal_plot_${MAP}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.linegraph x_file=x_count.txt \
    y_file=`ls file_${MAP}_*.txt -1v | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $OPTIONS ${ZONE_COLORS}
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

MAP="ff_relative_count"
OPTIONS="y_range=0,0.65 y_tics=$YTICS width=$LINE_WIDTH"

for CAT in ${CATS}
do
    v.db.select zones sep="\n" col=`g.list rast p="${MAP}_*" sep=_average,`_average -c where="cat = $CAT" > file_${MAP}_$CAT.txt
    d.mon start=cairo output=zonal_plot_${MAP}_$CAT.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x_count.txt y_file=file_${MAP}_$CAT.txt $OPTIONS
    d.mon stop=cairo
done

# requires fix in d.linegraph for >10 colors
d.mon start=cairo output=zonal_plot_${MAP}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.linegraph x_file=x_count.txt \
    y_file=`ls file_${MAP}_*.txt -1v | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $OPTIONS ${ZONE_COLORS}
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

OPTIONS="y_range=0,0.5 y_tics=$YTICS width=$LINE_WIDTH"

for MAP in "n_slice" "mean_slice"
do
    for CAT in ${CATS}
    do
        # TODO: are we right when replacing NULL by 0? (pff maps)
        v.db.select zones sep="\n" col=`g.list rast p="${MAP}_*" sep=_average,`_average -c where="cat = ${CAT}" null_value=0 > file_${MAP}_${CAT}.txt
        d.mon start=cairo output=zonal_plot_${MAP}_${CAT}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
        d.erase  # previous image is not cleaned
        d.linegraph x_file=x.txt y_file=file_${MAP}_${CAT}.txt $OPTIONS
        d.mon stop=cairo
    done
done

OPTIONS="y_range=0,1 y_tics=$YTICS width=$LINE_WIDTH"

for MAP in "pf_slice" "pff_slice"
do
    for CAT in ${CATS}
    do
        # TODO: are we right when replacing NULL by 0? (pff maps)
        v.db.select zones sep="\n" col=`g.list rast p="${MAP}_*" sep=_average,`_average -c where="cat = ${CAT}" null_value=0 > file_${MAP}_${CAT}.txt
        d.mon start=cairo output=zonal_plot_${MAP}_${CAT}.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
        d.erase  # previous image is not cleaned
        d.linegraph x_file=x.txt y_file=file_${MAP}_${CAT}.txt $OPTIONS
        d.mon stop=cairo
    done
done

OPTIONS="y_range=0,1 y_tics=$YTICS width=$LINE_WIDTH"

for CAT in ${CATS}
do
    d.mon start=cairo output=zonal_plot_n_pf_pff_zone_$CAT.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x.txt y_file=file_n_slice_$CAT.txt,file_pf_slice_$CAT.txt,file_pff_slice_$CAT.txt $OPTIONS $COLORS4
    d.legend.vect at=85,98 input=legend_n_pf_pff.txt
    d.mon stop=cairo
done
