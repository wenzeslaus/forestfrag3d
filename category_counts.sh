#!/bin/bash

r3.count.categories input=ff output=ff_count slices=ff_slice
r3.count.categories input=ff output=ff_surface_count slices=ff_slice surface=max_3_4_5_in_cells -s
r3.count.categories input=ff output=ff_relative_count slices=ff_slice surface=max_3_4_5_in_cells -d -s

r.colors map=`g.list rast pat="ff_slice_*" sep=,` raster_3d=ff

r.colors map=`g.list rast pat="ff_count_*" sep=,` rules=- <<EOF
0 23:18:105
5 238:81:76
10 252:148:63
30 244:243:68
100% 244:243:68
EOF

r.colors map=`g.list rast pat="ff_surface_count_*" sep=,` rules=- <<EOF
0 23:18:105
5 238:81:76
10 252:148:63
30 244:243:68
100% 244:243:68
EOF

r.colors map=`g.list rast pat="ff_relative_count_*" sep=,` rules=- <<EOF
0% 23:18:105
5% 238:81:76
10% 252:148:63
60% 244:243:68
100% 244:243:68
EOF
