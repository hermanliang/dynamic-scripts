#!/bin/bash

set -e

if [[ ! -z "$TRAVIS_PULL_REQUEST" && "$TRAVIS_PULL_REQUEST" != "false" && "$TRAVIS_OS_NAME" == "osx" ]]; then

    rvm use ruby-2.4.1
    echo "git fetch origin develop"
    COMPARE_BRANCH="$TRAVIS_BRANCH"
    CURRENT_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
    git branch $CURRENT_BRANCH
    git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git fetch origin $COMPARE_BRANCH
    git checkout $CURRENT_BRANCH

    CHANGED_COUNT=$(git diff --name-only origin/develop | grep -c '.*java' | cut -d ' ' -f1)
    if [[ $CHANGED_COUNT -gt 0 ]]; then
        COMPONENTS="platform-tools,build-tools-26.0.1,android-26,extra-google-m2repository"
        LICENSES="android-sdk-license-c81a61d9|android-sdk-license-2742d1c5"
        curl -L https://raw.github.com/embarkmobile/android-sdk-installer/version-2/android-sdk-installer | bash /dev/stdin --install=$COMPONENTS --accept=$LICENSES
        source ~/.android-sdk-installer/env
        brew install infer
    else
        echo "No changed java files, ignore configuration"
    fi
fi
