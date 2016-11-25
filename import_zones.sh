#!/bin/bash

if [ -z "$1" ]
then
    >&2 echo "$0 requires one parameter but got an invalid one: $1"
    exit 1
fi

INPUT=$1

v.in.ascii input=$INPUT output=zones_full format=standard
v.in.region output=region
v.overlay ainput=zones_full binput=region operator=and output=zones
