Verify if the environment is ready for FoxML theme development and AI operations.

Instructions:
1. **AI Check**:
   - Verify `ollama` service is active (`systemctl is-active ollama`).
   - Check if the required models are pulled: `qwen2.5-coder:7b`, `14b`, and `32b`.
   - Verify `opencode` config exists at `~/.config/opencode/opencode.json`.
2. **System Check**:
   - Check if essential tools are in PATH: `hyprctl`, `waybar`, `nvim`, `kitty`.
   - If NVIDIA is present, check `nvidia-smi` for driver health.
3. **Hardware Check**:
   - Check available VRAM (need 4GB for models).
   - Check RAM (need 32GB for 32B model).
4. **Summary**:
   - Provide a "Readiness Report" with [READY] or [NOT READY] status for each category.
   - List specific commands to fix any missing requirements.
