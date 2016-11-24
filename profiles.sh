#!/bin/bash

r3.colors map=n rules=- <<EOF
0 220:246:255
1 255:255:0
100% 255:255:0
EOF

r3.colors map=reconstructed_01 rules=- <<EOF
0 220:246:255
1 0:128:0
EOF

POINT1="2091704.5,730249.0"
POINT2="2092141.0,730797.0"
COORDS="$POINT1,$POINT2"
# from high tree to SE lower trees
# 2091312.07692,730694.897436,2092148.84615,730230.025641

for MAP in n reconstructed_01 ff
do
    r3.profile input=${MAP} raster_output=${MAP}_profile coordinates=${COORDS}
    # TODO: do this in r3.profile
    r.colors map=${MAP}_profile  raster_3d=${MAP}
done

v.in.ascii input=- output=profile_points format=standard -n <<EOF
P 1 1
 ${POINT1/,/ }
 1 1
P 1 1
 ${POINT2/,/ }
 1 2
EOF

v.in.ascii input=- output=profile_line format=standard -n <<EOF
L 2 1
 ${POINT1/,/ }
 ${POINT2/,/ }
 1 1
EOF
