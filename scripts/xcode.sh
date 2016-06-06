#!/bin/sh

set -eo pipefail
shopt -s nullglob

if [[ -d "/Applications/Xcode-Beta.app" ]]; then
    echo "Moving Xcode Beta..."
    mv "/Applications/Xcode-Beta.app" "/Applications/Xcode.app"
fi

[[ ! -d "/Applications/Xcode.app" ]] && exit


# accept Xcode license
xcodebuild -license accept
