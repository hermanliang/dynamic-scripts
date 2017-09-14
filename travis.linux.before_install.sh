#!/bin/bash
# wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

# Install infer (latest version)
# Checkout Infer
git clone https://github.com/facebook/infer.git
cd infer
# Compile Infer
./build-infer.sh java
# Install Infer into your PATH
export PATH=`pwd`/infer/bin:$PATH
cd ..
