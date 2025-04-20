import sys
from collections import Counter
from calibre.library.database2 import LibraryDatabase

def list_all_tags(db):
    tag_set = set()
    for book_id in db.all_book_ids():
        mi = db.get_metadata(book_id, index_is_id=True)
        if mi.tags:
            tag_set.update(mi.tags)
    for tag in sorted(tag_set):
        print(tag)

def remove_tag_from_all(db, tag_to_remove):
    affected = 0
    for book_id in db.all_book_ids():
        mi = db.get_metadata(book_id, index_is_id=True)
        if tag_to_remove in (mi.tags or []):
            mi.tags = [tag for tag in mi.tags if tag != tag_to_remove]
            db.set_metadata(book_id, mi)
            affected += 1
    print(f"Removed tag '{tag_to_remove}' from {affected} book(s).")

def report_tag_usage(db):
    tag_counter = Counter()
    for book_id in db.all_book_ids():
        mi = db.get_metadata(book_id, index_is_id=True)
        if mi.tags:
            tag_counter.update(mi.tags)
    for tag, count in tag_counter.most_common():
        print(f"{tag}: {count}")

def main():
    if len(sys.argv) < 3:
        print("Usage: core_tag_tool.py [list-tags|remove-tag|report-tags] /path/to/library [tag_to_remove]")
        return

    command = sys.argv[1]
    library_path = sys.argv[2]
    db = LibraryDatabase(library_path)
    db.connect()

    if command == "list-tags":
        list_all_tags(db)
    elif command == "remove-tag":
        if len(sys.argv) < 4:
            print("Error: 'remove-tag' requires a tag name.")
        else:
            remove_tag_from_all(db, sys.argv[3])
    elif command == "report-tags":
        report_tag_usage(db)
    else:
        print(f"Unknown command: {command}")

    db.close()

if __name__ == "__main__":
    main()
