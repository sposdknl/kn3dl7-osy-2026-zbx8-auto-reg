#!/bin/bash
set -euo pipefail

version=$(dpkg-query -W -f='${Version}' zabbix-agent2 2>/dev/null || true)

case "$version" in
  *:8.*|8.*)
    echo "zabbix-agent2 $version je již nainstalován, přeskakuji instalaci."
    ;;
  *)
    # Starší agent 2 (např. 7.0) používá stejnou službu i konfiguraci jako verze 8.
    if [ -n "$version" ]; then
      systemctl stop zabbix-agent2 || true
      apt-get purge -y zabbix-agent2 zabbix-release || true
    fi

    # Oficiální repozitář Zabbix 8.0 LTS pro Debian 13.
    cd /tmp
    ok=0
    for url in \
      "https://repo.zabbix.com/zabbix/8.0/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_8.0+debian13_all.deb" \
      "https://repo.zabbix.com/zabbix/8.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_8.0+debian13_all.deb"; do
      if wget -qO zabbix-release.deb "$url"; then ok=1; break; fi
    done
    if [ "$ok" -ne 1 ]; then
      echo "Nepodařilo se stáhnout zabbix-release pro Debian 13." >&2
      exit 1
    fi
    dpkg -i zabbix-release.deb
    rm -f zabbix-release.deb
    apt-get update
    apt-get install -y zabbix-agent2
    ;;
esac

version=$(dpkg-query -W -f='${Version}' zabbix-agent2)
case "$version" in
  *:8.*|8.*) ;;
  *) echo "Neočekávaná verze zabbix-agent2: $version" >&2; exit 1 ;;
esac

zabbix_agent2 -V | head -n 1 || true
