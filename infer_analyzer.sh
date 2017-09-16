#!/bin/bash

set -e

env

if [[ ! -z "$TRAVIS_PULL_REQUEST" && "$TRAVIS_PULL_REQUEST" != "false" && "$TRAVIS_OS_NAME" == "osx" || -z $CI ]]; then
    if [ "$CI" == "true" ]; then
        echo "git fetch origin develop"
        COMPARE_BRANCH="$TRAVIS_BRANCH"
        CURRENT_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
        git branch $CURRENT_BRANCH
        git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
        git fetch origin $COMPARE_BRANCH
        git checkout $CURRENT_BRANCH
    else
        SDK_ROOT="$PWD"
        COMPARE_BRANCH="develop"
        CURRENT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
    fi
    INFER_OUT="$SDK_ROOT/infer-out"
    GRADLE_PATH="$SDK_ROOT/android-studio"

    cd $GRADLE_PATH
    ./gradlew clean
    cd $SDK_ROOT
    echo "Changed files"
    git diff --name-only origin/$COMPARE_BRANCH > index.txt
    cat index.txt
    echo "Analyze branch ${CURRENT_BRANCH}"
    infer capture -- $GRADLE_PATH/gradlew --offline assembleDebug -b $GRADLE_PATH/ce-premium-global/build.gradle
    infer analyze --changed-files-index index.txt
    infer report -q --issues-json report-current.json

    echo "Switch to ${COMPARE_BRANCH}"
    git checkout $COMPARE_BRANCH
    echo "Analyze branch ${COMPARE_BRANCH}"
    infer capture --reactive -- $GRADLE_PATH/gradlew --offline assembleDebug -b $GRADLE_PATH/ce-premium-global/build.gradle
    infer analyze --reactive --changed-files-index index.txt
    infer report -q --issues-json report-compare.json
    echo "Comparing..."
    infer reportdiff --report-current report-current.json --report-previous report-compare.json
    git checkout $CURRENT_BRANCH

    CHANNEL=android_integration
    FILE_PATH=$INFER_OUT/differential/introduced.json
    INTRO_REPORT=$(cat $FILE_PATH)
    INTRO_REPORT_SIZE=${#INTRO_REPORT}
    MESSAGE="$CURRENT_BRANCH has introduced issues."
    if [[ $INTRO_REPORT_SIZE -gt "2" ]]; then
        echo -e "\033[0;31mFailed:\033[1;33m $MESSAGE Please check slack channel #android_integration.\033[0m"
        curl \
            -F file=@${FILE_PATH} \
            -F channels=${CHANNEL} \
            -F token="${SLACK_TRAVIS_TOKEN}" \
            -F title="${CURRENT_BRANCH}" \
            -F initial_comment="${MESSAGE}" \
            https://slack.com/api/files.upload
        exit 1
    fi
    echo "No introduced issues"
fi
