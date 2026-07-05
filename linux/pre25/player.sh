#!/bin/sh
VMWARE_VER=$(vmware-installer -l | awk '$1=="vmware-player" {split($2,a,"."); print a[1]"."a[2]"."a[3]}')
curl -LO "https://github.com/mkubecek/vmware-host-modules/archive/refs/heads/player-${VMWARE_VER}.zip"
unzip player-${VMWARE_VER}.zip
cd vmware-host-modules-player-${VMWARE_VER}
tar -cf vmmon.tar vmmon-only
tar -cf vmnet.tar vmnet-only
sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/
sudo vmware-modconfig --console --install-all
sudo rm -r vmware-host-modules-player-${VMWARE_VER}
sudo rm player-${VMWARE_VER}.zip vmmon.tar vmnet.tar