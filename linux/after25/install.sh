#!/bin/sh
set -euo

version=$(vmware-installer -l | awk '$1=="vmware-workstation" {
    split($2,a,".")
    print a[1], a[2], a[3]
}')

set -- $version
major=$1
patch=${3:-0}

check_branch() {
    branch="$1"

    if curl -fsI "https://github.com/philipl/vmware-host-modules/archive/refs/heads/${branch}.zip" >/dev/null; then
        FOUND_BRANCH="$branch"
        return 0
    fi

    return 1
}

FOUND_BRANCH=""

# Try branch for specific version (25h2u1=25.0.1)
if [ "$patch" -gt 0 ]; then
    for h in 1 2 3 4 5; do
        check_branch "workstation-${major}h${h}u${patch}" && break
    done
fi

# If not found then fallback to only to base version (25h2=25.0.0)
if [ -z "$FOUND_BRANCH" ]; then
    for h in 1 2 3 4 5; do
        check_branch "workstation-${major}h${h}" && break
    done
fi

if [ -z "$FOUND_BRANCH" ]; then
    echo "No compatible branch found."
    exit 1
fi

echo "Using $FOUND_BRANCH"

curl -LO "https://github.com/philipl/vmware-host-modules/archive/refs/heads/${FOUND_BRANCH}.zip"
unzip "${FOUND_BRANCH}.zip"
cd "vmware-host-modules-${FOUND_BRANCH}"

tar -cf vmmon.tar vmmon-only
tar -cf vmnet.tar vmnet-only

sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/
sudo vmware-modconfig --console --install-all

cd ..
rm -rf "vmware-host-modules-${FOUND_BRANCH}" "${FOUND_BRANCH}.zip"