WOW_ADDON_DIR = "/Applications/World of Warcraft/_retail_/Interface/AddOns"

clean:
	rm -rf DataTracker
	rm -f *.zip

build: clean
	mkdir -p DataTracker
	mkdir -p DataTracker/Media
	cp *.lua *.toc *.md DataTracker
	cp -R Localization DataTracker
	cp -R UI DataTracker
	cp Media/icon.tga DataTracker/Media
	
pack: build
	zip -r datatracker.zip DataTracker

sync: build
	mkdir -p $(WOW_ADDON_DIR)/DataTracker
	cp DataTracker/*.toc $(WOW_ADDON_DIR)/DataTracker
	cp DataTracker/*.lua $(WOW_ADDON_DIR)/DataTracker
