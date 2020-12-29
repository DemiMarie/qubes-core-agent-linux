#!/bin/bash

# Source Qubes library.
# shellcheck source=init/functions
. /usr/lib/qubes/init/functions

# List of services enabled by default (in case of absence of qubesdb entry)
DEFAULT_ENABLED_NETVM="network-manager qubes-network qubes-update-check qubes-updates-proxy meminfo-writer qubes-firewall"
DEFAULT_ENABLED_PROXYVM="qubes-network qubes-firewall qubes-update-check meminfo-writer"
DEFAULT_ENABLED_APPVM="cups qubes-update-check meminfo-writer"
DEFAULT_ENABLED_TEMPLATEVM="$DEFAULT_ENABLED_APPVM updates-proxy-setup"
DEFAULT_ENABLED="meminfo-writer"

# Wait for xenbus initialization
while [ ! -e /dev/xen/xenbus ]; do
  sleep 0.1
done

mkdir -p /var/run/qubes
chgrp qubes /run/qubes
chmod 0775 /run/qubes
mkdir -p /var/run/qubes-service
mkdir -p /run/xen-hotplug

# Set default services depending on VM type
is_appvm && DEFAULT_ENABLED=$DEFAULT_ENABLED_APPVM && touch /run/qubes/this-is-appvm
is_netvm && DEFAULT_ENABLED=$DEFAULT_ENABLED_NETVM && touch /run/qubes/this-is-netvm
is_proxyvm && DEFAULT_ENABLED=$DEFAULT_ENABLED_PROXYVM && touch /run/qubes/this-is-proxyvm
is_templatevm && DEFAULT_ENABLED=$DEFAULT_ENABLED_TEMPLATEVM && touch /run/qubes/this-is-templatevm

# Enable default services
for srv in $DEFAULT_ENABLED; do
    touch "/run/qubes-service/$srv"
done

# Enable services
for srv in $(qubesdb-multiread /qubes-service/ 2>/dev/null |grep ' = 1'|cut -f 1 -d ' '); do
    touch "/run/qubes-service/$srv"
done

# Disable services
for srv in $(qubesdb-multiread /qubes-service/ 2>/dev/null |grep ' = 0'|cut -f 1 -d ' '); do
    rm -f "/run/qubes-service/$srv"
done

# Prepare environment for other services
echo > /run/qubes-service-environment

exit 0
