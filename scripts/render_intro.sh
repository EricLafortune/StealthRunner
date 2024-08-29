#!/bin/bash
#
# This script renders the intro animation using Blender.

blender \
  --background animations.blend \
  --python ${0%.sh}.py
