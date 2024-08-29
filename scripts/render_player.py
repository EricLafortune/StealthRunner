# Blender script to render animated player sprites from multiple directions.
#
# Inspired by similar scripts:
#   FoozleCC:
#     https://foozlecc.itch.io/render-4-or-8-direction-sprites-from-blender
#
#   Robert Shenton:
#     https://robertshenton.co.za/blog/blender-render-script/
#
# First import the animation files:
#
# File > Import > FBX > (all .fbx animation files)
#
# For all imported animations:
#   Scene Collection > Collection > Armature > Animation > ...mixamo... > Rename to "Walking",...
#
#   To keep them in-place:
#     (bottom left) ooov (Editor type) > Dope Sheet
#     (selection) v (Editing context) > Action Editor
#     (bottom panel) Summary > mixamorig:Hips > X or Y or Z Location: uncheck
#
# Save as > "animations.blend"
#
# File > New > General
# File > Import > FBX > (the .fbx model file)
# File > Append... > "animations.blend" > Actions > (all actions)
# (bottom left) ooov (Editor type) > Dope Sheet
# (selection) v (Editing context) > Action Editor
# For all imported actions:
#   (bottom center) ooov (Browse action) > (action)
#   (bottom center) V (shield, Fake user)
#   (bottom left) Push Down
#
# For other objects:
#   Collection > New (set name, keep selected)
#   File > Import > FBX > (.fbx model, optionally set scale)
#
# Properties > Render > File > Transparent checkbox
# Camera: Data > Lens > Focal Length > 100mm

import bpy
import os
import math

# Define what we want to render.
armature_name = "Player"
action_names  = ["Run backward", "Walk backward", "Stand", "Walk", "Run", "Die backward", "Run strafe left", "Run strafe right", "Walk strafe left", "Walk strafe right" ]
angles        = 16
path          = os.path.abspath(os.path.join('out', 'animations', 'color', 'Player'))

# Set the scene.
scene = bpy.context.scene

scene.render.resolution_x = 256
scene.render.resolution_y = 256

# Find the player armature.
armature_collection = bpy.data.collections[armature_name]
armature_object     = bpy.context.scene.objects[armature_name]

# Set its rendering flag (affects all visible elements of the collection).
armature_collection.hide_render = False

# Loop over the requested actions.
for action_name in action_names:

    # Find the track and its only action.
    track  = armature_object.animation_data.nla_tracks[action_name]
    action = track.strips[0].action

    # Enable the track as only track (rather than enabling it or setting it as
    # active action).
    track.is_solo = True

    # Set/tweak the frames to render based on the action.
    match action_name:
        case "Stand":
            frames = range(1, 2)
        case "Die backward":
            frames = range(15, 100, 5)
        case _:
            frames = range(int(action.frame_range[0]),
                           int(action.frame_range[1]))

    # Compose a directory path for the animation of this action.
    action_directory = os.path.join(path, action.name.replace(" ", "_"))

    # Loop over all requested directions.
    for angle in range(0, angles, 1):

        # Compose a directory path for the action and for the angle.
        animation_directory = os.path.join(action_directory, str(angle).zfill(2))

        # Rotate the model for the new angle.
        armature_object.rotation_euler[2] = math.radians(360. * angle / angles)

        # Loop over all frames.
        for frame in frames:
            scene.frame_current = frame

            scene.render.filepath = os.path.join(animation_directory, str(frame).zfill(3))

            bpy.ops.render.render(animation   = False,
                                  write_still = True)

        # Reset the frame.
        scene.frame_current = 1

# Reset the rotation.
armature_object.rotation_euler[2] = 0
