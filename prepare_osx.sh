#!/bin/bash

brew update
brew tap caskroom/cask
brew cask install android-sdk
eval echo \"y\" | android update sdk --no-ui --force --all --filter extra-google-m2repository || true
eval echo \"y\" | android update sdk --no-ui --force --all --filter build-tools-26.0.1 || true
eval echo \"y\" | android update sdk --no-ui --force --all --filter android-26 || true
export ANDROID_HOME=/usr/local/opt/android-sdk
brew install infer
