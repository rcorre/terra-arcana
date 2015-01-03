#!/bin/sh

# return the needed lflags for static linkage on linux

LIBDIR=../allegro/build/lib/pkgconfig
LIBS="                       \
  allegro-static-5.0,        \
  allegro_acodec-static-5.0, \
  allegro_audio-static-5.0,  \
  allegro_color-static-5.0,  \
  allegro_font-static-5.0,   \
  allegro_image-static-5.0,  \
  allegro_main-static-5.0,   \
  allegro_ttf-static-5.0     \
"

# awk is used to remove duplicates without sorting
PKG_CONFIG_PATH=$LIBDIR pkg-config --libs --static $LIBS \
  | sed -r 's/\s+/\n/g' \
  | awk '!a[$0]++' \
  | grep -v 'NOTFOUND' \
  | grep -v 'allegro'
