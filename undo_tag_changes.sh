#!/bin/bash

LIBRARY_PATH="$1"
LOG_FILE="$2"
DRY_RUN=false

if [[ "$3" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ -z "$LIBRARY_PATH" || -z "$LOG_FILE" || ! -f "$LOG_FILE" ]]; then
    echo "Usage: $0 /path/to/calibre/library /path/to/log_file.txt [--dry-run]"
    exit 1
fi

echo "Restoring tags using log: $LOG_FILE"
echo "Library path: $LIBRARY_PATH"
echo "Dry run: $DRY_RUN"
echo ""

while IFS= read -r line; do
    [[ "$line" =~ ^ID:([0-9]+)\ \|\ TITLE:.*\ \|\ OLD:\[(.*)\]\ \|\ NEW:\[(.*)\]$ ]] || continue
    BOOK_ID="${BASH_REMATCH[1]}"
    OLD_TAGS="${BASH_REMATCH[2]}"
    TITLE=$(echo "$line" | sed -E 's/^ID:[0-9]+ \| TITLE:(.*) \| OLD:.*/\1/')
    
    if $DRY_RUN; then
        echo "[DRY RUN] Would restore ID $BOOK_ID '$TITLE': Tags => [$OLD_TAGS]"
    else
        calibredb set_metadata "$BOOK_ID" --library-path="$LIBRARY_PATH" --field tags:"$OLD_TAGS" >/dev/null
        echo "Restored ID $BOOK_ID '$TITLE': Tags => [$OLD_TAGS]"
    fi
done < "$LOG_FILE"

echo ""
echo "Undo complete."
