#!/bin/bash

# Configure dnf
echo -e "fastestmirror=True\nmax_parallel_downloads=10\ndefaultyes=True\ncountme=False" | sudo tee -a /etc/dnf/dnf.conf

# Setting umask to 077
# No one except wheel user and root get read/write files
umask 077
sudo sed -i 's/umask 002/umask 077/g' /etc/bashrc
sudo sed -i 's/umask 022/umask 077/g' /etc/bashrc

# Disable the Modular Repos
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-updates-modular.repo
sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum.repos.d/fedora-modular.repo

# Disable Machine Counting for all repos
sudo sed -i 's/countme=1/countme=0/g' /etc/yum.repos.d/*

# Debloat
sudo dnf remove abrt* adcli anaconda* hyperv* alsa-sof-firmware boost-date-time virtualbox-guest-additions yelp fedora-bookmarks mailcap open-vm-tools openconnect openvpn ppp pptp rsync samba-client unbound-libs vpnc yajl zd1211-firmware atmel-firmware libertas-usb8388-firmware mediawriter firefox xorg-x11-drv-vmware sos kpartx dos2unix sssd cyrus-sasl-plain geolite2* traceroute mtr realmd ModemManager teamd tcpdump mozilla-filesystem nmap-ncat plasma-welcome akregator dnfdragora kmahjongg kpat kmines gwenview kolourpaint okular kmail konversation krdc krfb kf5-ktnef dragon elisa-player kamoso kontact korganizer kwrite libreoffice* kcalc spice-vdagent

# Run Updates
sudo dnf upgrade --best --allowerasing --refresh -y
sudo dnf distro-sync -y

sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates -y
sudo fwupdmgr update -y

# Setup Flathub and Flatpak
# Flathub is enabled by default, but fails to install anything outside of Fedora still.
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Setup RPMFusion
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core -y

# Multimedia from RPMFusion
sudo dnf swap ffmpeg-free ffmpeg --allowerasing -y
sudo dnf groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin -y
sudo dnf groupupdate sound-and-video -y

sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y
sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y
sudo dnf swap mesa-va-drivers.i686 mesa-va-drivers-freeworld.i686 -y
sudo dnf swap mesa-vdpau-drivers.i686 mesa-vdpau-drivers-freeworld.i686 -y

# Install Flatpaks
flatpak install com.brave.Browser com.discordapp.Discord com.github.Matoking.protontricks com.github.zocker_160.SyncThingy com.heroicgameslauncher.hgl com.makemkv.MakeMKV com.spotify.Client com.steamgriddb.SGDBoop com.usebottles.bottles com.vscodium.codium dev.bsnes.bsnes fr.romainvigier.MetadataCleaner io.freetubeapp.FreeTube io.github.shiiion.primehack io.gitlab.librewolf-community io.mgba.mGBA net.davidotek.pupgui2 net.kuribo64.melonDS net.pcsx2.PCSX2 nz.mega.MEGAsync org.DolphinEmu.dolphin-emu org.citra_emu.citra org.duckstation.DuckStation org.kde.kid3 org.keepassxc.KeePassXC org.libreoffice.LibreOffice org.mozilla.firefox org.musicbrainz.Picard org.prismlauncher.PrismLauncher org.ryujinx.Ryujinx org.sonic3air.Sonic3AIR org.yuzu_emu.yuzu org.zdoom.GZDoom re.chiaki.Chiaki org.gimp.GIMP org.kde.okteta org.kde.okular org.kde.kwrite org.kde.kid3 org.kde.gwenview org.kde.kamoso org.kde.kcalc -y

# Install dnf packages
sudo dnf in -y steam yt-dlp @virtualization qbittorrent wine neofetch mpv kid3 nodejs stow tldr yt-dlp flac goverlay --best --allowerasing

# And also remove any packages without a source backing them
sudo dnf autoremove -y
sudo dnf clean all

# Initialize virtualization
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -a -G libvirt $(whoami)

# Harden the Kernel with Kicksecure's patches
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/modprobe.d/30_security-misc.conf -o /etc/modprobe.d/30_security-misc.conf
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_security-misc.conf -o /etc/sysctl.d/30_security-misc.conf
sudo curl https://raw.githubusercontent.com/Kicksecure/security-misc/master/etc/sysctl.d/30_silent-kernel-printk.conf -o /etc/sysctl.d/30_silent-kernel-printk.conf

sudo sed -i 's|install udf /bin/disabled-filesys-by-security-misc|#install udf /bin/disabled-filesys-by-security-misc|g' /etc/modprobe.d/30_security-misc.conf
sudo sed -i 's|install nfsv4 /bin/disabled-netfilesys-by-security-misc|#install nfsv4 /bin/disabled-netfilesys-by-security-misc|g' /etc/modprobe.d/30_security-misc.conf
sudo sed -i 's|install bluetooth /bin/disabled-bluetooth-by-security-misc|#install bluetooth /bin/disabled-bluetooth-by-security-misc|g' /etc/modprobe.d/30_security-misc.conf
sudo sed -i 's|install btusb /bin/disabled-bluetooth-by-security-misc|#install btusb /bin/disabled-bluetooth-by-security-misc|g' /etc/modprobe.d/30_security-misc.conf

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

# Make the Home folder private
# Privatizing the home folder creates problems with virt-manager
# accessing ISOs from your home directory. Store images in /var/lib/libvirt/images
chmod 700 /home/"$(whoami)"
