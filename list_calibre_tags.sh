#!/bin/bash

LIBRARY_PATH="$1"

if [[ -z "$LIBRARY_PATH" ]]; then
    echo "Usage: $0 /path/to/calibre/library"
    exit 1
fi

calibredb list --library-path="$LIBRARY_PATH" --fields=tags --for-machine \
| jq -r '.[] | .tags[]?' \
| sort -u
