# Stealth Runner

![Stealth Runner](images/player.png) Stealth Runner is a third-person
open-world action game for the TI-99/4A home computer.

## Features

* Pre-rendered graphics.
* Smooth motion-captured animation (30 fps).
* Pixel-precise omni-directional scrolling.
* Sound and speech.
* Entirely written in TMS-9900 assembly code.
* The source code!

## Screenshots

![Title screen](screenshots/title.png)
![Standing](screenshots/standing.png)
![Walking](screenshots/walking.png)
![Running](screenshots/running.png)
![Charge](screenshots/charge.png)
![EMP](screenshots/emp.png)
![Explosion](screenshots/explosion.png)
![Drone](screenshots/drone.png)
![Turret](screenshots/turret.png)
   
You can also see a [video](https://youtu.be/e1ln8T1XRmM) on YouTube.

## Requirements

* TI-99/4A home computer.
* Programmable ROM/RAM cartridge, with about 1.5 MB of space.
* 32K memory expansion (optionally an internal one).
* Speech synthesizer (optional).
* Mechatronic mouse (optional).

or:

* An emulator for the TI-99/4A, such as Mame.

## Downloading

You can download the [latest
binary](https://github.com/EricLafortune/StealthRunner/releases/latest) from
GitHub.

## Building

If you want to build the game yourself, you'll need a couple of tools. These
are readily available for Linux distributions, but other platforms may work
as well.

* The 3D animation package [Blender](https://www.blender.org/) (Debian package
  `blender`), for rendering the player avatar and the objects in the game world.
* The image toolkit [ImageMagick](https://imagemagick.org/) (Debian package
  `imagemagick`), for processing animation frames.
* The video converter `ffmpeg` (Debian package `ffmpeg`), for processing sound
  files.
* The tool `xxd` (Debian package `xxd`), for converting simple hex source files
  to binary files.
* My [Video Tools](https://github.com/EricLafortune/VideoTools/) for the
  TI-99/4A, for computing speech coefficients and for creating the intro video.
* A Java development environment (Debian package `openjdk-17-jdk`, for example),
  version 14 or higher, for the video tools.
* The [xdt99](https://github.com/endlos99/xdt99) cross-development tools, for
  assembling the final video player.
* A Python 3 runtime environment (Debian package `python3`) for the
  cross-development tools.

On Linux, you can then run the build script:

    ./build.sh

Alternatively, you can run its commands manually.

You'll then have
* a raw cartridge ROM file `out/romc.bin`.
* a cartridge file `out/StealthRunner.rpk` that is suitable for emulators like
  Mame.

## Running

The easiest way is to use the Mame emulator (version 0.278 or higher).

On Linux, you can run the script to launch Mame with the proper options:

    ./run.sh

Alternatively, you can run the Mame command manually. The game targets an
NTSC system, with a display at 60 Hz. You can optionally enable the faster
_internal_ memory expansion, to improve the frame rate at busy moments
(<kbd>Scroll Lock</kbd>, if needed, to get in Mame's UI mode, and then
<kbd>Tab</kbd> > Machine Configuration > Console 32 KiB RAM upgrade (16 bit)
> On).

With the computer or emulator running, at the TI-99/4A home screen:

1. Press any key.
2. Press <kbd>2</kbd> for "STEALTH RUNNER".

The game then starts. The goal of the game is to find and reach the target
cross in the world, evading or destroying enemy devices. You may encounter:

|                                  |                                            |
|----------------------------------|--------------------------------------------|
| ![Target](images/target.png)     | The target to reach.                       |
| ![Stone](images/stone.png)       | Stone.                                     |
| ![Battery](images/battery.png)   | Battery charge for electromagnetic pulses. |
| ![Grenade](images/grenade.png)   | Grenade.                                   |
| ![Mine](images/mine.png)         | Enemy mine.                                |
| ![Drone](images/drone.png)       | Enemy drone.                               |
| ![Turret](images/turret.png)     | Enemy gun turret.                          |
| ![Launcher](images/launcher.png) | Enemy shell launcher.                      |

You can control your avatar with the keyboard and optionally a Mechatronic
mouse:

|                                  |                                                                  |
|----------------------------------|------------------------------------------------------------------|
| <kbd>Q</kbd>                     | Turn left.                                                       |
| <kbd>E</kbd>                     | Turn right.                                                      |
| <kbd>W</kbd>                     | Move forward.                                                    |
| <kbd>S</kbd>                     | Move backward.                                                   |
| <kbd>A</kbd>                     | Strafe left.                                                     |
| <kbd>D</kbd>                     | Strafe right.                                                    |
| <kbd>Shift</kbd>                 | Speed up from walking to running.                                |
| <kbd>X</kbd>                     | Swap the current weapon (stone, electromagnetic pulse, grenade). |
| <kbd>Enter</kbd>                 | Fire the current weapon.                                         |
| <kbd>Ctrl</kbd>                  | Apply a medkit after you've fallen.                              |
| Mouse                            | Turn.                                                            |
| Mouse button 1                   | Fire the current weapon.                                         |
| Mouse button 2                   | Swap the current weapon.                                         |
| <kbd>6</kbd> = <kbd>Proc'd</kbd> | Pause/unpause the game.                                          |
| <kbd>7</kbd> = <kbd>Aid</kbd>    | Restart at the last save point.                                  |
| <kbd>8</kbd> = <kbd>Redo</kbd>   | Start a new game.                                                |
| <kbd>9</kbd> = <kbd>Back</kbd>   | Return to the game title screen.                                 |
| <kbd>=</kbd> = <kbd>Quit</kbd>   | Return to the computer title screen.                             |
    
When you die, you can still press <kbd>Aid</kbd>, <kbd>Redo</kbd>,
<kbd>Back</kbd>, or <kbd>Quit</kbd>.

You can exit Mame by pressing <kbd>Scroll Lock</kbd> (if needed, to get in
Mame's UI mode) and then <kbd>Esc</kbd>.

## Technical background

The game tries to push the envelope of what is achievable on the TI-99/4A.
Can we deliver interactive, motion-captured, pre-rendered graphics, with the
help of freely available modern-day resources?

The implementation builds on my experiences with streaming graphics, sound,
and speech in my [Bad Apple](https://github.com/EricLafortune/BadApple) demo
for the TI-99/4a. The demo is linear; this game is fully interactive. The
general strategy is still to preprocess resources to efficient custom formats.

### Graphics

The player's avatar and its motion-captured animations originate from
[Mixamo](https://mixamo.com/). They have an amazing collection of 3D character
models and motion-captured animations, which can be downloaded for free.

I've imported the "SWAT" character and animations in the open-source animation
package [Blender](https://www.blender.org/). I've additionally created static
3D objects. The build process runs custom python scripts in Blender to render
the character and the objects. Each motion-captured animation has between 20
and 31 frames and is rendered from 16 viewing angles.

Further python/bash/java scripts/programs massage the resulting images. I'm
using the open-source toolkit [ImageMagick](https://imagemagick.org/) to
reduce the resolution and the number of colors, since the TI-99/4A supports a
fixed resolution of 256x192 pixels and a fixed palette of 16 colors. The
scripts eventually convert the images to efficient, custom file formats for
the game.

### Speech

The speech in the game is generated with AI text-to-speech conversion (on
[OpenAI.fm](https://www.openai.fm/)). It's an effective way to get consistent
and crisp sound files. I've then converted these files to speech coefficients
for the TMS5200 speech synthesizer of the TI, with my own open-source [Video
Tools](https://github.com/EricLafortune/VideoTools/docs/ConvertWavToLpc.md).

### Music

The music originates from freely available MusicXML files. Notably, I've
picked a segment from Mozart's piano concerto No 20 (K466) and converted it to
a format that is optimized for the TMS9919 sound chip of the TI, again with my
[Video
Tools](https://github.com/EricLafortune/VideoTools/docs/ConvertMusicXmlToSnd.md).
The conversion tool tries to squeeze all parts, bars and chords into the 3
available sound channels.

### Sound

I've manually created some simple sound effects for the sound chip of the TI.
They are hard-coded in the game's code.

### Video

I've created the short introductory animation sequence with Blender,
ImageMagick, and my Video Tools, building on the Mixamo models and the MusicXML
file.

### Game world

The game world is represented by a plain image file. A custom tool again
converts it to optimized formats that are then included in the application.

### Game code

The game's assembly code ties together all resulting assets. For low-level
code, it is still quite readable, thanks to macros and comments, and thanks to
the excellent [xdt99](https://github.com/endlos99/xdt99) cross-development
tools. The major challenge is to efficiently stream graphics to the video
display processor. The code tries to update just the changes between frames:
characters and patterns of the landscape, characters and patterns of the
player's avatar, positions and patterns of the sprites. Standard 16x16 pixel
sprites are combined into larger sprites. They are cached in the available
space in video memory and swapped in when necessary. The most
performance-sensitive code is run from the computer's 256 bytes of 16-bit
scratchpad RAM. The game interleaves all computations between even and odd
frames at 60 NTSC video frames per second, resulting in updates at 30 frames
per second.
        
The source code contains a collection of [include files](src/include) that
can be generally useful for game development. They provide convenient and
efficient support for graphics, sound, speech, and keyboard/mouse input.

## License

Stealth Runner is released under the GNU General Public License, version 2.

Enjoy!

Eric Lafortune
