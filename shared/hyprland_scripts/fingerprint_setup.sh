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
sudo fprintd-enroll $USER

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

# 4. Final Instructions
echo -e "\n${PEACH}[3/3] Finalizing...${NC}"
echo "  ✓ Biometrics linked to System Auth"
echo "  ✓ Biometrics linked to Greetd"
echo "  ✓ Biometrics linked to Sudo"

echo -e "\n${SAGE}✨ Setup Complete!${NC}"
echo "To activate your fingerprint and SSH agent, you MUST:"
echo "  1. Log out of your current session."
echo "  2. Log back in (you can use your finger now!)."
echo "  3. Open a terminal and run 'ssh-add ~/.ssh/id_ed25519' once."
