ASEDIR = resources/ase
SPRITEDIR = content/image
ASEFILES := $(wildcard resources/ase/*.ase)

all: sprites

sprites: $(ASEFILES:$(ASEDIR)/%.ase=$(SPRITEDIR)/%.png)

$(SPRITEDIR)/%.png : $(ASEDIR)/%.ase
	@mkdir -p $(SPRITEDIR)
	@aseprite --batch --sheet $(SPRITEDIR)/$*.png $(ASEDIR)/$*.ase --data /dev/null

clean:
	@$(RM) $(SPRITEDIR)/*.png 
