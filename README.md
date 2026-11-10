# 🚀 Chitti APK Hunter

**Chitti APK Hunter** is an advanced Python-based tool designed for Bug Bounty Researchers and Ethical Hackers to perform deep static analysis on Android APKs. It extracts hidden API endpoints, hardcoded secrets, Firebase URLs, JWTs, and more with an interactive command-line interface.

## ✨ Features
- **Interactive CLI:** Just run the script and it will prompt you for the APK path.
- **Deep Extraction:** Uses `jadx` and `apktool` to decompile source code and resources.
- **Python Regex Engine:** Uses Python's built-in `re` module for faster and more accurate scanning compared to traditional `grep`.
- **Smart Hunting:** Finds APIs, IPs, Emails, JWTs, AWS keys, Google API keys, Stripe keys, and Firebase URLs.
- **Hardcoded Secrets:** Scans for variables like `api_key`, `secret`, `token`, `bearer`, etc.
- **Auto Markdown Report:** Generates a `BUG_BOUNTY_REPORT.md` file, ready to be submitted or uploaded to GitHub.
- **Termux Friendly:** Works perfectly on Android via Termux.

## 🛠️ Prerequisites (Termux / Linux)

You need Python, Java, JADX, APKTool, and standard Linux tools installed. Run the following commands in Termux:

```bash
# 1. Update packages and install dependencies
pkg update && pkg install python openjdk-17 apktool unzip wget -y

# 2. Download and setup JADX
wget https://github.com/skylot/jadx/releases/download/v1.4.7/jadx-1.4.7.zip
unzip jadx-1.4.7.zip -d jadx
export PATH=$PATH:$(pwd)/jadx/bin


# 1. Clone the repository
git clone https://github.com/Roshan0786shah/Chitti-APK-Hunter.git

# 2. Navigate to the directory
cd Chitti-APK-Hunter

# 3. Run the Python script
python chitti_hunter.py


Once prompted, simply enter the path to your target APK (e.g., /sdcard/Download/target.apk). The tool will handle the extraction, decompilation, and scanning automatically.

📂 Output Structure

After the scan is complete, the tool creates a folder named Chitti_Recon_<timestamp>. Inside, you will find:

· Results/ — Categorized .txt files for URLs, IPs, Secrets, Emails, etc.
· BUG_BOUNTY_REPORT.md — A ready-to-use Markdown report containing the top findings, ready for your bug bounty submission.

⚠️ Disclaimer

This tool is created for educational purposes and legal Bug Bounty hunting only.

The developer (Chitti / Roshan0786shah) assumes no liability and is not responsible for any misuse, damage, or illegal activities caused by this program.

By using this tool, you agree that:

1. You will only use it on applications you own or have explicit, written permission to test.
2. You will not use it for any malicious purposes or unauthorized access.
3. You are solely responsible for your actions and any legal consequences that may arise.

Always ensure you have permission to test the target application before running this tool.
