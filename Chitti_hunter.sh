#!/bin/bash

# ==========================================
# 🚀 Chitti APK Hunter - Advanced Recon Tool
# Created by: Roshan 
# For Bug Bounty & Ethical Hacking
# ==========================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${CYAN}"
cat << "EOF"
  ___ _   _ ___ _____ _____   ___  ___  
 / __| |_| |_ _|_   _|_   _| /_\ | _ \ 
| (__|  _  || |  | |   | |  / _ \|  _/ 
 \___|_| |_|___| |_|   |_| /_/ \_\_|   
         HUNTER v1.0 ⚡
EOF
echo -e "${NC}"
echo -e "${BLUE}==========================================${NC}"
echo -e "Target APK: $1"
echo -e "${BLUE}==========================================${NC}"

if [ -z "$1" ]; then
    echo -e "${RED}[!] Usage: bash chitti_hunter.sh <path_to_apk>${NC}"
    exit 1
fi

APK_FILE=$1
BASE_DIR="Chitti_Recon_$(date +%s)"
UNZIP_DIR="$BASE_DIR/unzipped"
JADX_DIR="$BASE_DIR/jadx_out"
APKTOOL_DIR="$BASE_DIR/apktool_out"
RESULTS_DIR="$BASE_DIR/Results"
REPORT_FILE="$BASE_DIR/BUG_BOUNTY_REPORT.md"

mkdir -p "$RESULTS_DIR"

# Dependency Check
echo -e "\n${YELLOW}[*] Checking dependencies...${NC}"
for cmd in unzip apktool jadx grep; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}[-] $cmd is not installed. Please install it first.${NC}"
        # We won't exit for jadx/apktool in case they want a quick unzip, but we warn them
    fi
done

# 1. Unzip
echo -e "\n${YELLOW}[*] Phase 1: Extracting raw APK...${NC}"
unzip -o -q "$APK_FILE" -d "$UNZIP_DIR"

# 2. APKTool
echo -e "${YELLOW}[*] Phase 2: Decoding AndroidManifest & Resources...${NC}"
if command -v apktool &> /dev/null; then
    apktool d -f -q "$APK_FILE" -o "$APKTOOL_DIR"
fi

# 3. JADX
echo -e "${YELLOW}[*] Phase 3: Decompiling Source Code (This takes time)...${NC}"
if command -v jadx &> /dev/null; then
    jadx -d "$JADX_DIR" -q "$APK_FILE"
else
    echo -e "${RED}[-] JADX not found. Skipping deep source code decompilation.${NC}"
fi

echo -e "\n${GREEN}[+] Extraction Complete. Starting Deep Scan...${NC}"

# Function to extract, save, and print count
extract_pattern() {
    local pattern=$1
    local outfile=$2
    local description=$3
    
    grep -raEo "$pattern" "$BASE_DIR" 2>/dev/null | awk -F: '{print $2}' | sort -u > "$RESULTS_DIR/$outfile"
    local count=$(wc -l < "$RESULTS_DIR/$outfile")
    
    if [ "$count" -gt 0 ]; then
        echo -e "${GREEN}[+] Found $count $description${NC}"
        echo "## $description ($count found)" >> "$REPORT_FILE"
        echo '```' >> "$REPORT_FILE"
        head -n 20 "$RESULTS_DIR/$outfile" >> "$REPORT_FILE" # Print top 20 to report
        echo '```' >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
}

# Initialize Report
echo "# 🚀 Chitti APK Hunter Report" > "$REPORT_FILE"
echo "**Target:** \`$APK_FILE\`" >> "$REPORT_FILE"
echo "**Date:** $(date)" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"

echo -e "\n${CYAN}--- Scanning for Hidden Secrets ---${NC}"

extract_pattern "https?://[a-zA-Z0-9./?=_%:-]*" "urls.txt" "API Endpoints & URLs"
extract_pattern "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" "ips.txt" "IP Addresses"
extract_pattern "https://[a-zA-Z0-9-]+\.firebaseio\.com" "firebase.txt" "Firebase Databases"
extract_pattern "AKIA[0-9A-Z]{16}" "aws_keys.txt" "AWS Access Keys"
extract_pattern "AIza[0-9A-Za-z\\-_]{35}" "google_api.txt" "Google API Keys"
extract_pattern "sk_live_[0-9a-zA-Z]{24}" "stripe_live.txt" "Stripe Live Keys"
extract_pattern "eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*" "jwts.txt" "JSON Web Tokens (JWT)"
extract_pattern "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" "emails.txt" "Email Addresses"

# Secret Keywords
echo -e "\n${YELLOW}[*] Searching for hardcoded secrets...${NC}"
grep -raiE "(api_key|apikey|secret|token|password|bearer|authorization)[\"']?\s*[:=]\s*[\"'][^\"']+[\"']" "$BASE_DIR" 2>/dev/null | sort -u > "$RESULTS_DIR/secrets.txt"
if [ -s "$RESULTS_DIR/secrets.txt" ]; then
    echo -e "${RED}[!] Found potential hardcoded secrets! Check Results/secrets.txt${NC}"
    echo "## 🚨 Hardcoded Secrets" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
    head -n 20 "$RESULTS_DIR/secrets.txt" >> "$REPORT_FILE"
    echo '```' >> "$REPORT_FILE"
fi

echo -e "\n${CYAN}==========================================${NC}"
echo -e "${GREEN}✅ HUNT COMPLETE, BHAI!${NC}"
echo -e "Check the folder: ${YELLOW}$BASE_DIR${NC}"
echo -e "Markdown Report: ${YELLOW}$REPORT_FILE${NC} (Upload this to GitHub/Bug Bounty)"
echo -e "${CYAN}==========================================${NC}"
