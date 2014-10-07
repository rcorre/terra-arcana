# Resource directories
ASEDIR = resources/ase
SVGDIR = resources/svg
MMPZDIR = resources/mmpz

# Content directories
PNGDIR = content/image
OGGDIR = content/music
WAVDIR = content/sound

# Source files
#ASEFILES := $(wildcard $(ASEDIR)/*.ase)
SPRITEDIRS := $(sort $(dir $(wildcard $(ASEDIR)/*/)))
SPRITES := $(notdir $(SPRITEDIRS:%/=%))
MMPZFILES := $(wildcard $(MMPZDIR)/*.mmpz)

all: debug

debug: content
	dub build

release: content
	dub build release

run: content
	dub run

content: dirs sprites music

dirs:
	@mkdir -p $(PNGDIR) $(OGGDIR)

#sprites: $(ASEFILES:$(ASEDIR)/%.ase=$(PNGDIR)/%.png)

sprites: $(SPRITES:%=$(PNGDIR)/%.png)

$(PNGDIR)/%.png : $(ASEDIR)/%
	@echo building sprite $*
	@./tools/build-spritesheet.sh $(ASEDIR)/$*

music: $(MMPZFILES:$(MMPZDIR)/%.mmpz=$(OGGDIR)/%.ogg)

#$(PNGDIR)/%.png : $(ASEDIR)/%.ase
#	@aseprite --batch --sheet $(PNGDIR)/$*.png $(ASEDIR)/$*.ase --data /dev/null

$(OGGDIR)/%.ogg : $(MMPZDIR)/%.mmpz
	@building song $*
	@-! { lmms -r $(MMPZDIR)/$*.mmpz -f ogg -o $(OGGDIR)/$*.ogg ; } >/dev/null 2>&1

clean:
	@$(RM) $(PNGDIR)/*.png
	@$(RM) $(OGGDIR)/*.ogg
