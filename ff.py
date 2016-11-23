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

# TODO: put this color table to r3.forestfrag?
gs.write_command('r3.colors', map=ff, rules='-', stdin="""
0 220:246:255
1 35:60:37
2 172:92:80
3 192:126:73
4 157:182:90
5 107:214:72
6 195:233:82
""")
