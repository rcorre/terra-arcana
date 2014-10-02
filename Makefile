ASEDIR = resources/ase
SPRITEDIR = content/image
ASEFILES := $(wildcard resources/ase/*.ase)

all: sprites

sprites: $(ASEFILES:$(ASEDIR)/%.ase=$(SPRITEDIR)/%.png)

content/image/%.png : resources/ase/%.ase
	@aseprite --batch --sheet content/image/$*.png resources/ase/$*.ase --data /dev/null

clean:
	@$(RM) $(SPRITEDIR)/*.png 
