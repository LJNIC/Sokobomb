# Fennel Skeleton
My personal skeleton for LÖVE projects made with [Fennel](https://fennel-lang.org/).

The game is run with the `run.py` Python script. It compiles every Fennel file to Lua and runs the game. Afterwards, it deletes all of the Lua files. Using the `-s` flag will keep the Lua files around, and `-l` will stop the game from running. The script will also replace dashes with underscores in table accesses, so that snake case code from other modules (like `batteries`) can still be used with kebab-case.

A config for [makelove](https://github.com/pfirsich/makelove) is also included, which calls `run.py` appropriately to generate the required Lua code.

### Included Libraries
* [batteries](https://github.com/1bardesign/batteries/) (globally exported)
* [bump](https://github.com/kikito/bump.lua)
* [anim8](https://github.com/kikito/anim8)
* [roomy](https://github.com/tesselode/roomy)
* [ripple](https://github.com/tesselode/ripple)
* potatonomicon's [vec2](https://github.com/potatonomicon/russet/blob/master/vec2.lua)

