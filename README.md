# Hermes Phone Control - Termux Setup Guide

This repository contains a dedicated Termux installation script to deploy **Hermes Agent** on Android devices. Hermes Agent is an autonomous, self-improving AI framework developed by Nous Research, capable of running directly on your phone.

Using the included installer script, you can easily install the agent, configure dependencies, and integrate with Android system functions using Termux APIs.

---

## 🚀 Quick Setup Instructions

### Step 1: Clone or Copy the Installer to Termux
Open **Termux** on your Android device and run:

```bash
# 1. Ensure git is installed to retrieve the script
pkg install git -y

# 2. Clone your repository (replace with your repo URL if using a private fork)
git clone https://github.com/AbuZar-Ansarii/Hermes-Phone-Control.git "$HOME/Hermes-Phone-Control"

# 3. Navigate into the repository directory
cd "$HOME/Hermes-Phone-Control"

# 4. Make the installation script executable
chmod +x install.sh
```

---

### Step 2: Run the Installation Script
Execute the script to start the setup process:

```bash
./install.sh
```

#### What the script does:
1. Updates Termux package repositories.
2. Installs required native libraries (`git`, `python`, `clang`, `rust`, `make`, `pkg-config`, `libffi`, `openssl`, `nodejs`, `ripgrep`, `ffmpeg`, `android-tools`).
3. Installs `termux-api` for Android operating system integration.
4. Clones the official `NousResearch/hermes-agent` codebase into `$HOME/hermes-agent`.
5. Creates a Python virtual environment (`venv`).
6. Prebuilds the Android-compatible `psutil` compatibility shim to avoid build errors.
7. Installs the Hermes package with optimal Termux baseline or extended profiles.
8. Sets up a user wrapper command `hermes` in `$PREFIX/bin` so you can launch it from anywhere.
9. Installs the Shizuku `rish` wrapper using the silent native C installer.
10. Installs the custom `phone-control` script helper in `$PREFIX/bin` to allow advanced device control.

---

### Step 3: Run Hermes Setup
Once the script completes, restart your Termux session or source your profile. Then run the interactive configuration wizard:

```bash
hermes setup
```

You will be prompted to:
- Choose your LLM Provider (e.g., Anthropic, OpenAI, OpenRouter, local/remote endpoints).
- Enter your API keys.
- Choose models (e.g., Hermes 3, Claude 3.5 Sonnet, GPT-4o, etc.).
- Set up notification gateways (like Telegram or Discord) to interact with your agent remotely.

---

## 📱 Advanced Phone Control via Shizuku & Termux:API

By combining **Shizuku (Wireless Debugging)** with **Termux:API**, you can grant Hermes Agent complete, high-privilege programmatic access to your phone (such as opening apps, clicking elements on the screen, typing, taking screenshots, and playing music).

---

### Part 1: Setting up Shizuku Wireless Debugging

To allow Hermes to perform touch actions and manage applications:

1. **Install Shizuku App**: Download and install [Shizuku from Google Play Store](https://play.google.com/store/apps/details?id=moe.shizuku.privileged.api) or GitHub.
2. **Enable Developer Options**: Go to Android Settings -> About Phone -> Tap **Build Number** 7 times.
3. **Enable Wireless Debugging**: Go to Developer Options -> Toggle on **Wireless Debugging**.
4. **Pair & Start Shizuku**:
   - Open Shizuku, tap **Pairing**, then **Developer Options**.
   - Tap **Wireless Debugging** -> **Pair device with pairing code**.
   - Enter the pairing code in the Shizuku notification box.
   - Go back to Shizuku's main screen and tap **Start**.
5. **Authorize Termux**:
   - Inside Termux, run `rish` once.
   - A system popup will appear asking to authorize Termux. Tap **Allow** (or **Always Allow**).
   - Type `exit` to return to your Termux shell.

---

### Part 2: High-Privilege Control (`phone-control`)

Our installer configures a custom `phone-control` wrapper script. Hermes Agent can call this script through its built-in `terminal` execution tools to control your phone.

#### Available Commands:
*   **Tap coordinates**: `phone-control tap <x> <y>`
*   **Swipe/Scroll**: `phone-control swipe <x1> <y1> <x2> <y2> [duration_ms]`
*   **Type text**: `phone-control text "Your text here"` (handles spaces automatically)
*   **Hardware keys**: `phone-control home`, `phone-control back`, `phone-control enter`
*   **Press keyevent**: `phone-control key <keycode>`
*   **Open App**: `phone-control open <package_name>`
    *   *Example*: `phone-control open com.google.android.youtube`
*   **Analyze Screen UI**: `phone-control read-screen`
    *   *Dumps the XML UI hierarchy, parses it, and lists all visible elements with their center coordinates.*
*   **Semantic Tap**: `phone-control tap-element <pattern>`
    *   *Finds the element matching the search text or ID on the screen and taps it automatically.*
*   **Play Song on YouTube**: `phone-control play-yt "<song or artist>"`
    *   *Launches YouTube, searches for the song, and automatically locates and taps the first search result.*
*   **Screenshot**: `phone-control screenshot <path>`

---

### Part 3: Low-Level Sensors & Hardware (`termux-api`)

Ensure you have the companion [Termux:API F-Droid app](https://f-droid.org/en/packages/com.termux.api/) installed.

*   **Text-to-Speech:** `termux-tts-speak "Hello, I am Hermes!"`
*   **Vibrate:** `termux-vibrate -d 500`
*   **Get Location:** `termux-location`
*   **Send SMS:** `termux-sms-send -n +1234567890 "Message from Hermes"`
*   **Battery Status:** `termux-battery-status`
*   **Take Photo:** `termux-camera-photo -c 0 output.jpg`


---

## ⚡ Keeping Hermes Alive in the Background

Android aggressive power management will kill background apps. To keep your agent running continuously:

1.  **Unrestrict Battery Usage:**
    *   Go to **Android Settings** -> **Apps** -> **Termux** -> **Battery**.
    *   Set Battery optimization to **Unrestricted** / **No restrictions**.
2.  **Acquire WakeLock:**
    *   Open Termux, swipe down your notification drawer, and tap **Acquire WakeLock**. This keeps CPU active when the screen is off.
3.  **Use `tmux` for persistence:**
    *   Install tmux: `pkg install tmux -y`
    *   Start a new session: `tmux new -s hermes`
    *   Run the agent: `hermes`
    *   Detach from session: Press `Ctrl + B` then `D`
    *   To re-attach later: `tmux attach -t hermes`
