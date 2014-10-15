# Resource directories
ASEDIR = resources/ase
SVGDIR = resources/svg
MMPZDIR = resources/mmpz

# Content directories
PNGDIR = content/image
OGGDIR = content/music
WAVDIR = content/sound
GUIDIR = $(PNGDIR)/gui

# Source files
#ASEFILES  := $(wildcard $(ASEDIR)/*.ase)
SPRITEDIRS := $(sort $(dir $(wildcard $(ASEDIR)/*/)))
SPRITES    := $(notdir $(SPRITEDIRS:%/=%))
MMPZFILES  := $(wildcard $(MMPZDIR)/*.mmpz)
GUIFILES   := $(wildcard $(SVGDIR)/*.svg)

all: debug

debug: content
	@dub build --quiet

release: content
	@dub build release --quiet

run: content
	@dub run --quiet 

content: dirs sprites gui music

dirs:
	@mkdir -p $(PNGDIR) $(OGGDIR) $(GUIDIR) $(WAVDIR)

#sprites: $(ASEFILES:$(ASEDIR)/%.ase=$(PNGDIR)/%.png)

sprites: $(SPRITES:%=$(PNGDIR)/%.png)

$(PNGDIR)/%.png : $(ASEDIR)/%/*
	@echo building sprite $*
	@./tools/build-spritesheet.sh $(ASEDIR)/$*

music: $(MMPZFILES:$(MMPZDIR)/%.mmpz=$(OGGDIR)/%.ogg)

$(OGGDIR)/%.ogg : $(MMPZDIR)/%.mmpz
	@echo building song $*
	@-! { lmms -r $(MMPZDIR)/$*.mmpz -f ogg -o $(OGGDIR)/$*.ogg ; } >/dev/null 2>&1

gui: $(GUIFILES:$(SVGDIR)/%.svg=$(GUIDIR)/%.png)

$(GUIDIR)/%.png : $(SVGDIR)/%.svg
	@echo building gui image $*
	@inkscape $(SVGDIR)/$*.svg --export-png=$(GUIDIR)/$*.png

clean:
	@$(RM) $(PNGDIR)/*.png
	@$(RM) $(OGGDIR)/*.ogg
