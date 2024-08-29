# Blender script to render the short intro video.

import bpy
import os
import math

# Define what we want to render.
camera_name   = "IntroCamera"
armature_name = "Player"
action_name   = "Run intro"
frames        = range(1, 38)
path          = os.path.abspath(os.path.join('out', 'animations', 'color', 'Intro'))

# Set the scene.
scene = bpy.context.scene

scene.camera = bpy.data.objects[camera_name]

scene.render.resolution_x = 256
scene.render.resolution_y = 192

# Find the player armature.
armature_collection = bpy.data.collections[armature_name]
armature_object     = bpy.context.scene.objects[armature_name]

# Set its rendering flag (affects all visible elements of the collection).
armature_collection.hide_render = False

# Find the track (with a strip of actions).
track = armature_object.animation_data.nla_tracks[action_name]

# Enable the track as only track (rather than enabling it or setting it as active action).
track.is_solo = True

# Loop over all frames.
for frame in frames:
    scene.frame_current = frame

    scene.render.filepath = os.path.join(path, str(frame).zfill(3))

    bpy.ops.render.render(False, # undo support
                          animation=False,
                          write_still=True
                         )

# Reset the frame.
scene.frame_current = 1
