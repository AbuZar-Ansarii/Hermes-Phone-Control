# Hermes Phone Control - Termux Setup Guide

This repository contains a dedicated Termux installation script to deploy **Hermes Agent** on Android devices. Hermes Agent is an autonomous, self-improving AI framework developed by Nous Research, capable of running directly on your phone.

Using the included installer script, you can easily install the agent, configure dependencies, and integrate with Android system functions using Termux APIs.

---

## 🚀 Quick Setup Instructions

### Option A: 1-Click Install (Recommended)
Open **Termux** on your Android device and paste:

```bash
curl -fsSL https://raw.githubusercontent.com/AbuZar-Ansarii/Hermes-Phone-Control/master/install.sh | bash
```

---

### Option B: Manual Git Clone Setup
Open **Termux** on your Android device and run:

```bash
# 1. Ensure git is installed to retrieve the script
pkg install git -y

# 2. Clone your repository
git clone https://github.com/AbuZar-Ansarii/Hermes-Phone-Control.git "$HOME/Hermes-Phone-Control"

# 3. Navigate into the repository directory
cd "$HOME/Hermes-Phone-Control"

# 4. Make the installation script executable and run it
chmod +x install.sh
./install.sh
```

#### What the script does:
1. Updates Termux package repositories.
2. Installs required native libraries (`git`, `python`, `clang`, `rust`, `make`, `pkg-config`, `libffi`, `openssl`, `nodejs`, `ripgrep`, `ffmpeg`, `android-tools`, `nmap`).
3. Installs `termux-api` for Android operating system integration.
4. Clones the official `NousResearch/hermes-agent` codebase into `$HOME/hermes-agent`.
5. Creates a Python virtual environment (`venv`).
6. Prebuilds the Android-compatible `psutil` compatibility shim to avoid build errors.
7. Installs the Hermes package with optimal Termux baseline or extended profiles.
8. Sets up a user wrapper command `hermes` in `$PREFIX/bin`.
9. Installs the Shizuku `rish` wrapper using the silent native C installer.
10. Installs the `shizuku` auto-connector utility (`$PREFIX/bin/shizuku`) to start the daemon in one click.
11. Installs the custom `phone-control` script helper in `$PREFIX/bin/phone-control` to execute advanced device actions.
12. Deploys the custom phone-control skill to `~/.hermes/skills/phone-control/SKILL.md` to give Hermes native instruction awareness.

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

By combining **Shizuku (Wireless Debugging)** with **Termux:API**, you can grant Hermes Agent complete, high-privilege programmatic access to your phone (such as toggling Wi-Fi, opening apps, clicking elements on the screen, typing, taking screenshots, and playing music).

---

### Part 1: Setting up Shizuku (Zero-Root / Auto-Connect)

To allow Hermes to perform touch actions and manage applications:

1. **Install Shizuku App**: Download and install [Shizuku from Google Play Store](https://play.google.com/store/apps/details?id=moe.shizuku.privileged.api) or GitHub.
2. **Enable Developer Options**: Go to Android Settings -> About Phone -> Tap **Build Number** 7 times.
3. **Enable Wireless Debugging**: Go to Developer Options -> Toggle on **Wireless Debugging**.
4. **Automated Shizuku Launch**:
   - Turn on Wireless Debugging.
   - In Termux, type:
     ```bash
     shizuku
     ```
   - This script automatically scans your local device port range (30000-50000) using `nmap`, connects local ADB, starts the Shizuku app daemon, and shuts down Wireless Debugging to conserve battery.
5. **One-Time Termux Authorization**:
   - In Termux, type `rish` once.
   - When the system dialog asks to authorize Termux access, tap **Allow / Always Allow**.
   - Type `exit` to return to your normal Termux prompt.

---

### Part 2: High-Privilege Control (`phone-control`)

Our installer configures a custom `phone-control` wrapper script. Hermes Agent can call this script through its built-in `terminal` execution tools to control your phone.

#### Available Commands:
*   **Tap coordinates**: `phone-control tap <x> <y>`
*   **Swipe/Scroll**: `phone-control swipe <x1> <y1> <x2> <y2> [duration_ms]`
*   **Type text**: `phone-control text "Your text here"` (handles spaces automatically)
*   **Hardware keys**: `phone-control home`, `phone-control back`, `phone-control enter`, `phone-control recent`
*   **Toggle Power/Lock**: `phone-control power`
*   **Wake up screen**: `phone-control screenon`
*   **Toggle WiFi**: `phone-control wifi <on/off>`
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
*   **Arbitrary ADB commands**: `phone-control shell "<command_string>"`

---

### Part 3: Hermes Skill Integration

During the installation process, a custom Hermes skill is deployed to `~/.hermes/skills/phone-control/SKILL.md`. This gives the Hermes Agent direct, cognitive awareness of the `phone-control` toolset, teaching it how to loop commands, analyze screen states, and navigate the Android environment autonomously.


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
