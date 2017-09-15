#!/bin/bash

set -e

COMPONENTS="platform-tools,tools,build-tools-26.0.1,android-26,extra-google-m2repository"
LICENSES="android-sdk-license-5be876d5|android-sdk-license-c81a61d9"
curl -L https://raw.github.com/embarkmobile/android-sdk-installer/version-2/android-sdk-installer | bash /dev/stdin --install=$COMPONENTS --accept=$LICENSES && source ~/.android-sdk-installer/env

echo "y" | android update sdk --no-ui --filter build-tools-26.0.1,android-26

brew update
brew install infer
