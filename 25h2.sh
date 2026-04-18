#!/bin/sh
curl -LO https://github.com/philipl/vmware-host-modules/archive/refs/heads/workstation-25h2.zip
unzip workstation-25h2.zip
cd vmware-host-modules-workstation-25h2
tar -cf vmmon.tar vmmon-only
tar -cf vmnet.tar vmnet-only
sudo cp -v vmmon.tar vmnet.tar /usr/lib/vmware/modules/source/
sudo vmware-modconfig --console --install-all
sudo rm -r vmware-host-modules-workstation-25h2
sudo rm workstation-25h2.tar.gz vmmon.tar vmnet.tar
