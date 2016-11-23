#!/bin/bash

POINTS=/data/points.las

r.in.lidar input=$POINTS output=n_3_4_5_3_f method=n class_filter=3,4,5

r.colors map=n_3_4_5_3_f color=viridis -e
