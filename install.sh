#!/bin/bash

# Configure dnf (In order: automatically select fastest mirror, parallel downloads, and disable telemetry)
printf "%s" "
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
countme=False
" | sudo tee -a /etc/dnf/dnf.conf

# Setting umask to 077
# No one except wheel user and root get read/write files
umask 077
sudo sed -i 's/umask 002/umask 077/g' /etc/bashrc
sudo sed -i 's/umask 022/umask 077/g' /etc/bashrc

###
# Disable the Modular Repos
# Given the added load at updates, and the issues to keep modules updated, in check and listed from the awful cli for it - remove entirely.
###

sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo

# Rpmfusion makes this obsolete
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# Disable Machine Counting for all repos
sudo sed -i 's/countme=1/countme=0/g' /etc/yum.repos.d/*

sudo dnf upgrade --best --allowerasing --refresh -y

# And also remove any packages without a source backing them
sudo dnf distro-sync -y

# Debloat
sudo dnf remove -y abrt* adcli anaconda* dmidecode anthy-unicode hyperv* alsa-sof-firmware boost-date-time virtualbox-guest-additions yelp fedora-bookmarks mailcap open-vm-tools openconnect openvpn ppp pptp rsync samba-client unbound-libs vpnc yajl zd1211-firmware atmel-firmware libertas-usb8388-firmware mediawriter firefox xorg-x11-drv-vmware sane* perl* sos kpartx dos2unix sssd cyrus-sasl-plain geolite2* traceroute mtr realmd ModemManager teamd tcpdump mozilla-filesystem nmap-ncat spice-vdagent perl-IO-Socket-SSL evince

# Run Updates
sudo dnf autoremove -y
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates -y
sudo fwupdmgr update -y

# Setup Flathub and Flatpak
# Flathub is enabled by default, but fails to install anything outside of Fedora still.
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Setup RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core -y

# Install
flatpak install com.brave.Browser com.discordapp.Discord com.github.Matoking.protontricks com.github.zocker_160.SyncThingy com.heroicgameslauncher.hgl com.makemkv.MakeMKV com.spotify.Client com.steamgriddb.SGDBoop com.usebottles.bottles com.vscodium.codium dev.bsnes.bsnes fr.romainvigier.MetadataCleaner io.freetubeapp.FreeTube io.github.shiiion.primehack io.gitlab.librewolf-community io.mgba.mGBA net.davidotek.pupgui2 net.kuribo64.melonDS net.pcsx2.PCSX2 nz.mega.MEGAsync org.DolphinEmu.dolphin-emu org.citra_emu.citra org.duckstation.DuckStation org.kde.kid3 org.keepassxc.KeePassXC org.libreoffice.LibreOffice org.mozilla.firefox org.musicbrainz.Picard org.prismlauncher.PrismLauncher org.ryujinx.Ryujinx org.sonic3air.Sonic3AIR org.yuzu_emu.yuzu org.zdoom.GZDoom re.chiaki.Chiaki org.gimp.GIMP -y
sudo dnf in -y steam yt-dlp @virtualization qbittorrent wine neofetch --best --allowerasing

sudo dnf clean all

# Initialize virtualization
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt $(whoami)

# Harden the Kernel with Kicksecure's patches
# TODO: Remove the disable of Bluetooth from these
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/modprobe.d/30_security-misc.conf -o /etc/modprobe.d/30_security-misc.conf
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_security-misc.conf -o /etc/sysctl.d/30_security-misc.conf
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_silent-kernel-printk.conf -o /etc/sysctl.d/30_silent-kernel-printk.conf

# Enable Kicksecure CPU mitigations
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/default/grub.d/40_cpu_mitigations.cfg -o /etc/grub.d/40_cpu_mitigations.cfg
# Kicksecure's CPU distrust script
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/default/grub.d/40_distrust_cpu.cfg -o /etc/grub.d/40_distrust_cpu.cfg
# Enable Kicksecure's IOMMU patch (limits DMA)
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/default/grub.d/40_enable_iommu.cfg -o /etc/grub.d/40_enable_iommu.cfg

# Divested's brace patches
# Sandbox the brace systemd permissions
# If you have VPN issues: https://old.reddit.com/r/DivestOS/comments/12b4fk4/comment/jex4qt2/
sudo mkdir -p /etc/systemd/system/NetworkManager.service.d
sudo curl https://gitlab.com/divested/brace/-/raw/master/brace/usr/lib/systemd/system/NetworkManager.service.d/99-brace.conf -o /etc/systemd/system/NetworkManager.service.d/99-brace.conf
sudo mkdir -p /etc/systemd/system/irqbalance.service.d
sudo curl https://gitlab.com/divested/brace/-/raw/master/brace/usr/lib/systemd/system/irqbalance.service.d/99-brace.conf -o /etc/systemd/system/irqbalance.service.d/99-brace.conf

# NTS instead of NTP
# NTS is a more secured version of NTP
sudo curl https://raw.githubusercontent.com/GrapheneOS/infrastructure/main/chrony.conf -o /etc/chrony.conf

# Remove Firewalld's Default Rules
sudo firewall-cmd --permanent --remove-port=1025-65535/udp
sudo firewall-cmd --permanent --remove-port=1025-65535/tcp
sudo firewall-cmd --permanent --remove-service=mdns
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --remove-service=samba-client

# Add services I use
sudo firewall-cmd --zone=public --add-service=syncthing --permanent
sudo firewall-cmd --zone=public --add-service=kdeconnect --permanent
sudo firewall-cmd --reload
