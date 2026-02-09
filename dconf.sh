#!/bin/sh

set -u
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

if ! command -v dconf >/dev/null 2>&1; then
  echo "dconf not installed"
  exit 0
fi

mkdir -p /etc/dconf/profile
mkdir -p /etc/dconf/db/local.d/locks

if [ ! -f /etc/dconf/profile/user ]; then
  printf "user-db:user\nsystem-db:local\n" >/etc/dconf/profile/user
fi

cat >/etc/dconf/db/local.d/01-ccdc-security <<EOF
[org/gnome/desktop/media-handling]
automount=false
automount-open=false

[org/gnome/settings-daemon/plugins/media-keys]
custom-keybindings=['']

[org/gnome/login-screen]
disable-user-list=true

[org/gnome/desktop/privacy]
remember-recent-files=false
remember-app-usage=false
remove-old-trash-files=true
remove-old-temp-files=true
EOF

cat >/etc/dconf/db/local.d/locks/01-ccdc-locks <<EOF
/org/gnome/desktop/media-handling/automount
/org/gnome/desktop/media-handling/automount-open
/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
/org/gnome/login-screen/disable-user-list
/org/gnome/desktop/privacy/remember-recent-files
EOF

dconf update

getent passwd | while IFS=: read -r username _ uid _ _ homedir _; do
  if [ "$uid" -ge 1000 ] && [ "$uid" -lt 60000 ]; then
    if [ -d "$homedir" ]; then
      DCONF_FILE="$homedir/.config/dconf/user"

      if [ -f "$DCONF_FILE" ]; then
        echo "Wiping local dconf for: $username"
        rm -f "$DCONF_FILE"
      fi
    fi
  fi
done
