#!/bin/bash

r.relief input=ground output=relief

#r.contour -t --overwrite input=ground output=contours_full step=8.2021 cut=200
r.contour -t --overwrite input=ground output=contours_full step=3 cut=2
v.generalize --overwrite input=contours_full output=contours method=boyle threshold=500
