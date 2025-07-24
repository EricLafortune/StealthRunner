#!/bin/bash
#
# This script converts music from MusicXML format to our binary SND format.

INPUT_DIR=${1:-music}
OUTPUT_DIR=${2:-out}

mkdir -p $OUTPUT_DIR

java ConvertMusicXmlToSnd \
  -startmeasure 93 \
  -endmeasure 115 \
  -part 'Fl.'              -chordnotes 1 -transpose 0 -attenuate 3 -instrument piano \
  -part 'Ob.'              -chordnotes 1 -transpose 0 -attenuate 3 -instrument piano \
  -part 'Bsn.'             -chordnotes 1 -transpose 0 -attenuate 3 -instrument piano \
  -part 'F Hn.'            -chordnotes 1 -transpose 0 -attenuate 3 -instrument piano \
  -part 'B♭ Cnt.'          -chordnotes 1 -transpose 0 -attenuate 3 -instrument piano \
  -part 'Timp.'            -chordnotes 1 -transpose 0 -attenuate 3 -instrument bass_drum \
  -part 'P7'               -chordnotes 1 -transpose 0 -attenuate 0 -instrument piano \
  -part 'P8'      -voice 1 -chordnotes 1 -transpose 0 -attenuate 0 -instrument piano \
  -part 'P9'               -chordnotes 1 -transpose 0 -attenuate 0 -instrument piano \
  -part 'P10'              -chordnotes 1 -transpose 0 -attenuate 2 -instrument piano \
  -part 'P11'              -chordnotes 1 -transpose 0 -attenuate 2 -instrument piano \
  -part 'Vlas.'            -chordnotes 1 -transpose 0 -attenuate 2 -instrument piano \
  -part 'Vcs.'             -chordnotes 1 -transpose 0 -attenuate 2 -instrument piano \
  -part 'Cb.'              -chordnotes 1 -transpose 0 -attenuate 2 -instrument piano \
  $INPUT_DIR/PianoConcerto20_1.xml \
  $OUTPUT_DIR/PianoConcerto20_1.snd
