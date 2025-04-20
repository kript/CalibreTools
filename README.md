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

## Requirements

```bash
pip install rich python-dotenv
```

## Setup

Create a `.env` file:

```env
CALIBRE_LIBRARY_PATH=/path/to/your/Calibre Library
```

## Usage

```bash
# List all tags
python3 calibre_tag_tool.py --list-tags

# Remove a specific tag from all books
python3 calibre_tag_tool.py --remove-tag "sci-fi"

# Show a tag usage report
python3 calibre_tag_tool.py --report-tags

# Override library path via CLI
python3 calibre_tag_tool.py --library "/another/path" --list-tags
```

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```
