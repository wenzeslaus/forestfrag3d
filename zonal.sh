#!/bin/bash

v.db.addtable zones

for MAP in `g.list rast p="ff_slice_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="pf_slice_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="pff_slice_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="ff_count_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="ff_surface_count_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="ff_relative_count_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="n_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done

for MAP in `g.list rast p="mean_*"`
do
    v.rast.stats map=zones raster=$MAP column_prefix=$MAP method=average,stddev
done
