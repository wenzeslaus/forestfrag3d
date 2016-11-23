#!/bin/bash

POINTS=/data/points.las

# bin in 3D
r3.in.lidar input=$POINTS n=n base_raster=ground -d class_filter=3,4,5
