# Compilation environments

The scripts in this directory compilation the compilation environment for MOM6 on the NCRC Gaea platform.
Currently platform  ncrc3 and ncrc4 yield the same answers recorded in this repo.

e.g. in bash, `. environ/gcc-9.3.0.sh` prior to `make`

The regression files ("regressions/*/ocean.stats.%") currently have a suffix "%" of "gnu", "intel", or "pgi".
For convenience, these are mapped to an environment file via the symbolic links "%.env".

Note: the older way of recording environments was solely through a "label" in labels.json. This file will
co-exist with these scripts while we transition the pipelines to use the scripts.

## To do
[ ] remove labels.json
[ ] update suffix of stats files to reflect the compiler name rather than vendor name
