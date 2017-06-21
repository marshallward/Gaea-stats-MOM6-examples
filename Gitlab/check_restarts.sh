#!/bin/bash

# Compares ocean.stats for 12 and 02 restart stages

new_answer=`tail -1 $1 | sed 's/ *[0-9]*,//'`
right_answer=`tail -1 $2 | sed 's/ *[0-9]*,//'`

if [ "$new_answer" != "$right_answer" ]; then
  cat $2 | sed "s,^,$2: ,"
  cat $1 | sed "s,^,$1: ,"
  exit 1
fi
