default:
    @just --list

build:
    ./scripts/build.sh

release:
    ./scripts/create_release.sh

publish version:
    ./scripts/publish.sh {{version}}