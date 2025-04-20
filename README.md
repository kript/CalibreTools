Assorted tools for working with Calibre, the eBook management software.
At the moment, this consists only of;

## Calibre-CoverArt-Collation.pl  

A script to create a directory of cover art files, one for each book 
in the library, for use in screensavers and such.

# Calibre Tag Cleanup Scripts

This directory includes Bash utilities to manage and clean up tags in a Calibre ebook library using the `calibredb` CLI.

## Scripts Included

### ✅ `list_calibre_tags.sh`
List a deduplicated, sorted set of all tags in your Calibre library.

**Usage:**
```bash
./list_calibre_tags.sh "/path/to/Calibre Library"
```

### ✅ `remove_calibre_tag.sh`
Remove a specified tag from all books. Supports tags with spaces and includes dry-run mode.

**Usage:**
```bash
./remove_calibre_tag.sh "/path/to/Calibre Library" "tag to remove" --dry-run
./remove_calibre_tag.sh "/path/to/Calibre Library" "tag to remove"
```

### ✅ `keep_only_these_tags.sh`
Removes **all tags** from all books **except** those listed in a `.txt` file (one tag per line). Includes dry-run mode, live progress, and logs actions to a file.

**Usage:**
```bash
./keep_only_these_tags.sh "/path/to/Calibre Library" keep_tags.txt --dry-run
./keep_only_these_tags.sh "/path/to/Calibre Library" keep_tags.txt
```

**Example `keep_tags.txt`:**
```
sci-fi
history
programming
```

### 🆕 Undo Support (via log replay)
Each destructive operation logs original tags per book ID. To undo changes:

1. Locate the log file (e.g., `tag_cleanup_log_live_20250420_142355.txt`)
2. Use a recovery script (to be created) that reads the log and restores the original tags.

Example log entry:
```
Updated ID 123 'Example Book': Tags => [history, sci-fi]
```
To support undo, logs could optionally include:
```
ID:123 | TITLE:Example Book | OLD:[sci-fi, fiction] | NEW:[history]
```

This will allow future tooling or scripts to parse and restore original metadata.

## Requirements

- `calibredb` (installed with Calibre)
- `jq` (for parsing JSON output)

Install `jq` if needed:
```bash
sudo apt install jq
```

## Notes
- All scripts support paths with spaces (wrap in quotes)
- Logs are timestamped and saved in the current working directory
- Scripts do not require Python

Let us know if you'd like to add undo support, backups, or CSV output.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
