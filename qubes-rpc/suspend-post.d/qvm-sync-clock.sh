#!/bin/sh

if [ ! -f /run/qubes-service/clocksync ]; then
    /usr/bin/qvm-sync-clock
fi
