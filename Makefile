WOW_ADDONDIR_CLASSIC = "/Applications/World of Warcraft/_classic_era_/Interface/AddOns"
WOW_ADDONDIR_RETAIL = "/Applications/World of Warcraft/_retail_/Interface/AddOns"

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
	mkdir -p $(WOW_ADDONDIR_CLASSIC)/DataTracker
	cp -vf DataTracker/*.toc $(WOW_ADDONDIR_CLASSIC)/DataTracker
	cp -vf DataTracker/*.lua $(WOW_ADDONDIR_CLASSIC)/DataTracker
	cp -vfR DataTracker/Localization $(WOW_ADDONDIR_CLASSIC)/DataTracker
	cp -vfR DataTracker/UI $(WOW_ADDONDIR_CLASSIC)/DataTracker
	mkdir -p $(WOW_ADDONDIR_CLASSIC)/DataTracker/Media
	cp -vfR DataTracker/Media/icon.tga $(WOW_ADDONDIR_CLASSIC)/DataTracker/Media/

	mkdir -p $(WOW_ADDONDIR_RETAIL)/DataTracker
	cp -vf DataTracker/*.toc $(WOW_ADDONDIR_RETAIL)/DataTracker
	cp -vf DataTracker/*.lua $(WOW_ADDONDIR_RETAIL)/DataTracker
	cp -vfR DataTracker/Localization $(WOW_ADDONDIR_RETAIL)/DataTracker
	cp -vfR DataTracker/UI $(WOW_ADDONDIR_RETAIL)/DataTracker
	mkdir -p $(WOW_ADDONDIR_RETAIL)/DataTracker/Media
	cp -vfR DataTracker/Media/icon.tga $(WOW_ADDONDIR_RETAIL)/DataTracker/Media/
