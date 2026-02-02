#!/usr/bin/env bash
set -euo pipefail

# Wired & Wireless Display (Linux + scrcpy)
# - Lists USB / wireless adb devices
# - Optionally enables wireless adb (tcpip) and connects by IP
# - Launches scrcpy with sane defaults

die() { echo "Error: $*" >&2; exit 1; }
has() { command -v "$1" >/dev/null 2>&1; }

for bin in adb scrcpy; do
  has "$bin" || die "Missing dependency: '$bin'. Install it first (e.g. sudo apt install android-tools-adb scrcpy)."
done

adb start-server >/dev/null 2>&1 || true

prompt() {
  local msg="$1" default="${2:-}"
  if [[ -n "$default" ]]; then
    read -r -p "$msg [$default]: " ans || true
    echo "${ans:-$default}"
  else
    read -r -p "$msg: " ans || true
    echo "${ans}"
  fi
}

echo
echo "Wired & Wireless Display"
echo "-----------------------"
echo "1) USB (wired)"
echo "2) Wireless (already connected via adb)"
echo "3) Both"
echo "4) Set up wireless (tcpip 5555) + connect"
mode="$(prompt "Choose connection mode (1-4)" "1" | tr '[:upper:]' '[:lower:]')"

case "$mode" in
  1|usb) mode="usb" ;;
  2|wireless) mode="wireless" ;;
  3|both) mode="both" ;;
  4|setup|set\ up|wifi|wireless-setup|wireless_setup) mode="setup" ;;
  *) die "Invalid option: $mode" ;;
esac

# Helper: list devices in device state
list_devices() {
  adb devices | tail -n +2 | awk '/device$/{print $1}'
}

if [[ "$mode" == "setup" ]]; then
  echo
  echo "Wireless setup notes:"
  echo " - Phone and PC must be on the same Wi‑Fi"
  echo " - USB debugging must be enabled"
  echo " - Connect by USB for the first time, then we can switch adb to TCP/IP"
  echo

  echo "Looking for a USB device..."
  DEV_USB="$(list_devices | grep -v ':' || true)"
  [[ -n "$DEV_USB" ]] || die "No USB device found. Plug in your phone and accept the USB debugging prompt."

  # If multiple USB devices, choose one
  if [[ "$(echo "$DEV_USB" | wc -l)" -gt 1 ]]; then
    echo "Multiple USB devices found:"
    nl -w2 -s") " <<<"$DEV_USB"
    idx="$(prompt "Select device number" "1")"
    serial="$(echo "$DEV_USB" | sed -n "${idx}p")"
  else
    serial="$DEV_USB"
  fi

  echo "Using USB device: $serial"
  echo "Switching adb to TCP/IP on port 5555..."
  adb -s "$serial" tcpip 5555 >/dev/null

  ip="$(prompt "Enter phone IP address (Settings → About → Status or Wi‑Fi details)")"
  [[ -n "$ip" ]] || die "IP is required."
  port="$(prompt "Port" "5555")"

  echo "Connecting to $ip:$port ..."
  adb connect "$ip:$port" | sed 's/^/adb: /'
  mode="wireless"
  echo
  echo "Tip: next time you can choose option 2 (Wireless) as long as the device stays connected."
  echo
fi

DEVICES="$(list_devices || true)"
[[ -n "${DEVICES// }" ]] || die "No adb devices found. Run 'adb devices' and make sure USB debugging is enabled."

case "$mode" in
  usb)     FILTERED="$(echo "$DEVICES" | grep -v ':' || true)" ;;
  wireless)FILTERED="$(echo "$DEVICES" | grep ':' || true)" ;;
  both)    FILTERED="$DEVICES" ;;
esac

[[ -n "${FILTERED// }" ]] || die "No devices found for mode '$mode'."

if [[ "$(echo "$FILTERED" | wc -l)" -gt 1 ]]; then
  echo "Devices:"
  nl -w2 -s") " <<<"$FILTERED"
  idx="$(prompt "Select device number" "1")"
  DEVICE="$(echo "$FILTERED" | sed -n "${idx}p")"
  [[ -n "${DEVICE:-}" ]] || die "Invalid selection."
else
  DEVICE="$FILTERED"
fi

echo
echo "Display mode:"
echo "1) Windowed"
echo "2) Fullscreen"
dmode="$(prompt "Choose (1-2)" "1" | tr '[:upper:]' '[:lower:]')"
case "$dmode" in
  2|full|fullscreen) DISPLAY_FLAG="--fullscreen" ;;
  *) DISPLAY_FLAG="" ;;
esac

# Optional quality knobs
fps="$(prompt "Max FPS (0=default)" "60")"
bitrate="$(prompt "Video bitrate (e.g. 8M, 12M)" "12M")"

echo
echo "Launching scrcpy for: $DEVICE"
exec scrcpy -s "$DEVICE" --gamepad=uhid --max-size 0 --video-bit-rate "$bitrate" ${fps:+--max-fps "$fps"} $DISPLAY_FLAG
