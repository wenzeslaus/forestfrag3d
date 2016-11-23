#!/bin/bash

POINTS=/data/points.las

r.in.lidar input=$POINTS method=max output=max_3_4_5 base_raster=ground -d class_f=3,4,5
r.in.lidar input=$POINTS method=n output=n_3_4_5 class_f=3,4,5
r.to.vect input=max_3_4_5 output=max_3_4_5 type=point -zbt

# TODO: perhaps mask using clumping the zero areas and throwing out the small ones
g.copy raster=n_3_4_5,n_3_4_5_nulls
r.null map=n_3_4_5_nulls setnull=0
r.grow input=n_3_4_5_nulls output=n_3_4_5_mask radius=15 old=1 new=1
r.mapcalc "n_3_4_5_mask_nulls_inverted = if(isnull(n_3_4_5_mask), 1, null())"
r.grow input=n_3_4_5_mask_nulls_inverted output=n_3_4_5_mask_inverted radius=17 old=1 new=1
r.null map=n_3_4_5_mask_inverted null=0

r.mask raster=n_3_4_5_mask_inverted maskcats=0

v.surf.rst input=max_3_4_5 \
    elevation=max_3_4_5_surface slope=max_3_4_5_surface_slope aspect=max_3_4_5_surface_aspect \
    npmin=30 segmax=10 tension=10 smooth=10

r.mask -r

r.mapcalc "max_3_4_5_surface_masked = if(n_3_4_5_mask_inverted == 1, 0, max_3_4_5_surface)"

# max depth
MAX=46

# TODO: should 0 height in r3.count.categories mean that you should not divide
# TODO: should the divide in r3.count.categories be +1 because we want to allow 0?
# TODO: should r3.count.categories somehow take into account the numbering of depths from 1? (as opposed to 0)

# TODO: adding one, as first depth is 0, but theoretically, this might/should be null
r.mapcalc "max_3_4_5_in_cells = eval(a = (max_3_4_5_surface_masked / 3.) + 1, int(if(a < 1, 1, if(a > ${MAX}, ${MAX}, a))))"

r.colors map=max_3_4_5_surface_masked color=grass -n
r.colors map=max_3_4_5_in_cells color=grass -n
