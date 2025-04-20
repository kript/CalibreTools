import os
import argparse
from collections import Counter
from rich import print
from rich.table import Table
from rich.console import Console
from dotenv import load_dotenv
from calibre.library.database2 import LibraryDatabase

console = Console()
load_dotenv()

DEFAULT_LIBRARY_PATH = os.getenv("CALIBRE_LIBRARY_PATH")

def load_db(library_path):
    if not os.path.isdir(library_path):
        console.print(f"[red]Error:[/red] Invalid library path: {library_path}")
        exit(1)
    return LibraryDatabase(library_path)

def list_all_tags(db):
    tag_set = set()
    for book_id in db.all_book_ids():
        mi = db.get_metadata(book_id, index_is_id=True)
        if mi.tags:
            tag_set.update(mi.tags)
    sorted_tags = sorted(tag_set)
    table = Table(title="All Tags (deduplicated)")
    table.add_column("Tag")
    for tag in sorted_tags:
        table.add_row(tag)
    console.print(table)

def remove_tag_from_all(db, tag_to_remove):
    affected = 0
    for book_id in db.all_book_ids():
        mi = db.get_metadata(book_id, index_is_id=True)
        if tag_to_remove in (mi.tags or []):
            mi.tags = [tag for tag in mi.tags if tag != tag_to_remove]
            db.set_metadata(book_id, mi)
            affected += 1
    console.print(f"[green]Done.[/green] Removed tag '[bold]{tag_to_remove}[/bold]' from [cyan]{affected}[/cyan] book(s).")

def report_tag_usage(db):
    tag_counter = Counter()
    for book_id in db.all_book_ids():
        mi = db.get_metadata(book_id, index_is_id=True)
        if mi.tags:
            tag_counter.update(mi.tags)

    if not tag_counter:
        console.print("[yellow]No tags found in the library.[/yellow]")
        return

    table = Table(title="Tag Usage Report", show_lines=True)
    table.add_column("Tag", justify="left")
    table.add_column("Usage Count", justify="right")
    for tag, count in tag_counter.most_common():
        table.add_row(tag, str(count))
    console.print(table)

def main():
    parser = argparse.ArgumentParser(description="Calibre Tag Tool")
    parser.add_argument(
        "--library",
        default=DEFAULT_LIBRARY_PATH,
        help="Path to Calibre library (or set CALIBRE_LIBRARY_PATH in .env)",
    )
    parser.add_argument("--list-tags", action="store_true", help="List all tags (deduplicated)")
    parser.add_argument("--remove-tag", metavar="TAG", help="Remove a tag from all books")
    parser.add_argument("--report-tags", action="store_true", help="Show tag usage report")

    args = parser.parse_args()

    if not args.library:
        console.print("[red]Error:[/red] No library path specified. Use --library or set CALIBRE_LIBRARY_PATH in .env.")
        exit(1)

    db = load_db(args.library)
    db.connect()

    if args.list_tags:
        list_all_tags(db)
    elif args.remove_tag:
        remove_tag_from_all(db, args.remove_tag)
    elif args.report_tags:
        report_tag_usage(db)
    else:
        console.print("[yellow]No action specified. Use --list-tags, --remove-tag or --report-tags.[/yellow]")

    db.close()

if __name__ == "__main__":
    main()
