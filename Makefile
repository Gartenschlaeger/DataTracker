clean:
	rm -rf dist
	
build: clean
	mkdir dist
	zip dist/datatracker.zip *.toc *.lua **/*.lua **/*.xml