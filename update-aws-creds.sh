#!/bin/bash
# AWS Academy Credentials Updater with Multi-Profile Support

# Parse command line arguments
OVERRIDE_PROFILE=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --profile)
            if [ -z "$2" ]; then
                echo "Error: --profile requires a profile name"
                echo "Usage: $0 [--profile PROFILE_NAME]"
                exit 1
            fi
            if [[ ! "$2" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                echo "Error: Invalid profile name '$2'"
                echo "Profile names can only contain letters, numbers, hyphens, and underscores"
                exit 1
            fi
            OVERRIDE_PROFILE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--profile PROFILE_NAME]"
            exit 1
            ;;
    esac
done

echo "Checking clipboard content..."

# Get clipboard content
if command -v pbpaste >/dev/null 2>&1; then
    CLIPBOARD=$(pbpaste)
elif command -v xclip >/dev/null 2>&1; then
    CLIPBOARD=$(xclip -selection clipboard -o)
elif command -v xsel >/dev/null 2>&1; then
    CLIPBOARD=$(xsel --clipboard --output)
else
    echo "Error: No supported clipboard tool found (pbpaste, xclip, or xsel)"
    exit 1
fi

# Check if clipboard is empty
if [ -z "$CLIPBOARD" ]; then
    echo "Error: Clipboard is empty"
    exit 1
fi

# Determine profile name
if [ -n "$OVERRIDE_PROFILE" ]; then
    PROFILE_NAME="$OVERRIDE_PROFILE"
    echo "Using profile from command line: [$PROFILE_NAME]"
    # Strip any existing profile header from clipboard
    CLIPBOARD=$(echo "$CLIPBOARD" | grep -v '^\[[a-zA-Z0-9_-]\+\]$')
else
    # Extract profile name from clipboard (alphanumeric, underscore, hyphen only)
    PROFILE_NAME=$(echo "$CLIPBOARD" | grep -o '^\[[a-zA-Z0-9_-]\+\]' | head -1 | tr -d '[]')
    
    # If no profile found, assume default
    if [ -z "$PROFILE_NAME" ]; then
        PROFILE_NAME="default"
        echo "No profile found in clipboard, using [default]"
    else
        echo "Detected profile: [$PROFILE_NAME]"
    fi
fi

# Validate required fields with actual values
MISSING_FIELDS=()
[[ ! "$CLIPBOARD" =~ aws_access_key_id[[:space:]]*=[[:space:]]*[^[:space:]]+ ]] && MISSING_FIELDS+=("aws_access_key_id")
[[ ! "$CLIPBOARD" =~ aws_secret_access_key[[:space:]]*=[[:space:]]*[^[:space:]]+ ]] && MISSING_FIELDS+=("aws_secret_access_key")
[[ ! "$CLIPBOARD" =~ aws_session_token[[:space:]]*=[[:space:]]*[^[:space:]]+ ]] && MISSING_FIELDS+=("aws_session_token")

if [ ${#MISSING_FIELDS[@]} -ne 0 ]; then
    echo "Error: Invalid credentials format"
    echo "Missing fields: ${MISSING_FIELDS[*]}"
    exit 1
fi

# Prepare content to write - ensure profile header is included
if echo "$CLIPBOARD" | grep -q "^\[$PROFILE_NAME\]"; then
    CONTENT_TO_WRITE="$CLIPBOARD"
else
    CONTENT_TO_WRITE="[$PROFILE_NAME]
$CLIPBOARD"
fi

# Path to credentials file
CREDS_FILE=~/.aws/credentials

# Ensure .aws directory exists
mkdir -p ~/.aws

# If credentials file doesn't exist, create it
if [ ! -f "$CREDS_FILE" ]; then
    echo "$CONTENT_TO_WRITE" > "$CREDS_FILE"
    chmod 600 "$CREDS_FILE"
    echo "Credentials updated: [$PROFILE_NAME]"
    exit 0
fi

# Create temporary file
TEMP_FILE=$(mktemp)
chmod 600 "$TEMP_FILE"
trap 'rm -f "$TEMP_FILE"' EXIT

# Read existing file and update the target profile
IN_TARGET_PROFILE=false
PROFILE_FOUND=false

while IFS= read -r line || [ -n "$line" ]; do
    # Check if this is a profile header (alphanumeric, underscore, hyphen only)
    if [[ "$line" =~ ^\[[a-zA-Z0-9_-]+\]$ ]]; then
        CURRENT_PROFILE=$(echo "$line" | tr -d '[]')
        
        if [ "$CURRENT_PROFILE" = "$PROFILE_NAME" ]; then
            # Found target profile - write new credentials
            IN_TARGET_PROFILE=true
            PROFILE_FOUND=true
            echo "$CONTENT_TO_WRITE" >> "$TEMP_FILE"
        else
            # Different profile - exit target if we were in it
            [ "$IN_TARGET_PROFILE" = true ] && IN_TARGET_PROFILE=false
            echo "$line" >> "$TEMP_FILE"
        fi
    else
        # Not a profile header - keep line if not in target profile
        [ "$IN_TARGET_PROFILE" = false ] && echo "$line" >> "$TEMP_FILE"
    fi
done < "$CREDS_FILE"

# If profile wasn't found, append it
if [ "$PROFILE_FOUND" = false ]; then
    echo "" >> "$TEMP_FILE"
    echo "$CONTENT_TO_WRITE" >> "$TEMP_FILE"
fi

# Replace original file
mv "$TEMP_FILE" "$CREDS_FILE"
chmod 600 "$CREDS_FILE"

echo "Credentials updated: [$PROFILE_NAME]"
