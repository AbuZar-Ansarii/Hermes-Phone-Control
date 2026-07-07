#!/bin/bash
# ============================================================================
# Hermes Agent - Termux Installation Script
# ============================================================================
# Designed for setting up Hermes Agent on Android devices via Termux.
# Handles package updates, native toolchain dependencies, git cloning,
# virtual environment setup, psutil patch, and command launcher pathing.
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

log_info() {
    echo -e "${CYAN}→${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

print_banner() {
    echo -e "${BLUE}${BOLD}"
    echo "┌─────────────────────────────────────────────────────────┐"
    echo "│         ⚕ Hermes Phone Control - Termux Setup           │"
    echo "├─────────────────────────────────────────────────────────┤"
    echo "│ Installs Nous Research Hermes Agent + Android APIs      │"
    echo "└─────────────────────────────────────────────────────────┘"
    echo -e "${NC}"
}

# 1. Verification
print_banner

if [ -z "${TERMUX_VERSION:-}" ] && [[ "${PREFIX:-}" != *"com.termux/files/usr"* ]]; then
    log_error "This script is designed to run inside Termux on Android."
    log_warn "If you are running on desktop, please use the official installer:"
    echo "  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash"
    exit 1
fi

log_success "Termux environment detected."

# 2. Package Updates
log_info "Updating package repositories..."
pkg update -y || log_warn "pkg update returned some issues, proceeding anyway..."

# 3. Installing System Dependencies
log_info "Installing required build tools and libraries..."
# We install standard packages required to build python dependencies (like maturin, rust-based packages)
# termux-api is added to facilitate phone control capabilities
DEPS=(
    "git"
    "python"
    "clang"
    "rust"
    "make"
    "pkg-config"
    "libffi"
    "openssl"
    "ca-certificates"
    "curl"
    "nodejs"
    "ripgrep"
    "ffmpeg"
    "termux-api"
    "android-tools"
    "nmap"
)

log_info "Installing packages: ${DEPS[*]}"
pkg install -y "${DEPS[@]}"

# 4. Clone Hermes Agent Repo
HERMES_DIR="$HOME/hermes-agent"
if [ -d "$HERMES_DIR" ]; then
    log_info "Hermes Agent directory already exists. Pulling latest updates..."
    cd "$HERMES_DIR"
    git pull || log_warn "Failed to pull updates, proceeding with existing files"
else
    log_info "Cloning Hermes Agent repository..."
    git clone https://github.com/NousResearch/hermes-agent.git "$HERMES_DIR"
    cd "$HERMES_DIR"
fi

# 5. Virtual Environment Setup
log_info "Creating Python virtual environment..."
if [ -d "venv" ]; then
    log_warn "Existing virtual environment found, recreating..."
    rm -rf venv
fi

python -m venv venv
log_success "Virtual environment created."

# 6. Upgrade Pip and Build Tools inside venv
log_info "Upgrading pip, setuptools, and wheel in virtual environment..."
./venv/bin/python -m pip install --upgrade pip setuptools wheel

# 7. Apply Psutil Android Patch
# On Android, psutil requires a compatibility script before building.
if [ -f "scripts/install_psutil_android.py" ]; then
    log_info "Prebuilding psutil compatibility shim for Android..."
    if ./venv/bin/python scripts/install_psutil_android.py --pip "./venv/bin/python -m pip"; then
        log_success "psutil prebuilt successfully."
    else
        log_warn "psutil prebuild failed. Dependency installation might fail."
    fi
else
    log_warn "psutil prebuild script not found. Proceeding with standard install..."
fi

# 8. Install Hermes Package
log_info "Installing Hermes package and dependencies..."
# Try broad Termux profile first, then fallback to baseline Termux profile, then base install
if ./venv/bin/python -m pip install -e '.[termux-all]' -c constraints-termux.txt; then
    log_success "Installed Hermes with 'termux-all' profile."
elif ./venv/bin/python -m pip install -e '.[termux]' -c constraints-termux.txt; then
    log_success "Installed Hermes with baseline 'termux' profile."
else
    log_info "Trying base installation as fallback..."
    if ./venv/bin/python -m pip install -e '.' -c constraints-termux.txt; then
        log_success "Installed base Hermes package."
    else
        log_error "Package installation failed on Termux."
        echo -e "\nEnsure you have all packages installed:"
        echo "  pkg install clang rust make pkg-config libffi openssl -y"
        echo "Then run manually inside $HERMES_DIR:"
        echo "  ./venv/bin/python -m pip install -e '.[termux-all]' -c constraints-termux.txt"
        exit 1
    fi
fi

# 9. Create Launcher Symlink / Wrapper in $PREFIX/bin
log_info "Creating hermes launcher in $PREFIX/bin..."
LAUNCHER_PATH="$PREFIX/bin/hermes"
rm -f "$LAUNCHER_PATH"

cat > "$LAUNCHER_PATH" <<EOF
#!/usr/bin/env bash
# Hermes Agent Termux Wrapper
unset PYTHONPATH
unset PYTHONHOME
export ANDROID_API_LEVEL=\$(getprop ro.build.version.sdk 2>/dev/null || echo 24)
exec "$HERMES_DIR/venv/bin/hermes" "\$@"
EOF

chmod +x "$LAUNCHER_PATH"
log_success "Launcher created successfully at $LAUNCHER_PATH."

# 9b. Install Shizuku Rish Wrapper
log_info "Installing Shizuku 'rish' wrapper..."
if bash <(curl -fsSL https://raw.githubusercontent.com/merbah3266/rish_installer/clang_version/launcher.sh) --silent; then
    log_success "Shizuku 'rish' wrapper installed successfully."
else
    log_warn "Failed to automatically install 'rish'. You may need to run manual installation later."
fi

# 9c. Install phone-control helper in $PREFIX/bin
log_info "Installing phone-control helper in $PREFIX/bin..."
CONTROL_HELPER_PATH="$PREFIX/bin/phone-control"
rm -f "$CONTROL_HELPER_PATH"

if [ -f "$SCRIPT_DIR/phone-control" ]; then
    cp "$SCRIPT_DIR/phone-control" "$CONTROL_HELPER_PATH"
    chmod +x "$CONTROL_HELPER_PATH"
    log_success "phone-control helper installed successfully at $CONTROL_HELPER_PATH."
else
    log_info "phone-control local file not found. Downloading from repository..."
    if curl -fsSL "https://raw.githubusercontent.com/AbuZar-Ansarii/Hermes-Phone-Control/master/phone-control" -o "$CONTROL_HELPER_PATH"; then
        chmod +x "$CONTROL_HELPER_PATH"
        log_success "phone-control helper downloaded and installed successfully at $CONTROL_HELPER_PATH."
    else
        log_warn "Failed to download phone-control helper. Skipping."
    fi
fi

# 9ca. Install shizuku auto-connector in $PREFIX/bin
log_info "Installing shizuku auto-connector in $PREFIX/bin..."
SHIZUKU_HELPER_PATH="$PREFIX/bin/shizuku"
rm -f "$SHIZUKU_HELPER_PATH"

if [ -f "$SCRIPT_DIR/shizuku" ]; then
    cp "$SCRIPT_DIR/shizuku" "$SHIZUKU_HELPER_PATH"
    chmod +x "$SHIZUKU_HELPER_PATH"
    log_success "shizuku auto-connector installed successfully at $SHIZUKU_HELPER_PATH."
else
    log_info "shizuku local file not found. Downloading from repository..."
    if curl -fsSL "https://raw.githubusercontent.com/AbuZar-Ansarii/Hermes-Phone-Control/master/shizuku" -o "$SHIZUKU_HELPER_PATH"; then
        chmod +x "$SHIZUKU_HELPER_PATH"
        log_success "shizuku auto-connector downloaded and installed successfully at $SHIZUKU_HELPER_PATH."
    else
        log_warn "Failed to download shizuku auto-connector. Skipping."
    fi
fi

# 9cb. Deploy Hermes custom phone-control skill
log_info "Deploying custom phone-control skill for Hermes..."
SKILLS_DIR="$HOME/.hermes/skills/phone-control"
mkdir -p "$SKILLS_DIR"
SKILL_DEST="$SKILLS_DIR/SKILL.md"

if [ -f "$SCRIPT_DIR/skills/phone-control/SKILL.md" ]; then
    cp "$SCRIPT_DIR/skills/phone-control/SKILL.md" "$SKILL_DEST"
    log_success "Custom phone-control skill deployed successfully to $SKILL_DEST."
else
    log_info "SKILL.md local file not found. Downloading from repository..."
    if curl -fsSL "https://raw.githubusercontent.com/AbuZar-Ansarii/Hermes-Phone-Control/master/skills/phone-control/SKILL.md" -o "$SKILL_DEST"; then
        log_success "Custom phone-control skill downloaded and deployed successfully to $SKILL_DEST."
    else
        log_warn "Failed to deploy custom phone-control skill. Skipping."
    fi
fi


# 9d. Verify Shizuku authorization
log_info "Verifying Shizuku rish configuration..."
SHIZUKU_READY=false
if command -v rish &> /dev/null; then
    # Test rish connection in the background (timeout after 2 seconds)
    if timeout 2 rish -c "echo 'connected'" &> /dev/null; then
        log_success "Shizuku is active and authorized!"
        SHIZUKU_READY=true
    else
        log_warn "Shizuku daemon is either not running or Termux lacks authorization."
    fi
else
    log_warn "rish binary is missing."
fi

# 10. Complete Setup
echo -e "\n${GREEN}${BOLD}🎉 Installation Complete!${NC}"
echo -e "You can now run the agent by typing: ${CYAN}hermes${NC}\n"
echo -e "${BOLD}Next Steps:${NC}"
echo -e "1. Run setup to configure your API keys and models:"
echo -e "   ${CYAN}hermes setup${NC}"

if [ "$SHIZUKU_READY" = false ]; then
    echo -e "2. ${YELLOW}Configure Shizuku Control:${NC}"
    echo -e "   - Open the Shizuku app on your phone."
    echo -e "   - Start the Shizuku service (via Wireless Debugging or Root)."
    echo -e "   - In Termux, run: ${CYAN}rish${NC}"
    echo -e "   - When prompted by the system dialog, select ${GREEN}Allow / Always Allow${NC}."
    echo -e "   - Type ${CYAN}exit${NC} to return to Termux after authorization."
    echo -e "3. To ensure Hermes keeps running in the background:"
else
    echo -e "2. Shizuku is authorized! Your Hermes Agent can now control your phone via ${CYAN}phone-control${NC} command."
    echo -e "3. To ensure Hermes keeps running in the background:"
fi

echo -e "   - Open Android Settings -> Apps -> Termux -> Battery -> Set to ${YELLOW}Unrestricted${NC}."
echo -e "   - Pull down notification drawer and tap ${YELLOW}Acquire WakeLock${NC} in Termux notification."
echo -e "   - Run hermes in a ${CYAN}tmux${NC} session so it stays active when shell closes."

