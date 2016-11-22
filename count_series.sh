#!/bin/bash

r.series input=`g.list type=rast -e patt="^ff_surface_count_[0-5]" m=. sep=comma` \
    output=ff_series_05_min_raster,ff_series_05_max_raster \
    method=min_raster,max_raster

r.series input=`g.list type=rast -e patt="^ff_surface_count_[1-5]" m=. sep=comma` \
    output=ff_series_15_min_raster_14,ff_series_15_max_raster_14 \
    method=min_raster,max_raster

r.recode input=ff_series_15_max_raster_14 output=ff_series_15_max_raster rules=- <<EOF
0:0:1
1:1:2
2:2:3
3:3:4
4:4:5
EOF

r.colors map=ff_series_05_max_raster raster_3d=ff
r.colors map=ff_series_15_max_raster raster_3d=ff

N=13

r.neighbors input=ff_series_05_max_raster \
    output=ff_series_05_max_raster_neighbors \
    method=mode size=$N -c

r.neighbors input=ff_series_15_max_raster \
    output=ff_series_15_max_raster_neighbors \
    method=mode size=$N -c

r.category map=ff_series_05_max_raster separator=space rules=- << EOF
0 exterior
1 patch
2 transitional
3 edge
4 perforated
5 interior
6 undetermined
EOF

r.category map=ff_series_15_max_raster separator=space rules=- << EOF
0 exterior
1 patch
2 transitional
3 edge
4 perforated
5 interior
6 undetermined
EOF

r.category map=ff_series_05_max_raster_neighbors separator=space rules=- << EOF
0 exterior
1 patch
2 transitional
3 edge
4 perforated
5 interior
6 undetermined
EOF

r.category map=ff_series_15_max_raster_neighbors separator=space rules=- << EOF
0 exterior
1 patch
2 transitional
3 edge
4 perforated
5 interior
6 undetermined
EOF
