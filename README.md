# 🚀 Chitti APK Hunter

**Chitti APK Hunter** is an advanced Bash-based tool designed for Bug Bounty Researchers and Ethical Hackers to perform deep static analysis on Android APKs. It extracts hidden API endpoints, hardcoded secrets, Firebase URLs, and more.

## ✨ Features
- **Deep Extraction:** Uses `jadx` and `apktool` to decompile source code and resources.
- **Smart Regex Hunting:** Finds APIs, IPs, Emails, JWTs, AWS keys, Google API keys, Stripe keys, and Firebase URLs.
- **Hardcoded Secrets:** Scans for variables like `api_key`, `secret`, `token`, etc.
- **Auto Markdown Report:** Generates a `BUG_BOUNTY_REPORT.md` file, ready to be submitted or uploaded to GitHub.
- **Termux Friendly:** Works perfectly on Android via Termux.

## 🛠️ Prerequisites (Termux / Linux)
You need Java, JADX, APKTool, and standard Linux tools installed.
```bash
pkg update && pkg install openjdk-17 apktool unzip wget -y
wget https://github.com/skylot/jadx/releases/download/v1.4.7/jadx-1.4.7.zip
unzip jadx-1.4.7.zip -d jadx
export PATH=$PATH:$(pwd)/jadx/bin



git clone https://github.com/yourusername/Chitti-APK-Hunter.git
cd Chitti-APK-Hunter
chmod +x chitti_hunter.sh
./chitti_hunter.sh /path/to/target.apk




---

### 🔥 Is Version me kya naya hai?
1. **Professional Look:** Ekdum hacker-style ASCII banner (`Chitti APK Hunter`) aur colored output, jo kisi bhi GitHub repo ki shaan badha dega.
2. **Bug Bounty Report Generator:** Ye sabse bada upgrade hai. Ye saare results ko ek `BUG_BOUNTY_REPORT.md` file me save karega. Researcher ko bas us file ko copy-paste karna hoga.
3. **Advanced Regex Patterns:** Humne `Google API Keys`, `Stripe Live Keys`, `JWT Tokens`, aur `Firebase URLs` ka scan bhi add kar diya hai, jo modern bug bounties me sabse zyada kaam aate hain.
4. **Smart Folder Naming:** Ab har baar scan karne par folder timestamp ke sath banega, taaki purana data delete na ho.

Isko test kar, aur agar koi naya idea aaye toh bata. GitHub par is repo ka naam `Chitti-APK-Hunter` rakhna ekdam mast lagega! ⚡
