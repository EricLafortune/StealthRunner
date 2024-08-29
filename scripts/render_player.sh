#!/bin/bash
#
# This script renders the player animations using Blender.

blender \
  --background animations.blend \
  --python ${0%.sh}.py
