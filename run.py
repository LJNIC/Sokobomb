#!/usr/bin/python3
from pathlib import Path
import sys
import os
import re

run_love = True
delete = True

if "-s" in sys.argv:
    delete = False

if "-l" in sys.argv:
    run_love = False

def replace_dash(match):
    return match.group(0).replace("-", "_")

file_names = []
for subdir, dirs, files in os.walk("."):
    for file in files:
        if ".fnl" in file:
            file_path = Path(os.path.join(subdir, file))
            lua_file_path = file_path.with_suffix(".lua")
            file_names.append(lua_file_path)
            os.system(f"fennel --compile {file_path} > {lua_file_path}")

            with open(lua_file_path, "r+") as lua_file:
                lua_file_contents = lua_file.read()
            with open(lua_file_path, "w+") as lua_file:
                lua_file.write(re.sub(r'\[\"(.+?)\"\]', replace_dash, lua_file_contents))

if run_love:
    os.system("love .")

if delete:
    for file_name in file_names:
        os.remove(file_name)

