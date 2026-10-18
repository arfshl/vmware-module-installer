#!/bin/bash
set -euo

version_raw=$(vmware-installer -l | awk '$1=="vmware-workstation" {print $2}')

if [ -z "$version_raw" ]; then
    echo "VMware Workstation not found via vmware-installer."
    exit 1
fi

major=$(echo "$version_raw" | cut -d'.' -f1)

FOUND_BRANCH=""

# Retry loop for h1, h2, h3
for h in 1 2 3; do
    branch="workstation-${major}h${h}"
    url="https://github.com/philipL/vmware-host-modules/archive/refs/heads/${branch}.zip"
    
    echo "Checking branch: $branch..."

    # Download to a temporary zip file following redirects (-L), silent (-s), fail on server errors (-f)
    if curl -sLf -o "${branch}.zip" "$url"; then
        # Ensure the file is actually a valid zip (size > 1000 bytes, avoiding tiny html error pages)
        if [ -s "${branch}.zip" ] && [ "$(wc -c < "${branch}.zip")" -gt 1000 ]; then
            FOUND_BRANCH="$branch"
            echo "Found valid branch: $FOUND_BRANCH"
            break
        fi
    fi
    
    # Clean up invalid attempt if it exists
    rm -f "${branch}.zip"
done

if [ -z "$FOUND_BRANCH" ]; then
    echo "Error: No compatible branch (h1, h2, h3) found on GitHub for major version $major."
    exit 1
fi

echo "Using branch: $FOUND_BRANCH"

# The zip is already downloaded as ${FOUND_BRANCH}.zip during the check!
unzip "${FOUND_BRANCH}.zip"
cd "vmware-host-modules-${FOUND_BRANCH}"

tar -cf vmmon.tar vmmon-only
tar -cf vmnet.tar vmnet-only

sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/
sudo vmware-modconfig --console --install-all

cd ..
rm -rf "vmware-host-modules-${FOUND_BRANCH}" "${FOUND_BRANCH}.zip"
