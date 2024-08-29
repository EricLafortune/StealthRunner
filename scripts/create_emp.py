#!/usr/bin/python3
#
# Prints out ImageMagick commands for an expanding circle of dots centered
# around the player, representing an electromagnetic pulse (EMP).

import sys
import math as m

angle                = int(sys.argv[1])
angle_discretisation = int(sys.argv[2])
dot_count            = int(sys.argv[3])
dot_discretisation   = int(sys.argv[4])
radius               = float(sys.argv[5]) - 0.5

for dot in range(0, dot_count):

  angle_rad = 2. * m.pi * (angle / angle_discretisation +
                           (dot - dot_count/2 + 0.5) / dot_discretisation)

  x = round(63.5 + m.sin(angle_rad) * radius             )
  y = round(63.5 + m.cos(angle_rad) * radius /  m.sqrt(2))

  #if m.cos(angle_rad) < 0 or m.fabs(m.sin(angle_rad)) * radius > 10:
  #  print(f'point {x:d},{y:d}')
  print(f'point {x:d},{y:d}')
