#!/bin/sh
SPRITES="\
  assault sniper medic guardian\
  wyvern hellblossom antlion treant\
  raider scout defender hunter"

IMAGEDIR="./content/image"
IMAGEEXT="png"
CROPSIZE="32x32+0+0"
OUTFILE="./resources/unit-sheet.png"

TMPDIR=$(mktemp -d)
echo "created temp dir $TMPDIR"

for sprite in $SPRITES; do
  srcname="$IMAGEDIR/$sprite.$IMAGEEXT"
  dstname="$TMPDIR/$sprite.$IMAGEEXT"
  convert $srcname -crop $CROPSIZE $dstname
done

montage -geometry 32x32 -background transparent $TMPDIR/*.png $OUTFILE

echo "removing temp dir $TMPDIR"
rm -r $TMPDIR
