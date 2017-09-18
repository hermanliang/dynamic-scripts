#!/bin/bash

set -e

if [[ ! -z "$TRAVIS_PULL_REQUEST" && "$TRAVIS_PULL_REQUEST" != "false" && "$TRAVIS_OS_NAME" == "osx" ]]; then

    echo "git fetch origin develop"
    COMPARE_BRANCH="$TRAVIS_BRANCH"
    CURRENT_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
    git branch $CURRENT_BRANCH
    git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git fetch origin $COMPARE_BRANCH
    git checkout $CURRENT_BRANCH

    CHANGED_COUNT=$(git diff --name-only origin/$COMPARE_BRANCH | grep -c -e '.*java')
    if [[ "$CHANGED_COUNT" == "0" ]]; then
        echo "No changed java files, ignore configuration"
        exit 0
    fi

    COMPONENTS="platform-tools,build-tools-26.0.1,android-26,extra-google-m2repository"
    LICENSES="android-sdk-license-c81a61d9"
    curl -L https://raw.github.com/embarkmobile/android-sdk-installer/version-2/android-sdk-installer | bash /dev/stdin --install=$COMPONENTS --accept=$LICENSES
    source ~/.android-sdk-installer/env

    brew install infer
fi
