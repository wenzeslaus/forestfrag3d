#!/bin/bash

r3.to.rast input=n output=n_slice
# TODO: unify naming
r3.to.rast input=reconstructed output=mean_slice
r3.to.rast input=pf output=pf_slice
r3.to.rast input=pff output=pff_slice
