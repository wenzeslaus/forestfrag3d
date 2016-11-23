#!/bin/bash

for C in 0 1 2 3 4 5
do
    r3.mapcalc "ff_${C} = ff == ${C}"
done

wait

for C in 0 1 2 3 4 5
do
    r3.to.rast in=ff_${C} out=ff_${C}_slice type=CELL
done
