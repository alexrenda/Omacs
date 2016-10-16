#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
    ARG="*SCRATCH*"
else
    ARG=$1
fi;

rm "$HOME/.oca.ml.d"
ln -sf "$PWD/.oca.ml.d" "$HOME/.oca.ml.d"

ocamlbuild -use-ocamlfind -tag thread -pkgs="compiler-libs compiler-libs.toplevel lambda-term str core" main.byte &&
    ./main.byte $ARG
