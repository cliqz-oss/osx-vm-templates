#!/bin/bash

set -eo pipefail
shopt -s nullglob

list_all_simulators() {
    xcrun simctl list devices | grep -v '^[-=]' | cut -d "(" -f2 | cut -d ")" -f1
}

echo Creating simulators...
while xcrun simctl list devices | grep -q Creating; do
    sleep 1s
done

while read UUID; do
    echo -n "Booting "
    xcrun simctl list devices | grep $UUID
    xcrun simctl boot $UUID
    sleep 10s
    xcrun simctl shutdown $UUID
    sleep 1s
done < <(list_all_simulators)

echo Done
xcrun simctl list devices
