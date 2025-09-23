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
	zip -r datatracker.zip DataTracker
