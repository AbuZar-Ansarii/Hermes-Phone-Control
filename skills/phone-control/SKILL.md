---
name: phone-control
description: Control the host Android phone via Shizuku (touch inputs, launching apps, typing, WiFi toggling, volume, and screenshots)
version: 1.0.0
author: AbuZar Ansarii
license: MIT
platforms: [linux]
metadata:
  hermes:
    tags: [Android, Automation, Device Control]
---

# Phone Control Skill

This skill allows you to control the Android phone where Termux is running. You can perform taps, swipes, type text, launch apps, check the battery, toggle WiFi, search and play YouTube videos, take screenshots, and run arbitrary shell commands.

## Instructions

Whenever the user asks you to perform actions on their Android phone (e.g., play a song on YouTube, turn off WiFi, open an app, browse the screen), use the `phone-control` command in the shell.

### Critical Screen Automation Flow:
1. **Launch App**: Use `phone-control open <package>` (e.g., `com.google.android.youtube`).
2. **Analyze Screen**: Always run `phone-control read-screen` to see the current text elements and their coordinates `[x, y]` on the screen.
3. **Tap Button / Target**:
   - If you see the button's text in the output of `read-screen` (e.g., `[500, 600] Text: "Search"`), run `phone-control tap 500 600`.
   - Alternatively, you can run `phone-control tap-element "pattern"` where pattern matches the text or ID of the element.
4. **Type Text**: If you need to input text into a focused field, run `phone-control text "your input text"`.
5. **Scroll/Swipe**: If the target element is not on the screen or you need to view more content, use `phone-control swipe 500 1500 500 500` to scroll down.
6. **Chain Actions**: Do not stop after a single tap! Continue using `read-screen` and `tap` in a loop until the ultimate goal is fully achieved. Write a message to the user ONLY when the final goal is 100% completed.

### Available Commands:
- `phone-control tap <x> <y>` - Tap coordinates.
- `phone-control swipe <x1> <y1> <x2> <y2> [ms]` - Swipe coordinates.
- `phone-control text "<text>"` - Type text.
- `phone-control key <keycode>` - Send ADB key event.
- `phone-control home` - Go home.
- `phone-control back` - Press back.
- `phone-control enter` - Press enter.
- `phone-control open <package>` - Launch app.
- `phone-control wifi <on/off>` - Enable or disable WiFi.
- `phone-control play-yt "<query>"` - Plays a song on YouTube.
- `phone-control screenshot <path>` - Take screenshot.
- `phone-control read-screen` - Read text elements on screen.
- `phone-control tap-element <pattern>` - Tap element by text/ID match.
- `phone-control recent` - Open recent apps screen.
- `phone-control power` - Toggle power/screen state.
- `phone-control screenon` - Turn screen on.
- `phone-control shell "<cmd>"` - Run arbitrary ADB shell commands.
