# Wired & Wireless Display

**Mirror an Android handheld to a lightweight Linux box (Raspberry Pi or any Linux machine) using ADB + scrcpy.**

This is specifically aimed at **Android handhelds that *can’t* (or shouldn’t) use HDMI/DisplayPort output** (or where capture cards/docks are annoying),
so you can still play/stream/record on a bigger screen with keyboard/controller input forwarded through scrcpy.

Works great on:
- Raspberry Pi (Pi 4/5 recommended, but any modern Pi can work)
- mini PCs, old laptops, thin clients
- basically any Linux distro that can install `adb` + `scrcpy`

## What you get
- `Connect.sh` — your original device picker + scrcpy launcher
- `wwd.sh` — an enhanced script with:
  - dependency checks (`adb`, `scrcpy`)
  - **wireless setup** mode (switches ADB to TCP/IP `5555` and connects by IP)
  - better device selection UX
  - easy performance knobs (FPS / bitrate)

## Requirements (Linux)
- `scrcpy`
- `adb` (Android platform tools)

### Raspberry Pi OS / Debian / Ubuntu
```bash
sudo apt update
sudo apt install -y scrcpy android-tools-adb
```

### Fedora
```bash
sudo dnf install -y scrcpy android-tools
```

## Android handheld setup (one-time)
1. Enable **Developer options**
2. Enable **USB debugging**
3. Plug in once over USB and **accept** the “Allow USB debugging” prompt

## Run
From the project folder:
```bash
chmod +x wwd.sh
./wwd.sh
```

If you prefer the original:
```bash
chmod +x Connect.sh
./Connect.sh
```

## Wireless mode (ADB over Wi‑Fi)
- Use `wwd.sh` → option **4** once to switch the handheld to TCP/IP and connect.
- After that, as long as the device stays reachable on Wi‑Fi, option **2** works.

Manual reconnect:
```bash
adb connect <handheld-ip>:5555
adb devices
```

## Raspberry Pi performance tips
If you’re running on a Pi / low-power box:
- Keep bitrate moderate (e.g. `6M`–`12M`)
- Cap FPS to something realistic (e.g. `30` or `60`)
- Prefer USB if your Wi‑Fi is flaky (USB is usually lower latency)

The enhanced script prompts you for **bitrate** and **FPS** each run.

## Website
Open `website/index.html` in a browser, or serve it:
```bash
cd website
python3 -m http.server 8080
```
Then open `http://localhost:8080`.

## License
MIT (feel free to use and remix).
