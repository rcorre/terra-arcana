# Resource directories
ASEDIR   = resources/ase
SVGDIR   = resources/svg
MMPZDIR  = resources/mmpz
TTFDIR   = resources/font
SOUNDSRC = resources/sound
MAPSRC   = resources/tiled

CONTENTDIR = content
# Content directories
PNGDIR    = $(CONTENTDIR)/image
OGGDIR    = $(CONTENTDIR)/music
GUIDIR    = $(PNGDIR)/gui
FONTDIR   = $(CONTENTDIR)/font
SOUNDDEST = $(CONTENTDIR)/sound
MAPDEST	  = $(CONTENTDIR)/maps

# Source files
#ASEFILES  := $(wildcard $(ASEDIR)/*.ase)
SPRITEDIRS := $(sort $(dir $(wildcard $(ASEDIR)/*/)))
SPRITES    := $(notdir $(SPRITEDIRS:%/=%))
MMPZFILES  := $(wildcard $(MMPZDIR)/*.mmpz)
GUIFILES   := $(wildcard $(SVGDIR)/*.svg)
FONTFILES  := $(wildcard $(TTFDIR)/*.ttf)
SOUNDFILES := $(wildcard $(SOUNDSRC)/*.ogg)
MAPFILES	 := $(wildcard $(MAPSRC)/*.tmx)

all: debug

debug: content
	@dub build --compiler=dmd --build=debug --quiet

release: content
	@dub build --compiler=dmd release --quiet

run: content
	@dub run --compiler=dmd --quiet

content: dirs sprites gui music fonts sounds maps

dirs:
	@mkdir -p $(PNGDIR) $(OGGDIR) $(GUIDIR) $(SOUNDDEST) $(FONTDIR) $(MAPDEST)

sprites: $(SPRITES:%=$(PNGDIR)/%.png)

$(PNGDIR)/%.png : $(ASEDIR)/%/*
	@echo building sprite $*
	@./tools/build-spritesheet.sh $(ASEDIR)/$*

music: $(MMPZFILES:$(MMPZDIR)/%.mmpz=$(OGGDIR)/%.ogg)

$(OGGDIR)/%.ogg : $(MMPZDIR)/%.mmpz
	@echo building song $*
	@-! { lmms -r $(MMPZDIR)/$*.mmpz -f ogg -b 64 -o $(OGGDIR)/$*.ogg ; } >/dev/null 2>&1

gui: $(GUIFILES:$(SVGDIR)/%.svg=$(GUIDIR)/%.png)

$(GUIDIR)/%.png : $(SVGDIR)/%.svg
	@echo building gui image $*
	@inkscape $(SVGDIR)/$*.svg --export-png=$(GUIDIR)/$*.png

fonts: $(FONTFILES:$(TTFDIR)/%.ttf=$(FONTDIR)/%.ttf)

$(FONTDIR)/%.ttf : $(TTFDIR)/%.ttf
	@echo copying font $*
	@cp $(TTFDIR)/$*.ttf $(FONTDIR)/$*.ttf

sounds: $(SOUNDFILES:$(SOUNDSRC)/%.ogg=$(SOUNDDEST)/%.ogg)

$(SOUNDDEST)/%.ogg : $(SOUNDSRC)/%.ogg
	@echo copying sound $*
	@cp $(SOUNDSRC)/$*.ogg $(SOUNDDEST)/$*.ogg

maps: $(MAPFILES:$(MAPSRC)/%.tmx=$(MAPDEST)/%.json)

$(MAPDEST)/%.json : $(MAPSRC)/%.tmx
	@echo making map $*
	@tiled --export-map $(MAPSRC)/$*.tmx $(MAPDEST)/$*.json

clean:
	@$(RM) -r $(CONTENTDIR)
