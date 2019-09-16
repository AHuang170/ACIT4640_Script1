#!/bin/bash -x
vboxmanage () { VboxManage.exe "$@"; }
VM_NAME="VM_ACIT4640"
SED_PROGRAM='/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }'
VBOX_FILE=$(vboxmanage.exe showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")
vboxmanage createhd --filename $VM_NAME.vdi --size 10240
vboxmanage createvm --name $VM_NAME --ostype "RedHat_64" --register
vboxmanage storagectl $VM_NAME --name "SATA Controller" --add sata --controller IntelAHCI
vboxmanage storageattach $VM_NAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $VM_NAME.vdi
vboxmanage storagectl $VM_NAME --name "IDE Controller" --add ide
vboxmanage storageattach $VM_NAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium ~/windows/Desktop/ACIT_4640/ISO/CentOS-7-x86_64-Minimal-1810.iso
vboxmanage modifyvm $VM_NAME --cpus 1 --memory 1024
vboxmanage natnetwork add --netname net_4640 --network "192.168.250.0/24" --enable --dhcp off --ipv6 off
vboxmanage natnetwork modify --netname net_4640 --port-forward-4 "ssh:tcp:[]:50022:[192.168.250.10]:22"
vboxmanage natnetwork modify --netname net_4640 --port-forward-4 "http:tcp:[]:50080:[192.168.250.10]:80"
vboxmanage natnetwork modify --netname net_4640 --port-forward-4 "https:tcp:[]:50443:[192.168.250.10]:443"
vboxmanage natnetwork start --netname net_4640

