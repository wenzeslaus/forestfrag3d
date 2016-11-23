#!/bin/bash

export GRASS_OVERWRITE=1

#v.db.droptable map=classes layer=2 -f
#v.db.addtable map=classes layer=2

for C in 0 1 2 3 4 5
do
    for MAP in `g.list rast p="ff_${C}_slice_*"`
    do
        v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
    done
done
