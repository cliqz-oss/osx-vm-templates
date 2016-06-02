#!/bin/sh

set -eo pipefail
shopt -s nullglob

if [[ -d "/Applications/Xcode-Beta.app" ]]; then
    echo "Moving Xcode Beta..."
    mv "/Applications/Xcode-Beta.app" "/Applications/Xcode.app"
fi

[[ ! -d "/Applications/Xcode.app" ]] && exit

expand_dmg() {
    declare dmg="$1" target="${2:-/}"
    echo "Expanding $dmg..."
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/dmg.XXXX`
    TMPTARGET=`/usr/bin/mktemp -d /tmp/target.XXXX`
    hdiutil attach "$dmg" -mountpoint "$TMPMOUNT"
    find "$TMPMOUNT" -name '*.pkg' -exec pkgutil --expand "{}" "$TMPTARGET/data" \;
    tar zxf "$TMPTARGET/data/Payload" -C "$target"
    hdiutil detach "$TMPMOUNT"
    rm -rf "$TMPMOUNT"
    rm -rf "$TMPTARGET"
    rm -f "$dmg"
}

expand_dmg_url() {
    declare url="$1" target="$2"
    dmg=$(basename "$url")
    echo "Downloading $url..."
    curl --retry 3 -o "$dmg" "$url"
    expand_dmg "$dmg" "$target"
}

# accept Xcode license
xcodebuild -license accept

# detect xcode
XCODE_VERSION=$(xcodebuild -version | head -n1 | awk '{print $2}')
XCODE_MAJOR=$(echo "$XCODE_VERSION" | cut -d '.' -f 1)
XCODE_MINOR=$(echo "$XCODE_VERSION" | cut -d '.' -f 2)
DEVELOPER_DIR=$(xcode-select -p)
osx_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')

echo "Detected Xcode: '$XCODE_MAJOR.$XCODE_MINOR' on OSX 10.$osx_vers"
echo "Developer dir: $DEVELOPER_DIR"

# this is taken from:
# https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/index-3905972D-B609-49CE-8D06-51ADC78E07BC.dvtdownloadableindex
# curl URL | plutil -convert xml1 - -o -
if ( [[ "$XCODE_MAJOR" -ge 5 ]] && [[ "$XCODE_MINOR" -ge 1 ]] || [[ "$XCODE_MAJOR" -gt 5 ]] ) && [[ "$osx_vers" -lt 10 ]]; then
    expand_dmg_url http://devimages.apple.com/downloads/xcode/simulators/ios_7_0_simulator.dmg "$DEVELOPER_DIR"
fi

if [[ "$XCODE_MAJOR" -ge 6 ]] && [[ "$XCODE_MAJOR" -lt 7 ]]; then
    expand_dmg_url http://devimages.apple.com/downloads/xcode/simulators/ios_7_1_simulator_rdq52dx.dmg "$DEVELOPER_DIR"
fi

if [[ "$XCODE_MAJOR" -ge 7 ]] && [[ "$XCODE_MINOR" -ge 1 ]]; then
    expand_dmg_url https://devimages.apple.com.edgekey.net/downloads/xcode/simulators/com.apple.pkg.iPhoneSimulatorSDK9_1-9.1.1.1446593668.dmg "$DEVELOPER_DIR"
fi

if [[ "$XCODE_MAJOR" -ge 5 ]] && [[ "$XCODE_MAJOR" -lt 6 ]] && [[ "$osx_vers" -ge 9 ]]; then
    expand_dmg_url http://devimages.apple.com/downloads/xcode/simulators/ios_6_1_simulator.dmg "$DEVELOPER_DIR"
fi
