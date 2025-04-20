Assorted tools for working with Calibre, the eBook management software.
At the moment, this consists only of;

## Calibre-CoverArt-Collation.pl  
A script to create a directory of cover art files, one for each book 
in the library, for use in screensavers and such.

Probably broken. It's pretty old and I haven't used it in a while.

# Calibre Tag Tool

A CLI utility to manage tags in a Calibre ebook library using Python.

## Features

- ✅ List all tags (deduplicated)
- ✅ Remove a specific tag from all books
- ✅ Show a tag usage report (counts)

## Project Structure

This tool is split into two parts for compatibility:

- `core_tag_tool.py` → Uses Calibre's internal modules only. Run via `calibre-debug`.
- `cli_wrapper.py` → User-friendly CLI with argparse, rich output, dotenv config. Delegates work to `core_tag_tool.py`.

## Requirements

```bash
pip install rich python-dotenv
```

Or if you're using [Poetry](https://python-poetry.org/):

```bash
poetry add rich python-dotenv
```

## Setup

Create a `.env` file:

```env
CALIBRE_LIBRARY_PATH=/path/to/your/Calibre Library
```

## Usage

### Step 1: Run core logic via Calibre

Use `calibre-debug` to run `core_tag_tool.py`, which supports these operations:

```bash
calibre-debug -e core_tag_tool.py -- list-tags /path/to/library
calibre-debug -e core_tag_tool.py -- remove-tag sci-fi /path/to/library
calibre-debug -e core_tag_tool.py -- report-tags /path/to/library
```

### Step 2: Use friendly CLI (optional)

To use the prettier CLI with `rich` and `.env` support, run the wrapper:

```bash
poetry run python cli_wrapper.py list-tags
poetry run python cli_wrapper.py remove-tag sci-fi
poetry run python cli_wrapper.py report-tags
```

You can still override the library path manually:

```bash
poetry run python cli_wrapper.py list-tags --library "/another/path"
```

## Notes

- Only `core_tag_tool.py` should directly use Calibre's API.
- The wrapper parses arguments, loads `.env`, and calls `core_tag_tool.py` with subprocess.
- This structure avoids import errors while keeping a nice CLI for daily use.

Let us know if you'd like Bash completion, tag merging support, or an interactive cleanup mode.


## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
