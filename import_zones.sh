#!/bin/bash

if [ -z "$1" ]
then
    >&2 echo "ERROR: $0 requires one parameter, but got an invalid one: $1"
    exit 1
fi

INPUT=$1

v.in.ascii input=$INPUT output=zones_full format=standard
v.in.region output=region
# storing the original categories
v.overlay ainput=zones_full binput=region operator=and output=zones olayer=0,1,0 -t
# we use -t and create an empty table now
v.db.addtable zones
