#!/bin/bash

# fine resolution for the surfaces
g.region res=1 -a

POINTS=/data/points.las

# import points with grid-based decimation
r.in.lidar input=$POINTS method=mean output=ground_bin class_filter=2
#r.in.lidar input=$POINTS method=max output=max_3_4_5_bin class_filter=3,4,5

r.to.vect in=ground_bin type=point out=ground_points -zbt
#r.to.vect in=max_3_4_5_bin type=point out=max_3_4_5_points -zbt

# interpolate surfaces
v.surf.rst input=ground_points elevation=ground
#v.surf.rst input=max_3_4_5_points elevation=max_3_4_5_surface

# 2D and 3D resolution same, same in all directions, and coarser
g.region res=3 res3=3 b=0 t=138 -a

# bin in 3D
r3.in.lidar input=$POINTS n=n base_raster=ground -d class_filter=3,4,5

r.in.lidar input=$POINTS output="n_3_4_5_3_f" method="n" type="FCELL" zscale=1.0 intensity_scale=1.0 percent=100 class_filter=3,4,5 res=3
