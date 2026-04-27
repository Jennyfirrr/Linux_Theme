#!/bin/bash
# Cycle power profile: balanced → performance → power-saver → balanced

case "$(powerprofilesctl get 2>/dev/null)" in
    balanced)    powerprofilesctl set performance ;;
    performance) powerprofilesctl set power-saver ;;
    *)           powerprofilesctl set balanced ;;
esac
