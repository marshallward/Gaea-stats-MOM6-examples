#!/bin/bash -f

echo -n "Before script started at " && date
# Record environment (for debugging gitlab pipelines)
env > gitlab_session.log

# Assumes running in Gaea-stats-MOM6-examples regression repo
# Reset MOM6-examples to dev/master
(cd MOM6-examples && git checkout . && git checkout dev/master && git pull && git submodule init && git submodule update)

# Pre-process land and set up link to datasets
test -d MOM6-examples/src/LM3 || make -f Gitlab/Makefile.clone clone_gfdl -s
make -f Gitlab/Makefile.clone MOM6-examples/.datasets -s

# Build a manifest of runs to make with PE counts
bash Gitlab/generate_manifest.sh > manifest.mk

echo -n "Before script finished at " && date
