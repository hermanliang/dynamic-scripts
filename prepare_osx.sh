#!/bin/bash

set -e

if [[ ! -z "$TRAVIS_PULL_REQUEST" && "$TRAVIS_PULL_REQUEST" != "false" && "$TRAVIS_OS_NAME" == "osx" ]]; then
    COMPONENTS="platform-tools,build-tools-26.0.1,android-26,extra-google-m2repository"
    LICENSES="android-sdk-license-c81a61d9"
    curl -L https://raw.github.com/embarkmobile/android-sdk-installer/version-2/android-sdk-installer | bash /dev/stdin --install=$COMPONENTS --accept=$LICENSES
    source ~/.android-sdk-installer/env

    brew install infer
fi
