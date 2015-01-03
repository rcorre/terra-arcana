#!/bin/sh

# return the needed lflags for static linkage on linux

LIBDIR=../allegro/build/lib/pkgconfig

# awk is used to remove duplicates without sorting
PKG_CONFIG_PATH=$LIBDIR pkg-config --libs --static $LIBDIR/*5.0.pc \
  | sed -r 's/\s+/\n/g' \
  | awk '!a[$0]++'
