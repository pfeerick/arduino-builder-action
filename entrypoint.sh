#!/bin/sh
set -e

BUILDER_PATH="/opt/arduino"
LIBRARIES_PATH="$BUILDER_PATH/libraries:$GITHUB_WORKSPACE/../"

SKETCH_PATH="$INPUT_SKETCH"
BOARD_NAME="$INPUT_BOARD"
SKETCH_DIRECTORY_PATH="$INPUT_SKETCHDIRECTORY"

if [ -d "$INPUT_LIBRARIES" ]; then
    LIBRARIES_PATH="$LIBRARIES_PATH:$INPUT_LIBRARIES"
fi

getLibraryOptions() {
    local IFS=":"
    for library in $1
    do
        echo -n " -libraries $library"
    done
}

BUILDER_OPTIONS="-hardware $BUILDER_PATH/hardware -tools $BUILDER_PATH/hardware/tools/avr -tools $BUILDER_PATH/tools-builder `getLibraryOptions $LIBRARIES_PATH` -fqbn $BOARD_NAME"

if [ -d "$INPUT_HARDWARE" ]; then
    BUILDER_OPTIONS="$BUILDER_OPTIONS -hardware $INPUT_HARDWARE"
fi

if [ -n "$SKETCH_PATH" ]; then
    if [ -z "$1" ]; then
        echo "Building sketch path: ${SKETCH_PATH}"
        arduino-builder $BUILDER_OPTIONS "$SKETCH_PATH"
    else
        echo "Building sketch path: ${SKETCH_PATH}"
        arduino-builder "$@" "$SKETCH_PATH"
    fi
else
    for sketch in `find "$SKETCH_DIRECTORY_PATH" -name '*.ino'`
    do
        if [ -z "$1" ]; then
            echo "Building sketch: ${sketch}"
            arduino-builder $BUILDER_OPTIONS "$sketch"
        else
            echo "Building sketch: ${sketch}"
            arduino-builder "$@" "$sketch"
        fi
    done
fi
