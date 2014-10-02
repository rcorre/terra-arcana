ASEDIR = resources/ase
SPRITEDIR = content/image
ASEFILES := $(wildcard resources/ase/*.ase)

all: dirs sprites

dirs:
	@mkdir -p $(SPRITEDIR)

sprites: $(ASEFILES:$(ASEDIR)/%.ase=$(SPRITEDIR)/%.png)

$(SPRITEDIR)/%.png : $(ASEDIR)/%.ase
	@aseprite --batch --sheet $(SPRITEDIR)/$*.png $(ASEDIR)/$*.ase --data /dev/null

clean:
	@$(RM) $(SPRITEDIR)/*.png 
