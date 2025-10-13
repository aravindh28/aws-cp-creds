#!/bin/bash
# AWS Academy Credentials Updater

echo "Checking clipboard content..."

# Get clipboard content
CLIPBOARD=$(pbpaste)

# Check if clipboard is empty
if [ -z "$CLIPBOARD" ]; then
    echo "Clipboard is empty. Copy credentials first."
    exit 1
fi

# Validate required fields
MISSING_FIELDS=()

if ! echo "$CLIPBOARD" | grep -q "\[default\]"; then
    MISSING_FIELDS+=("[default]")
fi

if ! echo "$CLIPBOARD" | grep -q "aws_access_key_id"; then
    MISSING_FIELDS+=("aws_access_key_id")
fi

if ! echo "$CLIPBOARD" | grep -q "aws_secret_access_key"; then
    MISSING_FIELDS+=("aws_secret_access_key")
fi

if ! echo "$CLIPBOARD" | grep -q "aws_session_token"; then
    MISSING_FIELDS+=("aws_session_token")
fi

# If any fields are missing, show error
if [ ${#MISSING_FIELDS[@]} -ne 0 ]; then
    echo "Invalid credentials format"
    echo "Missing fields: ${MISSING_FIELDS[*]}"
    echo ""
    echo "Make sure you copied the complete credentials from 'AWS Details' in Canvas."
    exit 1
fi

# Write to credentials file
echo "$CLIPBOARD" > ~/.aws/credentials

echo "AWS credentials updated successfully!"
echo ""
echo "New credentials active in: ~/.aws/credentials"