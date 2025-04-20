import subprocess
subprocess.run(["poetry", "run", "python", "calibre_tag_tool.py"] + __import__('sys').argv[1:])
