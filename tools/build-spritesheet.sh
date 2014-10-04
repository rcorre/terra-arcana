#!/bin/sh

SPRITEDIR=$1
SPRITENAME=$(basename $SPRITEDIR)
DEST="content/image"
TEMPDIR="sprite_build_temp"
mkdir "$TEMPDIR"
for file in $SPRITEDIR/*.ase ;
do
  IDX=$(basename $file .ase)
  aseprite --batch --sheet "$TEMPDIR/$IDX.png" "$file" --data /dev/null
done

convert -append "$TEMPDIR/*.png" "$DEST/$SPRITENAME.png"
rm -r "$TEMPDIR"
