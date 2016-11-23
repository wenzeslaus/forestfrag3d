#!/bin/bash

POINTS=/data/points.las

# import points with grid-based decimation
r.in.lidar input=$POINTS method=mean output=ground_bin class_filter=2
#r.in.lidar input=$POINTS method=max output=max_3_4_5_bin class_filter=3,4,5

r.to.vect in=ground_bin type=point out=ground_points -zbt
#r.to.vect in=max_3_4_5_bin type=point out=max_3_4_5_points -zbt

# interpolate surfaces
v.surf.rst input=ground_points elevation=ground
#v.surf.rst input=max_3_4_5_points elevation=max_3_4_5_surface

