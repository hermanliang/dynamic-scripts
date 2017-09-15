#!/bin/bash

env

if [[ "$TRAVIS_PULL_REQUEST" == "false" || "$TRAVIS_OS_NAME" == "linux" ]]; then
    exit 0
fi

GRADLE_PATH="$SDK_ROOT/android-studio"
CURRENT_BRANCH=$(git branch | grep \* | cut -d ' ' -f2)
COMPARE_BRANCH="develop"
INFER_OUT="$SDK_ROOT/infer-out"

if [ "$CI" == "true" ]; then
    CURRENT_BRANCH="$TRAVIS_PULL_REQUEST_BRANCH"
    git branch $CURRENT_BRANCH
    git config --replace-all remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
    git fetch origin $COMPARE_BRANCH
    git checkout $CURRENT_BRANCH
fi

cd $GRADLE_PATH
./gradlew clean
cd $SDK_ROOT
git diff --name-only origin/$COMPARE_BRANCH > index.txt
echo "Changed files"
cat index.txt
echo "Analyze branch ${CURRENT_BRANCH}"
infer capture -- $GRADLE_PATH/gradlew --offline assembleDebug -b $GRADLE_PATH/ce-premium-global/build.gradle
infer analyze --fail-on-issue -a infer --changed-files-index index.txt
infer report -q --issues-json report-current.json

echo "Switch to ${COMPARE_BRANCH}"
git checkout $COMPARE_BRANCH
echo "Analyze branch ${COMPARE_BRANCH}"
infer capture --reactive -- $GRADLE_PATH/gradlew --offline assembleDebug -b $GRADLE_PATH/ce-premium-global/build.gradle
infer analyze --reactive --fail-on-issue -a infer --changed-files-index index.txt
infer report -q --issues-json report-compare.json
echo "Comparing..."
infer reportdiff --report-current report-current.json --report-previous report-compare.json
git checkout $CURRENT_BRANCH

CHANNEL=android_integration
FILE_PATH=$INFER_OUT/differential/introduced.json
INTRO_REPORT=$(cat $FILE_PATH)
INTRO_REPORT_SIZE=${#INTRO_REPORT}
MESSAGE="$CURRENT_BRANCH Have introduced issues"
if [[ $INTRO_REPORT_SIZE > "2" ]]; then
    echo $MESSAGE
    curl \
        -F file=@${FILE_PATH} \
        -F channels=${CHANNEL} \
        -F token="${SLACK_TRAVIS_TOKEN}" \
        -F title="${CURRENT_BRANCH}" \
        -F initial_comment="${MESSAGE}" \
        https://slack.com/api/files.upload
    exit 1
else
    echo "No introduced issues"
fi
