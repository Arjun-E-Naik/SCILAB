#!/bin/bash
# =============================================================================
# setup.sh — Installs Scilab inside GitHub Codespace / GitLab CI
# =============================================================================

set -e

echo "============================================"
echo " FOSSEE IP Toolbox — Environment Setup"
echo "============================================"

# Update package list
echo "[1/3] Updating apt..."
sudo apt-get update -qq

# Install Scilab CLI (headless, no GUI needed)
echo "[2/3] Installing Scilab..."
sudo apt-get install -y scilab scilab-cli --no-install-recommends

# Verify installation
echo "[3/3] Verifying Scilab..."
scilab-cli -version

echo ""
echo "✅ Setup complete!"
echo "   Run all tests with:  bash tests/run_all_tests.sh"
echo "   Run one function  :  bash tests/run_all_tests.sh immse"
echo "============================================"