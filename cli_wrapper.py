import os
import subprocess
import argparse
from dotenv import load_dotenv
from rich.console import Console
from rich.table import Table

console = Console()
load_dotenv()

DEFAULT_LIBRARY_PATH = os.getenv("CALIBRE_LIBRARY_PATH")

def run_core(command, library, tag=None):
    args = ["calibre-debug", "-e", "core_tag_tool.py", "--", command, library]
    if tag:
        args.append(tag)
    result = subprocess.run(args, capture_output=True, text=True)
    return result.stdout.strip()

def main():
    parser = argparse.ArgumentParser(description="CLI wrapper for Calibre Tag Tool")
    parser.add_argument("command", choices=["list-tags", "remove-tag", "report-tags"])
    parser.add_argument("tag", nargs="?", help="Tag to remove (required for remove-tag)")
    parser.add_argument("--library", default=DEFAULT_LIBRARY_PATH, help="Path to Calibre library")

    args = parser.parse_args()

    if not args.library:
        console.print("[red]Error:[/red] No library path provided. Use --library or set CALIBRE_LIBRARY_PATH.")
        return

    if args.command == "remove-tag" and not args.tag:
        console.print("[red]Error:[/red] You must specify a tag for 'remove-tag'.")
        return

    output = run_core(args.command, args.library, args.tag)

    if args.command == "list-tags":
        tags = output.splitlines()
        table = Table(title="All Tags")
        table.add_column("Tag")
        for tag in tags:
            table.add_row(tag)
        console.print(table)

    elif args.command == "report-tags":
        lines = output.splitlines()
        table = Table(title="Tag Usage Report")
        table.add_column("Tag")
        table.add_column("Count", justify="right")
        for line in lines:
            tag, count = line.rsplit(":", 1)
            table.add_row(tag.strip(), count.strip())
        console.print(table)

    else:
        console.print(output)

if __name__ == "__main__":
    main()
