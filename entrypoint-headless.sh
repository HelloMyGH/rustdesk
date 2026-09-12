#!/bin/sh
set -e

export DISPLAY=:0

CONFIG_DIR="${HOME}/.config/RustDesk"
mkdir -p "${CONFIG_DIR}"
MAIN_CFG="${CONFIG_DIR}/RustDesk.toml"

RD_SERVER="${RD_SERVER:-192.168.9.234}"
RD_RELAY="${RD_RELAY:-${RD_SERVER}}"
RD_PASSWORD="${RD_PASSWORD:-1234}"

write_opt() {
    key="$1"
    val="$2"
    if grep -q "^${key}=" "${MAIN_CFG}" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}='${val}'|" "${MAIN_CFG}"
    else
        echo "${key}='${val}'" >> "${MAIN_CFG}"
    fi
}

write_opt custom-rendezvous-server "${RD_SERVER}"
write_opt relay-server "${RD_RELAY}"
write_opt key ""
write_opt verification-method "use-permanent-password"
write_opt enable-audio "N"
write_opt enable-record-session "N"

Xvfb :0 -screen 0 1920x1080x24 -ac +extension RANDR +extension RENDER &
XVFB_PID=$!

sleep 2

/usr/lib/rustdesk/rustdesk --server --no-tray &
SERVER_PID=$!

sleep 5
/usr/lib/rustdesk/rustdesk --password "${RD_PASSWORD}" || \
    echo "WARN: set password via IPC failed, retry or check server log"

wait ${SERVER_PID}