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

convert -background none "$TEMPDIR/*.png" -append "$DEST/$SPRITENAME.png"
rm -r "$TEMPDIR"
