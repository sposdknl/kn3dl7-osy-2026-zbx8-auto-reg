#!/bin/bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

# Základní nástroje pro správu a diagnostiku.
apt-get update
apt-get install -y bash fastfetch joe vim htop btop mc nmap git curl wget ca-certificates netcat-openbsd