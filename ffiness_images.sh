#!/bin/bash

export GRASS_FONT="DejaVu Sans:Book"

eval `g.region -g`

DESIRED_WIDTH=500
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

# some cubehelix
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

ZONE_COLORS="$C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$C10"
LINE_WIDTH=3
YTICS="0.0,0.1,0.2,0.3,0.4,0.5"

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

CATS=`v.category zones -g op=print | sort | uniq`

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
        y_file=`ls file_${MAP}_cat_*.txt -1 | tr '\n' ',' | sed 's/\(.*\),/\1/'` \
        $COMMON_OPTIONS y_color=$ZONE_COLORS
    d.legend.vect at=85,98 input=legend.txt
    d.mon stop=cairo
done
