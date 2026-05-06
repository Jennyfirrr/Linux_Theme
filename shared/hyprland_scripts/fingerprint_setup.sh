#!/bin/bash

# FoxML Fingerprint Automation
# Automates fprintd enrollment and PAM configuration for the Lenovo P15

set -e

# Colors for output
PEACH='\033[0;33m'
SAGE='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${PEACH}🦊 FoxML Fingerprint Setup Initialized...${NC}"

# 1. Check for fprintd
if ! pacman -Qi fprintd &>/dev/null; then
    echo "  Installing fprintd..."
    sudo pacman -S --needed --noconfirm fprintd
fi

# 2. Enrollment
echo -e "\n${PEACH}[1/3] Enrolling your fingerprint...${NC}"
echo "Please tap your right index finger on the reader when the light blinks."
fprintd-enroll $USER

# 3. PAM Configuration
echo -e "\n${PEACH}[2/3] Configuring PAM (System Authentication)...${NC}"

PAM_FILES=("/etc/pam.d/sudo" "/etc/pam.d/system-local-login" "/etc/pam.d/greetd")
PAM_LINE="auth      sufficient  pam_fprintd.so"

for file in "${PAM_FILES[@]}"; do
    if [[ -f "$file" ]]; then
        if grep -q "pam_fprintd.so" "$file"; then
            echo "  ✓ $file already configured"
        else
            # Insert at the top of the file
            sudo sed -i "1i $PAM_LINE" "$file"
            echo "  ✓ Configured $file"
        fi
    fi
done

# 4. SSH Keyring Verification
echo -e "\n${PEACH}[3/3] Optimizing SSH Keyring...${NC}"
if grep -q "ssh-agent" ~/.zshrc || grep -q "gnome-keyring" ~/.zshrc; then
     echo "  ✓ SSH Keyring already integrated in Zsh"
else
     echo "  Adding SSH Keyring auto-unlock to .zshrc..."
     cat >> ~/.zshrc << 'EOF'

# FoxML SSH Keyring Integration
if command -v gnome-keyring-daemon >/dev/null; then
    eval $(gnome-keyring-daemon --start --components=ssh)
    export SSH_AUTH_SOCK
fi
EOF
     echo "  ✓ SSH Keyring added to .zshrc"
fi

echo -e "\n${SAGE}✨ Setup Complete!${NC}"
echo "You can now use your fingerprint for sudo, login, and unlocking SSH keys."
echo "Note: Re-source your terminal (source ~/.zshrc) to activate the SSH changes."
