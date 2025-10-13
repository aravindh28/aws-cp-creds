# aws-cp-creds

Inspired from [gimme-aws-creds](https://github.com/Nike-Inc/gimme-aws-creds).

**macOS only** - This script works with macOS(zsh/bash). Windows users will need a powershell script(I'll add that later).

## Why I Built This

If you're taking courses with AWS Academy, every time you start a lab session, you have to:
1. Open Canvas
2. Click "AWS Details"
3. Copy the credentials
4. Open `~/.aws/credentials` in TextEdit or vim
5. Paste and save

I got tired of manually editing the credentials file (or dealing with vim), so I automated it.

## What This Does

This script:
- Reads AWS credentials directly from your clipboard
- Validates the format (checks for `[default]`, `aws_access_key_id`, `aws_secret_access_key`, and `aws_session_token`)
- Updates your `~/.aws/credentials` file automatically
- Prevents you from pasting wrong or empty content

Now you just copy credentials from Canvas, and run `aws-cp-creds`

## Prerequisites

- macOS (uses `pbpaste` for clipboard access)
- AWS CLI installed (or at least the `~/.aws` directory created)
- Terminal access

## Installation

### Quick Install (Recommended)

Run this command in your terminal:

```bash
curl -fsSL https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/install.sh | bash
```

This will:
- Download the script to `~/update-aws-creds.sh`
- Add the `aws-cp-creds` alias to your shell config
- Set everything up automatically

After installation, open a new terminal window or run `source ~/.zshrc` (or `source ~/.bash_profile` for bash).

### Manual Installation

If you prefer to install manually:

#### Step 1: Download the Script

Download the `update-aws-creds.sh` file to your home directory:

```bash
cd ~
# Download directly
curl -O https://raw.githubusercontent.com/aravindh28/aws-cp-creds/main/update-aws-creds.sh

# Or if you cloned the repo (update the path to where you cloned it)
# cp /path/to/repo/update-aws-creds.sh ~/update-aws-creds.sh
```

#### Step 2: Make the Script Executable

```bash
chmod +x ~/update-aws-creds.sh
```

#### Step 3: Add an Alias (Optional but Recommended)

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

## Usage

Every time you start a new AWS Academy lab:

1. Copy credentials from Canvas (click "AWS Details", select all, ⌘+C)
2. Run the command in your terminal:
   ```bash
   aws-cp-creds
   ```

## What the Script Validates

The script checks for these required fields before updating:
- `[default]` section header
- `aws_access_key_id`
- `aws_secret_access_key`
- `aws_session_token`

If any are missing, it will tell you exactly what's wrong and won't overwrite your credentials file.

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

Double-check that you copied the entire credentials block from "AWS Details", not just part of it. It should include all four components listed above.

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

## Credits

I love LLMs. Script and documentation created with assistance from Claude (Anthropic).

## Contributing

Found a bug or have a suggestion? Feel free to open an issue or submit a PR.

## License

MIT License - feel free to use and modify as needed.
