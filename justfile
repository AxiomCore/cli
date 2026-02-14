default:
    @just --list

build:
    ./scripts/build.sh

release:
    ./scripts/release.sh

publish version:
    ./scripts/publish.sh {{version}}