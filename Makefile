HERE = $(shell pwd)
BIN = $(HERE)/bin

BUILD_DIRS = pkg spec/fixtures

.PHONY: all build clean

all: build

clean:
	rm -rf $(BUILD_DIRS)
	find . -type f -name '*.swo' -exec rm -rf {} \;
	find . -type f -name '*.swp' -exec rm -rf {} \;

build: clean
	puppet module build
