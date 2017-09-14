#!/bin/bash

# set -ev

# Install Opaml
# wget https://github.com/ocaml/opam/releases/download/1.2.2/opam-1.2.2-x86_64-Linux -O opam
# chmod ugo+x opam
# ./opam init --yes --comp=4.01.0 #(then say 'y' to the final question)
# eval `./opam config env`
# ./opam install --yes sawja.1.5 atdgen.1.5.0 javalib.2.3a extlib.1.5.4 #(then say 'y' to the question)
wget https://raw.github.com/ocaml/opam/master/shell/opam_installer.sh -O - | sh -s /usr/local/bin

# Install infer (latest version)
# Checkout Infer
git clone https://github.com/facebook/infer.git
cd infer
# Compile Infer
./build-infer.sh java
# Install Infer into your PATH
export PATH=`pwd`/infer/bin:$PATH
cd ..
