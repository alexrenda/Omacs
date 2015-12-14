#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    ARG="*SCRATCH*"
else
    ARG=$1
fi;

rm "$HOME/.oca.ml.d"
ln -sf "$PWD/.oca.ml.d" "$HOME/.oca.ml.d"

cs3110 compile main.ml &&
    cs3110 run main $ARG
