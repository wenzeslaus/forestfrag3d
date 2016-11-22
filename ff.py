#!/usr/bin/env python

import grass.script as gs

# TODO: unify naming
mean = 'reconstructed'
mean_01 = 'reconstructed_01'
ff = "ff"
pf = "pf"
pff = "pff"

gs.run_command('r3.neighbors', input='n', output=mean,
               method='average', window='3,3,3')
gs.run_command(
    'r3.mapcalc',
    expression="{mean_01} = if({mean} > 0, 1, 0)".format(
        mean=mean, mean_01=mean_01))
gs.run_command('r3.forestfrag', input=mean_01, out=ff, pf=pf, pff=pff,
               color='perceptual')
