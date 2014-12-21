#!/bin/sh

NAME=terra-arcana
VERSION=0_0

tar -C .. -cvzf "$NAME$VERSION.tar.gz" $NAME/{terra-arcana,data,content,LICENSE,README.md}

#tar -cvzf "$NAME-content$VERSION.tar.gz" content/ LICENSE README.md
