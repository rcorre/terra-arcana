ASEDIR = resources/ase
SPRITEDIR = content/image
ASEFILES := $(wildcard ./resources/ase/*.ase)

all: sprites

sprites: $(ASEFILES:%.ase=%.png)

%.png : %.ase
	aseprite --batch --sheet $*.png $*.ase
	mv ./resources/ase/*.png ./content/image/
