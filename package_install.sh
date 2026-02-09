#!/bin/sh

LOG_FILE="./error_log.txt"

if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root."
  exit 1
fi

echo "Starting package installation..."

if [ -f /etc/os-release ]; then
  . /etc/os-release

  # Fallback to ID if ID_LIKE is empty
  ID_MATCH="${ID_LIKE:-$ID}"

  case "$ID_MATCH" in
  *debian* | *ubuntu* | *devuan* | *kali* | *raspbian* | *linuxmint* | *pop*)
    echo "Step 1: Detected Debian/Ubuntu-based system..."
    echo "Step 2: Updating package lists..."
    export DEBIAN_FRONTEND=noninteractive

    apt-get update --quiet
    apt-get upgrade --quiet

    echo "Step 3: Installing packages..."
    apt-get install --yes --ignore-missing --quiet \
      apparmor \
      apparmor-utils \
      apt \
      audispd-plugins \
      audit \
      audit-libs \
      auditd \
      automake \
      bash \
      busybox \
      ca-certificates \
      chrootkit \
      coreutils \
      curl \
      dash \
      debsums \
      dpkg \
      gcc \
      git \
      gnupg \
      gnupg2 \
      htop \
      iotop \
      iptables \
      iptables-persistent \
      iptables-services \
      libc6 \
      libpam-modules \
      libpam-pwquality \
      libpam-tmpdir \
      libpwquality \
      libtool \
      lsof \
      lynis \
      make \
      micro \
      nano \
      needrestart \
      net-tools \
      nmap \
      openssh-server \
      openssl \
      passwd \
      pigz \
      pkg-config \
      polkitd \
      rkhunter \
      rsyslog \
      rsyslog \
      setools-console \
      sudo \
      sysstat \
      tcpdump \
      unhide \
      unzip \
      util-linux \
      vim \
      wget \
      wireshark \
      yara \
      yum-utils \
      zstd
    ;;

  *rocky* | *rhel* | *fedora* | *centos* | *alma* | *ol* | *amzn* | *cloudlinux*)
    echo "Step 1: Detected RHEL/CentOS-based system..."

    if command -v dnf >/dev/null 2>&1; then
      PKG_MGR="dnf"
    else
      PKG_MGR="yum"
    fi

    echo "Step 2: Preparing repositories..."
    if ! grep -q "Amazon Linux" /etc/os-release; then
      # -y: Answer yes
      "${PKG_MGR}" install --assumeyes --quiet epel-release
    fi

    "${PKG_MGR}" makecache

    echo "Step 3: Installing packages..."

    "${PKG_MGR}" install --assumeyes --skip-broken --quiet \
      apparmor \
      apparmor-utils \
      apt \
      audispd-plugins \
      audit \
      audit-libs \
      auditd \
      automake \
      bash \
      busybox \
      ca-certificates \
      chrootkit \
      coreutils \
      curl \
      dash \
      debsums \
      dpkg \
      gcc \
      git \
      gnupg \
      gnupg2 \
      htop \
      iotop \
      iptables \
      iptables-persistent \
      iptables-services \
      libc6 \
      libpam-modules \
      libpam-pwquality \
      libpam-tmpdir \
      libpwquality \
      libtool \
      lsof \
      lynis \
      make \
      micro \
      nano \
      needrestart \
      net-tools \
      nmap \
      openssh-server \
      openssl \
      passwd \
      pigz \
      pkg-config \
      polkitd \
      rkhunter \
      rsyslog \
      rsyslog \
      setools-console \
      sudo \
      sysstat \
      tcpdump \
      unhide \
      unzip \
      util-linux \
      vim \
      wget \
      wireshark \
      yara \
      yum-utils \
      zstd
    ;;

  *alpine*)
    echo "Step 1: Detected Alpine Linux..."
    echo "Step 2: Updating package lists..."
    apk update >/dev/null 2>>"$LOG_FILE"

    ALPINE_PKGS="audit bash busybox-extras ca-certificates coreutils curl git gnupg htop ip6tables iptables lsof lynis nano net-tools nmap nmap-scripts openssh openssl passwd pigz python3 rkhunter rsyslog sudo sysstat tcpdump unzip vim wget zstd"

    echo "Step 3: Installing packages..."
    # apk add is generally non-interactive by default for known packages
    apk add $ALPINE_PKGS
    ;;

  *suse* | *sles*)
    echo "Step 1: Detected SUSE Linux..."
    echo "Step 2: Refreshing repositories..."
    # --non-interactive: Don't ask questions
    zypper --non-interactive refresh >/dev/null 2>>"$LOG_FILE"

    SUSE_PKGS="audit bash busybox ca-certificates coreutils curl git gpg2 htop iptables lsof lynis nano net-tools nmap openssh openssl pam passwd pigz rkhunter rsyslog sudo sysstat tcpdump unzip util-linux vim wget zstd"

    echo "Step 3: Installing packages..."
    # -n: Non-interactive
    # -y: Yes
    zypper --non-interactive install -y $SUSE_PKGS
    ;;

  *arch* | *manjaro*)
    echo "Step 1: Detected Arch Linux..."
    echo "Step 2: syncing package databases..."
    # --noconfirm: Do not ask for any confirmation
    pacman -Sy --noconfirm >/dev/null 2>>"$LOG_FILE"

    ARCH_PKGS="audit bash ca-certificates coreutils curl git gnupg htop iptables lsof lynis nano net-tools nmap openssh openssl pam pigz python rkhunter rsyslog sudo sysstat tcpdump unzip util-linux vim wget zstd"

    echo "Step 3: Installing packages..."
    # --noconfirm: Answer yes to all
    # --needed: Don't reinstall up-to-date packages
    pacman -S --noconfirm --needed $ARCH_PKGS
    ;;

  *)
    echo "Error: Distro not supported."
    exit 1
    ;;
  esac
fi

echo "Finished installing packages."
