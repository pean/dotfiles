#!/usr/bin/env bash

SRC=$1
FILE=$(basename $SRC)
DEST=~/dotfiles/$FILE
echo "FILE: $FILE"
echo "SRC: $SRC"
echo "DEST: $DEST"

mv $SRC $DEST

ln -s $DEST $SRC
