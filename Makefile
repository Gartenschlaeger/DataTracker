clean:
	rm -rf DataTracker
	rm -f *.zip

build: clean
	mkdir -p DataTracker
	cp *.lua *.toc *.md DataTracker
	cp -R Databases DataTracker
	cp -R General DataTracker
	cp -R Localization DataTracker
	cp -R Tracking DataTracker
	cp -R UI DataTracker
	zip -r datatracker.zip DataTracker