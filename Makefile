# Resource directories
ASEDIR = resources/ase
SVGDIR = resources/svg
MMPZDIR = resources/mmpz
TTFDIR = resources/font

# Content directories
PNGDIR  = content/image
OGGDIR  = content/music
WAVDIR  = content/sound
GUIDIR  = $(PNGDIR)/gui
FONTDIR = content/font

# Source files
#ASEFILES  := $(wildcard $(ASEDIR)/*.ase)
SPRITEDIRS := $(sort $(dir $(wildcard $(ASEDIR)/*/)))
SPRITES    := $(notdir $(SPRITEDIRS:%/=%))
MMPZFILES  := $(wildcard $(MMPZDIR)/*.mmpz)
GUIFILES   := $(wildcard $(SVGDIR)/*.svg)
FONTFILES  := $(wildcard $(TTFDIR)/*.ttf)

all: debug

debug: content
	@dub build --quiet

release: content
	@dub build release --quiet

run: content
	@dub run --quiet 

content: dirs sprites gui music fonts

dirs:
	@mkdir -p $(PNGDIR) $(OGGDIR) $(GUIDIR) $(WAVDIR) $(FONTDIR)

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

fonts: $(FONTFILES:$(TTFDIR)/%.ttf=$(FONTDIR)/%.ttf)

$(FONTDIR)/%.ttf : $(TTFDIR)/%.ttf
	@echo copying font $*
	@cp $(TTFDIR)/$*.ttf $(FONTDIR)/$*.ttf

clean:
	@$(RM) $(PNGDIR)/*.png
	@$(RM) $(GUIDIR)/*.png
	@$(RM) $(WAVDIR)/*.wav
	@$(RM) $(OGGDIR)/*.ogg
	@$(RM) $(FONTDIR)/*.ttf
