#!/bin/bash

r.relief input=ground output=relief

r.neighbors input=ground output=ground_smooth method=average size=21

r.contour -t --overwrite input=ground_smooth output=contours_full step=8 cut=200
v.generalize --overwrite input=contours_full output=contours method=boyle threshold=500
