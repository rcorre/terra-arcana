#!/bin/bash

NAME="terra-arcana"
OS="linux"
VERSION="v0_0"

tar -C .. -cvzf "$NAME-$OS-$VERSION.tar.gz" \
  $NAME/{terra-arcana,data,content,icon.png,LICENSE,README.md}
