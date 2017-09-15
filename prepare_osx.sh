#!/bin/bash

curl -L https://raw.github.com/embarkmobile/android-sdk-installer/version-2/android-sdk-installer | bash /dev/stdin --install=platform-tools,tools,build-tools-26.0.1,android-26,extra-google-m2repository && source ~/.android-sdk-installer/env

brew update
brew install infer
