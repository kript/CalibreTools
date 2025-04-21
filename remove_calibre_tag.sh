#!/bin/bash

LIBRARY_PATH="$1"
TAG_TO_REMOVE="$2"
DRY_RUN=false

if [[ "$3" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ -z "$LIBRARY_PATH" || -z "$TAG_TO_REMOVE" ]]; then
    echo "Usage: $0 /path/to/calibre/library \"tag to remove\" [--dry-run]"
    exit 1
fi

BOOK_IDS=$(calibredb search --library-path="$LIBRARY_PATH" "tags:\"=$TAG_TO_REMOVE\"")

if [[ -z "$BOOK_IDS" ]]; then
    echo "No books found with tag: '$TAG_TO_REMOVE'"
    exit 0
fi

echo "Found books with tag '$TAG_TO_REMOVE': $BOOK_IDS"

# Split comma-separated IDs into individual entries
for ID in $(echo "$BOOK_IDS" | tr ',' ' '); do
    METADATA=$(calibredb show_metadata "$ID" --library-path="$LIBRARY_PATH")
    TITLE=$(echo "$METADATA" | grep -i '^ *Title *:' | sed -E 's/^ *Title *: *//')
    CURRENT_TAGS=$(echo "$METADATA" | awk -F': ' '/^Tags/{print $2}' | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -vFx "$TAG_TO_REMOVE" | paste -sd, -)
    if $DRY_RUN; then
        echo "[DRY RUN] Would update book ID $ID ('$TITLE'): Tags => [$CURRENT_TAGS]"
    else
        calibredb set_metadata "$ID" --library-path="$LIBRARY_PATH" --field tags:"$CURRENT_TAGS" >/dev/null
        echo "Updated book ID $ID ('$TITLE'): Tags => [$CURRENT_TAGS]"
    fi
done

echo "Done."