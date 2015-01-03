#!/bin/bash

# package configuration
NAME="terra-arcana"
OS="linux"
VERSION="0.0.1"

# important directories
BINDIR="bin"
DATADIR="data"
CONTENTDIR="content"

# .so files to copy for static build
SOLIBS="png16 FLAC ogg dumb vorbis vorbisfile vorbisenc openal jpeg freetype \
  GL GLU json-c"

# check if using static or shared build
ldd $BINDIR/$NAME | grep -q 'allegro'
STATICBUILD=$?

# assign a name to the package
if [ $STATICBUILD -eq 0 ] ; then
  echo 'Dynamic (shared) build detected'
  PKGDIR="$NAME-$OS-$VERSION"
else
  echo 'Static build detected'
  PKGDIR="$NAME-$OS-static-$VERSION"
fi

# create package dir with necessary files
echo "creating temp dir $PKGDIR"
mkdir $PKGDIR
cp -r $BINDIR     $PKGDIR
cp -r $DATADIR    $PKGDIR
cp -r $CONTENTDIR $PKGDIR
cp    LICENSE     $PKGDIR
cp    README.md   $PKGDIR
cp    icon.png    $PKGDIR

# create run script
echo "generating run script $RUNCMD"
RUNCMD="$PKGDIR/run"
echo '#!/bin/sh' > $RUNCMD
chmod +x $RUNCMD

if [ $STATICBUILD -eq 0 ] ; then # dynamic linkage
  echo "$BINDIR/$NAME" >> $RUNCMD
else                             # static linkage
  echo "LD_LIBRARY_PATH=$BINDIR $BINDIR/$NAME" >> $RUNCMD
  for LIBNAME in $SOLIBS ; do
    echo "copying /usr/lib/lib$LIBNAME.so to $PKGDIR/$BINDIR"
    cp "/usr/lib/lib$LIBNAME.so" $PKGDIR/$BINDIR
  done
fi

# create tarball and clean up package dir
tar -czf "$PKGDIR.tar.gz" $PKGDIR
rm -r $PKGDIR
echo "created package $PKGDIR.tar.gz"
