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
render_object('Target', 1)
render_object('Battery', 1)
render_object('Mine', 2)
render_object('Drone', 16)
render_object('Base', 1)
render_object('Cannon', 16)
render_object('Bullets', 16)
render_object('Explosion', 16)
