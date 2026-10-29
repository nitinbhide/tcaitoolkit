#!/bin/bash

# Install specified agent skill
# Usage: ./install.sh <skill_name> <install_path>

SKILL_NAME="$1"
INSTALL_PATH="$2"

if [ -z "$SKILL_NAME" ]; then
    echo "Error: Skill name not provided."
    echo "Usage: ./install.sh <skill_name> <install_path>"
    exit 1
fi

if [ -z "$INSTALL_PATH" ]; then
    echo "Error: Install path not provided."
    echo "Usage: ./install.sh <skill_name> <install_path>"
    exit 1
fi

if [ ! -d "$INSTALL_PATH" ]; then
    echo "Error: Install path '$INSTALL_PATH' does not exist."
    exit 1
fi

AGENT_SKILL_ROOT=""
if [ -d "$INSTALL_PATH/.agents" ]; then
    AGENT_SKILL_ROOT="$INSTALL_PATH/.agents/skills"
elif [ -d "$INSTALL_PATH/.github" ]; then
    AGENT_SKILL_ROOT="$INSTALL_PATH/.github/skills"
elif [ -d "$INSTALL_PATH/.claude" ]; then
    AGENT_SKILL_ROOT="$INSTALL_PATH/.claude/skills"
fi

if [ -z "$AGENT_SKILL_ROOT" ]; then
    echo "Error: Neither '.agents', '.github', nor '.claude' folder found in '$INSTALL_PATH'."
    exit 1
fi

# Create the skills directory if it doesn't exist
mkdir -p "$AGENT_SKILL_ROOT"

SCRIPT_DIR=$(dirname "$0")
SOURCE_SKILL_PATH="$SCRIPT_DIR/$SKILL_NAME"
DEST_SKILL_PATH="$AGENT_SKILL_ROOT/$SKILL_NAME"

if [ ! -d "$SOURCE_SKILL_PATH" ]; then
    echo "Error: Skill '$SKILL_NAME' not found at '$SCRIPT_DIR'."
    exit 1
fi

echo "Installing skill '$SKILL_NAME' to '$AGENT_SKILL_ROOT'..."

# Back up the skill in every possible destination folder
for root in .agents .github .claude; do
    existing="$INSTALL_PATH/$root/skills/$SKILL_NAME"
    if [ -d "$existing" ]; then
        if [ -d "$existing.bak" ]; then
            echo "Removing existing backup: $existing.bak"
            rm -rf "$existing.bak"
        fi
        echo "Backing up existing skill folder to $existing.bak"
        mv "$existing" "$existing.bak"
    fi
done

# Copy the skill folder to the install path
echo "Copying skill folder..."
cp -r "$SOURCE_SKILL_PATH" "$DEST_SKILL_PATH"

if [ $? -eq 0 ]; then
    echo "Skill '$SKILL_NAME' installed successfully."
else
    echo "An error occurred during installation."
fi