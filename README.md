# aws-cp-creds

Inspired from [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds).

Works on **macOS/Linux** (bash/zsh) and **Windows** (PowerShell).

## Motivation

If you're taking courses with AWS Academy, every time you start a lab session, you have to:
1. Open Canvas
2. Click "AWS Details"
3. Copy the credentials
4. Open `~/.aws/credentials` in TextEdit or vim
5. Paste and save

I got tired of manually editing the credentials file (or dealing with vim), so this partially automates it.

## What This Does

This script:
- Reads AWS credentials directly from your clipboard
- Supports multiple AWS profiles (default, work, staging, etc.)
- Validates the format (checks for profile headers and actual credential values)
- Updates only the specified profile in your `~/.aws/credentials` file, keeping other profiles intact
- Prevents you from pasting wrong or empty content

Now you just copy credentials from Canvas, and run `aws-cp-creds`

## Prerequisites

### macOS / Linux
- macOS (uses `pbpaste` for clipboard) or Linux (uses `xclip` or `xsel`)
- AWS CLI installed (or at least the `~/.aws` directory created)
- Terminal access

### Windows
- Windows 10/11 with PowerShell 5.1+ (pre-installed)
- AWS CLI installed (or the script will create `~\.aws` for you)

## Installation

### macOS / Linux

#### Quick Install (Recommended)

Run this command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/install.sh | bash
```

This will:
- Download the script to `~/update-aws-creds.sh`
- Add the `aws-cp-creds` alias to your shell config
- Set everything up automatically

After installation, open a new terminal window or run `source ~/.zshrc` (or `source ~/.bash_profile` for bash).

#### Manual Installation

If you prefer to install manually:

##### Step 1: Download the Script

Download the `update-aws-creds.sh` file to your home directory:

```bash
cd ~
# Download directly
curl -O https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/update-aws-creds.sh

# Or if you cloned the repo (update the path to where you cloned it)
# cp /path/to/repo/update-aws-creds.sh ~/update-aws-creds.sh
```

##### Step 2: Make the Script Executable

```bash
chmod +x ~/update-aws-creds.sh
```

##### Step 3: Add an Alias (Optional but Recommended)

This lets you run the script with a short command like `aws-cp-creds` instead of typing the full path.

**Open your shell config file:**
```bash
open -a TextEdit ~/.zshrc
```

> **Note:** If you prefer using terminal editors, you can use `nano ~/.zshrc` instead. I prefer TextEdit because it's more visual and familiar!

**Add this line at the end of the file:**
```bash
alias aws-cp-creds='~/update-aws-creds.sh'
```

**Save and close TextEdit**, then reload your shell (see troubleshooting if you use bash instead of zsh):
```bash
source ~/.zshrc
```

> **Tip:** You can use any alias name you want, aws-cp-creds is just what came to my mind to not confuse it with gimme-aws-creds (OKTA)

---

### Windows (PowerShell)

#### Quick Install (Recommended)

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/install.ps1 | iex
```

This will:
- Download the script to `~\update-aws-creds.ps1`
- Add the `aws-cp-creds` function to your PowerShell profile
- Set everything up automatically

After installation, open a new PowerShell window or run `. $PROFILE`.

> **Note:** If you get an error about execution policies, run this first:
> ```powershell
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

#### Manual Installation

##### Step 1: Download the Script

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/update-aws-creds.ps1" -OutFile "$env:USERPROFILE\update-aws-creds.ps1"
```

##### Step 2: Add to Your PowerShell Profile (Optional but Recommended)

Open your PowerShell profile in Notepad:
```powershell
notepad $PROFILE
```

> **Note:** If the file doesn't exist, PowerShell will ask if you want to create it. Click Yes.

Add this at the end of the file:
```powershell
function aws-cp-creds {
    & "$env:USERPROFILE\update-aws-creds.ps1" @args
}
```

Save and close Notepad, then reload your profile:
```powershell
. $PROFILE
```

## Usage

### Basic Usage

Every time you start a new AWS Academy lab:

1. Copy credentials from Canvas (click "AWS Details", select all, ⌘+C or Ctrl+C)
2. Run the command in your terminal:
   ```bash
   # macOS / Linux
   aws-cp-creds
   ```
   ```powershell
   # Windows PowerShell
   aws-cp-creds
   ```

The script will detect the profile name from your clipboard (usually `[default]`) and update only that profile.

### Using the --profile Flag

If you want to save credentials under a different profile name:

```bash
# macOS / Linux
aws-cp-creds --profile work
```
```powershell
# Windows PowerShell
aws-cp-creds -Profile work
```

This is useful when:
- You copy credentials that have `[default]` but want to save them as `[work]`
- You're managing multiple AWS accounts
- You want to organize your credentials by environment

## What the Script Validates

The script checks for these required fields before updating:
- Profile name format (letters, numbers, hyphens, underscores only)
- `aws_access_key_id` with an actual value
- `aws_secret_access_key` with an actual value
- `aws_session_token` with an actual value

If any are missing or invalid, it will tell you exactly what's wrong and won't overwrite your credentials file.

## Troubleshooting

### Command not found: aws-cp-creds

Your alias isn't loaded. Try:
```bash
source ~/.zshrc
```

Or open a new terminal window.

### Clipboard is empty

Make sure you actually copied the credentials (⌘+C) before running the command.

### Invalid credentials format

Double-check that you copied the entire credentials block from "AWS Details", not just part of it. It should include all three required fields with values.

### Script doesn't have execute permissions

Run:
```bash
chmod +x ~/update-aws-creds.sh
```

### Using bash instead of zsh?

If you're using bash, edit `~/.bash_profile` or `~/.bashrc` instead of `~/.zshrc`:
```bash
open -a TextEdit ~/.bash_profile
```

Then reload with:
```bash
source ~/.bash_profile
```

### Windows: Script won't run / execution policy error

Run this once in PowerShell:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Windows: Command not found: aws-cp-creds

Your profile function isn't loaded. Try:
```powershell
. $PROFILE
```

Or open a new PowerShell window.

### Windows: Clipboard is empty

Make sure you actually copied the credentials (Ctrl+C) before running the command. Also, `Get-Clipboard` requires a desktop session (won't work in headless/SSH scenarios).

## Credits

I love LLMs. Script and documentation created with assistance from Claude (Anthropic).

## Contributing

Found a bug or have a suggestion? Feel free to open an issue or submit a PR.

## License

MIT License - feel free to use and modify as needed.
