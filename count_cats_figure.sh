#!/bin/bash

# set up temporary region
WIND_OVERRIDE=count_category_explanation_region
g.region -u save=$WIND_OVERRIDE
export WIND_OVERRIDE

r.in.ascii input=- output=count_categories_explanation_cells <<EOF
north: 7
south: 0
east: 7
west: 0
rows: 7
cols: 7
* * * * * 1 *
* * * * * * *
* * * 1 * 1 *
* * 1 * * * *
1 1 1 1 * * 1
* 1 1 * * * 1
* * * * * * 1
EOF

# set region to the raster and one cell bellow
g.region raster=count_categories_explanation_cells

# create grid which only overlaps the region
v.mkgrid map=count_categories_explanation_grid position=region

# set region to the raster and one cell bellow
g.region s=s-1

export GRASS_FONT="DejaVu Sans:Book"
eval `g.region -g`

DESIRED_WIDTH=300
DESIRED_HEIGHT=`python -c "print $DESIRED_WIDTH / float($cols) * $rows"`

FONT_SIZE=7
GRID_WIDTH=1

v.in.ascii input=- format=standard -n output=count_categories_explanation_line <<EOF
L 7 1
 0 3
 0 3
 2 3
 2 4
 6 4
 6 3
 7 3
 1 1
EOF

r.colors map=count_categories_explanation_cells rules=- <<EOF
1 #ff9200
EOF

d.mon start=cairo output=count_categories.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=count_categories_explanation_cells
d.vect map=count_categories_explanation_grid \
    color=26:26:26 fill_color=none width=$GRID_WIDTH
# TODO: replace by geographical coordinates
d.text text="1" at=7.3,7.3 align=cc color=black size=$FONT_SIZE
d.text text="2" at=21.6,7.3 align=cc color=black size=$FONT_SIZE
d.text text="3" at=35.9,7.3 align=cc color=black size=$FONT_SIZE
d.text text="2" at=50.1,7.3 align=cc color=black size=$FONT_SIZE
d.text text="0" at=64.4,7.3 align=cc color=black size=$FONT_SIZE
d.text text="2" at=78.7,7.3 align=cc color=black size=$FONT_SIZE
d.text text="3" at=92.7,7.3 align=cc color=black size=$FONT_SIZE
d.mon stop=cairo

d.mon start=cairo output=count_categories_surface.png width=$DESIRED_WIDTH height=$DESIRED_HEIGHT
d.erase  # previous image is not cleaned
d.rast map=count_categories_explanation_cells
d.vect map=count_categories_explanation_grid \
    color=26:26:26 fill_color=none width=$GRID_WIDTH
d.vect map=count_categories_explanation_line color=0:29:90 width=8
# TODO: replace by geographical coordinates
d.text text="1" at=7.3,7.3 align=cc color=black size=$FONT_SIZE
d.text text="2" at=21.6,7.3 align=cc color=black size=$FONT_SIZE
d.text text="2" at=35.9,7.3 align=cc color=black size=$FONT_SIZE
d.text text="1" at=50.1,7.3 align=cc color=black size=$FONT_SIZE
d.text text="0" at=64.4,7.3 align=cc color=black size=$FONT_SIZE
d.text text="0" at=78.7,7.3 align=cc color=black size=$FONT_SIZE
d.text text="3" at=92.7,7.3 align=cc color=black size=$FONT_SIZE
d.mon stop=cairo

# TODO: trim fails as there is something left on the sides
mogrify -trim count_categories.png count_categories_surface.png

# remove temporary region
g.remove -f type=region name=$WIND_OVERRIDE
unset WIND_OVERRIDE
