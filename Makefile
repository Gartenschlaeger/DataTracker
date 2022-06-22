clean:
	rm -rf DataTracker
	rm -f datatracker.zip

build: clean
	mkdir -p DataTracker
	cp *.lua *.toc *.md DataTracker
	cp -R Localization DataTracker
	cp -R UI DataTracker
	zip -r datatracker.zip DataTracker