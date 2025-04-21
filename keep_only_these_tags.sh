#!/bin/bash

LIBRARY_PATH="$1"
KEEP_FILE="$2"
DRY_RUN=false

if [[ "$3" == "--dry-run" ]]; then
    DRY_RUN=true
fi

if [[ -z "$LIBRARY_PATH" || -z "$KEEP_FILE" || ! -f "$KEEP_FILE" ]]; then
    echo "Usage: $0 /path/to/calibre/library /path/to/keep_tags.txt [--dry-run]"
    exit 1
fi

# Prepare log file
NOW=$(date +"%Y%m%d_%H%M%S")
MODE_LABEL=$([[ $DRY_RUN == true ]] && echo "dryrun" || echo "live")
LOG_FILE="tag_cleanup_log_${MODE_LABEL}_$NOW.txt"
touch "$LOG_FILE"

# Load tags to keep into an associative array
declare -A KEEP_TAGS
while IFS= read -r tag || [[ -n "$tag" ]]; do
    KEEP_TAGS["$tag"]=1
done < "$KEEP_FILE"

echo "Keeping the following tags:" | tee -a "$LOG_FILE"
for tag in "${!KEEP_TAGS[@]}"; do
    echo " - $tag" | tee -a "$LOG_FILE"
done

echo "" | tee -a "$LOG_FILE"

# Get all book IDs
BOOK_IDS=($(calibredb list --library-path="$LIBRARY_PATH" --fields=tags --for-machine | jq '.[].id'))
TOTAL=${#BOOK_IDS[@]}
COUNT=0

for ID in "${BOOK_IDS[@]}"; do
    ((COUNT++))
    PERCENT=$(( COUNT * 100 / TOTAL ))
    echo -ne "[ $PERCENT% | $COUNT/$TOTAL ]\r"

    METADATA=$(calibredb show_metadata "$ID" --library-path="$LIBRARY_PATH")
    TITLE=$(echo "$METADATA" | grep -i '^ *Title *:' | sed -E 's/^ *Title *: *//')
    CURRENT_TAGS=$(echo "$METADATA" | awk -F': ' '/^Tags/{print $2}' | tr ',' '\n' | sed 's/^ *//;s/ *$//')

    # Keep only allowed tags
    NEW_TAGS=$(echo "$CURRENT_TAGS" | while read -r tag; do
        [[ -n "$tag" && -n "${KEEP_TAGS[$tag]}" ]] && echo "$tag"
    done | paste -sd, -)

    if $DRY_RUN; then
        echo "[DRY RUN] ID:$ID | TITLE:$TITLE | OLD:[$CURRENT_TAGS] | NEW:[$NEW_TAGS]" | tee -a "$LOG_FILE"
    else
        calibredb set_metadata "$ID" --library-path="$LIBRARY_PATH" --field tags:"$NEW_TAGS" >/dev/null
        echo "ID:$ID | TITLE:$TITLE | OLD:[$CURRENT_TAGS] | NEW:[$NEW_TAGS]" | tee -a "$LOG_FILE"
    fi
done

echo -ne "\n"
echo "Done. Log written to: $LOG_FILE"