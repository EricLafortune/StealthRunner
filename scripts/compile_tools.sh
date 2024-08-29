#!/bin/bash
#
# This script compiles the Java tools that compress the various game assets,

javac \
  -sourcepath src \
  -d out \
  src/*.java
