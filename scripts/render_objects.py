# Blender script to render animated object sprites from multiple directions.
#
# Inspired by similar scripts:
#   FoozleCC:
#     https://foozlecc.itch.io/render-4-or-8-direction-sprites-from-blender
#
#   Robert Shenton:
#     https://robertshenton.co.za/blog/blender-render-script/

import bpy
import os
import math

# Renders the specified object (or part of an object) from the given number
# of angles (or in the given number of animation states).
def render_object(name, angles):

    # Find the named (part of an) object.
    armature_collection = bpy.data.collections[name]

    if name in bpy.context.scene.objects:
        armature_object = bpy.context.scene.objects[name]
    else:
        armature_object = armature_collection

    # Set its rendering flag (affects all visible elements of the collection).
    armature_collection.hide_render = False

    # Compose the output directory path.
    path = os.path.abspath(os.path.join('out', 'animations', 'color', name))

    # Loop over all requested directions.
    for angle in range(0, angles, 1):

        # Animate the model, e.g. the explosion.
        scene.frame_current = angle + 1

        # Rotate the model, e.g. the drone.
        if hasattr(armature_object, 'rotation_euler'):
            armature_object.rotation_euler[2] = math.radians(360. * angle / angles)

        scene.render.filepath = os.path.join(path, str(angle).zfill(2))

        bpy.ops.render.render(animation   = False,
                              write_still = True)

    # Reset the rotation.
    if hasattr(armature_object, 'rotation_euler'):
        armature_object.rotation_euler[2] = 0

    # Reset the frame.
    scene.frame_current = 1
    
    # Reset the rendering flag.
    armature_collection.hide_render = True

# Set the scene.
scene = bpy.context.scene

scene.render.resolution_x = 256
scene.render.resolution_y = 256

# Render all relevant objects in the input file.
render_object('Grass', 1)
render_object('Trunk', 1)
render_object('Stump', 1)
render_object('Rock', 1)
render_object('Puddle', 1)
render_object('Wood', 1)
render_object('Fence', 1)
render_object('Tripod', 1)
render_object('Barrel', 1)
render_object('Manhole', 1)
render_object('Bricks', 1)
render_object('Pylon', 1)
render_object('Target', 1)
render_object('Medkit', 1)
render_object('Battery', 1)
render_object('Mine', 2)
render_object('Drone', 16)
render_object('Base', 1)
render_object('Cannon', 16)
render_object('Launcher', 1)
render_object('Shell', 1)
render_object('Explosion', 16)
render_object('Tombstone', 1)

# Also render the player dangling from parachute lines.

# Shift the camera, so we see more of the lines.
camera_name = "Camera"

camera = bpy.data.cameras[camera_name]
camera.shift_y = 0.4

# Put the player in a dangling pose.
player_name = "Player"
action_name = "Hang"

player_collection = bpy.data.collections[player_name]
player_object     = bpy.context.scene.objects[player_name]
track             = player_object.animation_data.nla_tracks[action_name]
track.is_solo = True

# Enable rendering the lines, rotated so they come out right with the player
# rotated.
lines_name = "Lines"

lines_collection = bpy.data.collections[lines_name]
lines_object     = bpy.data.objects[lines_name]

lines_collection.hide_render = False
lines_object.rotation_euler[2] = math.radians(180.)
#lines_object.parent = player_object

render_object('Player', 2)
