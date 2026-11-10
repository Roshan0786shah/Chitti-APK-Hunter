import os
import subprocess
import re
import sys
import time

# Colors for Terminal
GREEN = '\033[0;32m'
CYAN = '\033[0;36m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

# New Clean CHITTI Banner
BANNER = f"""{CYAN}
  ██████╗██╗  ██╗██╗████████╗████████╗██╗
 ██╔════╝██║  ██║██║╚══██╔══╝╚══██╔══╝██║
 ██║     ███████║██║   ██║      ██║   ██║
 ██║     ██╔══██║██║   ██║      ██║   ██║
 ╚██████╗██║  ██║██║   ██║      ██║   ██║
  ╚═════╝╚═╝  ╚═╝╚═╝   ╚═╝      ╚═╝   ╚═╝
       {YELLOW}⚡ APK HUNTER v1.0 ⚡{NC}
"""

def print_banner():
    os.system('clear')
    print(BANNER)
    print(f"{BLUE}=========================================={NC}")

def check_dependencies():
    print(f"\n{YELLOW}[*] Checking dependencies...{NC}")
    missing = []
    for cmd in ["apktool", "jadx"]:
        if subprocess.call(["which", cmd], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL) != 0:
            missing.append(cmd)
    
    if missing:
        print(f"{RED}[!] Warning: {', '.join(missing)} is not installed or not in PATH.{NC}")
        print(f"{YELLOW}[*] The script will continue, but deep analysis might be skipped.{NC}")
    else:
        print(f"{GREEN}[+] All dependencies found.{NC}")

def extract_apk(apk_path, out_dir):
    print(f"\n{YELLOW}[*] Phase 1: Extracting raw APK...{NC}")
    os.makedirs(out_dir, exist_ok=True)
    subprocess.call(["unzip", "-o", "-q", apk_path, "-d", out_dir])

def decompile_resources(apk_path, out_dir):
    print(f"{YELLOW}[*] Phase 2: Decoding AndroidManifest & Resources (apktool)...{NC}")
    subprocess.call(["apktool", "d", "-f", "-q", apk_path, "-o", out_dir])

def decompile_source(apk_path, out_dir):
    print(f"{YELLOW}[*] Phase 3: Decompiling Source Code (JADX - This takes time)...{NC}")
    try:
        subprocess.call(["jadx", "-d", out_dir, "-q", apk_path])
    except Exception as e:
        print(f"{RED}[!] JADX failed: {e}{NC}")

def scan_directory(directory, regex_pattern):
    found = set()
    for root, _, files in os.walk(directory):
        for file in files:
            file_path = os.path.join(root, file)
            try:
                with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
                    matches = re.findall(regex_pattern, content)
                    for match in matches:
                        if isinstance(match, tuple):
                            found.add(match[0])
                        else:
                            found.add(match)
            except Exception:
                pass
    return sorted(list(found))

def generate_report(results, report_file, target_name):
    with open(report_file, "w", encoding="utf-8") as f:
        f.write(f"# 🚀 Chitti APK Hunter Report\n")
        f.write(f"**Target:** `{target_name}`\n")
        f.write(f"**Date:** {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("---\n\n")
        
        for category, data in results.items():
            if data:
                f.write(f"## {category} ({len(data)} found)\n")
                f.write("```\n")
                for item in data[:30]: # Limit to 30 to keep report small
                    f.write(f"{item}\n")
                if len(data) > 30:
                    f.write("... and more (check specific .txt file)\n")
                f.write("```\n\n")

def main():
    print_banner()
    
    # Ask for APK Path
    apk_path = input(f"{GREEN}[?] Enter path to APK file (e.g., /sdcard/app.apk): {NC}").strip()
    
    if not os.path.isfile(apk_path):
        print(f"{RED}[-] File not found: {apk_path}{NC}")
        sys.exit(1)
        
    check_dependencies()
    
    base_dir = f"Chitti_Recon_{int(time.time())}"
    unzip_dir = os.path.join(base_dir, "unzipped")
    jadx_dir = os.path.join(base_dir, "jadx_out")
    apktool_dir = os.path.join(base_dir, "apktool_out")
    results_dir = os.path.join(base_dir, "Results")
    report_file = os.path.join(base_dir, "BUG_BOUNTY_REPORT.md")
    
    os.makedirs(results_dir, exist_ok=True)
    
    extract_apk(apk_path, unzip_dir)
    decompile_resources(apk_path, apktool_dir)
    decompile_source(apk_path, jadx_dir)
    
    print(f"\n{GREEN}[+] Extraction Complete. Starting Deep Scan on {base_dir}...{NC}")
    
    # Regex Patterns
    patterns = {
        "API Endpoints & URLs": r"https?://[a-zA-Z0-9./?=_%:-]*",
        "IP Addresses": r"\b([0-9]{1,3}\.){3}[0-9]{1,3}\b",
        "Firebase Databases": r"https://[a-zA-Z0-9-]+\.firebaseio\.com",
        "AWS Access Keys": r"AKIA[0-9A-Z]{16}",
        "Google API Keys": r"AIza[0-9A-Za-z\-_]{35}",
        "Stripe Live Keys": r"sk_live_[0-9a-zA-Z]{24}",
        "JWT Tokens": r"eyJ[A-Za-z0-9-_=]+\.[A-Za-z0-9-_=]+\.?[A-Za-z0-9-_.+/=]*",
        "Email Addresses": r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}",
        "Potential Secrets": r"(?i)(api_key|apikey|secret|token|password|bearer|authorization)[\"']?\s*[:=]\s*[\"'][^\"']+[\"']"
    }
    
    all_results = {}
    
    for name, regex in patterns.items():
        print(f"{CYAN}[*] Scanning for {name}...{NC}", end="", flush=True)
        found = scan_directory(base_dir, regex)
        all_results[name] = found
        
        # Save to individual txt file
        filename = name.lower().replace(" ", "_").replace("&", "and") + ".txt"
        with open(os.path.join(results_dir, filename), "w", encoding="utf-8") as f:
            for item in found:
                f.write(f"{item}\n")
                
        if found:
            print(f" {GREEN}[{len(found)} found]{NC}")
        else:
            print(f" {RED}[0 found]{NC}")
            
    generate_report(all_results, report_file, os.path.basename(apk_path))
    
    print(f"\n{CYAN}=========================================={NC}")
    print(f"{GREEN}✅ HUNT COMPLETE, BHAI!{NC}")
    print(f"Check the folder: {YELLOW}{base_dir}{NC}")
    print(f"Markdown Report: {YELLOW}{report_file}{NC}")
    print(f"{CYAN}=========================================={NC}")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{RED}[!] Scan cancelled by user.{NC}")
        sys.exit(0)
