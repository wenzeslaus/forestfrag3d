#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"

seq 1 1 46 > x.txt
seq 0 1 5 > x_count.txt

eval `g.region -g`

DESIRED_WIDTH=500
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`
START=50.2
END=49.8

# cubehelix
C1=26:24:52
C2=21:69:78
C3=43:111:57
C4=116:122:50
C5=193:121:111
C6=211:143:197
C7=194:193:242
C8=206:235:239

# named
C1=orange
C2=red
C3=blue
C4=green
C5=violet
C6=aqua
C7=magenta
C8=brown
C9=194:193:242
C10=43:111:57

# Palettable CB Paired_10 (not printable, not blind)
C1=#A6CEE3
C2=#1F78B4
C3=#B2DF8A
C4=#33A02C
C5=#FB9A99
C6=#E31A1C
C7=#FDBF6F
C8=#FF7F00
C9=#CAB2D6
C10=#6A3D9A

COLORS="y_color=$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$C10"
LINE_WIDTH=3
YTICS="0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0"

cat > legend.txt <<EOF
1|legend/line|5|ps|$C1|$C1|$LINE_WIDTH|line|1
2|legend/line|5|ps|$C2|$C2|$LINE_WIDTH|line|1
3|legend/line|5|ps|$C3|$C3|$LINE_WIDTH|line|1
4|legend/line|5|ps|$C4|$C4|$LINE_WIDTH|line|1
5|legend/line|5|ps|$C5|$C5|$LINE_WIDTH|line|1
6|legend/line|5|ps|$C6|$C6|$LINE_WIDTH|line|1
7|legend/line|5|ps|$C7|$C7|$LINE_WIDTH|line|1
8|legend/line|5|ps|$C8|$C8|$LINE_WIDTH|line|1
9|legend/line|5|ps|$C9|$C9|$LINE_WIDTH|line|1
10|legend/line|5|ps|$C10|$C10|$LINE_WIDTH|line|1
EOF

COLORS4="y_color=$C2,$C4,$C6,$C8"

cat > legend_n_m_pff.txt <<EOF
n|legend/line|5|ps|$C2|$C2|$LINE_WIDTH|line|1
mean|legend/line|5|ps|$C4|$C4|$LINE_WIDTH|line|1
pf|legend/line|5|ps|$C6|$C6|$LINE_WIDTH|line|1
pff|legend/line|5|ps|$C8|$C8|$LINE_WIDTH|line|1
EOF

COMMON_OPTIONS="width=$LINE_WIDTH ytics=$YTICS" # y_range=0,0.6

MAP="ff_slice"
OPTIONS="y_range=0,5 width=$LINE_WIDTH"

for CAT in `v.category zones -g op=print | sort | uniq`
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
    y_file=`ls file_ff_slice_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $COLORS $OPTIONS
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

MAP="ff_count"
OPTIONS="y_range=0,40 width=$LINE_WIDTH"

for CAT in `v.category zones -g op=print | sort | uniq`
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
    y_file=`ls file_${MAP}_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $OPTIONS $COLORS
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

MAP="ff_surface_count"
OPTIONS="y_range=0,20 width=$LINE_WIDTH"

for CAT in `v.category zones -g op=print | sort | uniq`
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
    y_file=`ls file_${MAP}_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $OPTIONS $COLORS
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

MAP="ff_relative_count"
OPTIONS="y_range=0,0.65 y_tics=$YTICS width=$LINE_WIDTH"

for CAT in `v.category zones -g op=print | sort | uniq`
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
    y_file=`ls file_${MAP}_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
    $OPTIONS $COLORS
d.legend.vect at=85,98 input=legend.txt
d.mon stop=cairo

OPTIONS="y_range=0,0.5 y_tics=$YTICS width=$LINE_WIDTH"

for MAP in "n_slice" "mean_slice"
do
    for CAT in `v.category zones -g op=print | sort | uniq`
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
    for CAT in `v.category zones -g op=print | sort | uniq`
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

for CAT in `v.category zones -g op=print | sort | uniq`
do
    d.mon start=cairo output=zonal_plot_n_mean_pf_pff_zone_$CAT.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
    d.erase  # previous image is not cleaned
    d.linegraph x_file=x.txt y_file=file_n_slice_$CAT.txt,file_mean_slice_$CAT.txt,file_pf_slice_$CAT.txt,file_pff_slice_$CAT.txt $OPTIONS $COLORS4
    d.legend.vect at=85,98 input=legend_n_m_pff.txt
    d.mon stop=cairo
done

exit

# needs support for > 10 files
d.mon start=cairo output=zonal_plot_all.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.linegraph x_file=x.txt y_file=`ls file_n_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'`,`ls file_mean_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'`,`ls file_pf_slice_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'`,`ls file_pff_slice_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'` y_color=$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8
d.mon stop=cairo
