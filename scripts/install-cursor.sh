#!/usr/bin/env bash
set -euo pipefail

SKILL_NAME="spec-driven-develop"
REPO_URL="https://github.com/zhu1090093659/spec_driven_develop"
RAW_URL="https://raw.githubusercontent.com/zhu1090093659/spec_driven_develop/main"
TARGET_SKILLS_DIR="$HOME/.cursor/skills"
TARGET_DIR="$TARGET_SKILLS_DIR/$SKILL_NAME"
SKILLS_SUBPATH="plugins/spec-driven-develop/skills"
SKILL_SUBPATH="$SKILLS_SUBPATH/$SKILL_NAME"
BUNDLED_SKILLS=("spec-driven-develop" "deep-discuss" "review-spd")

# Extract version from SKILL.md frontmatter
extract_version() {
    sed -n 's/^[[:space:]]*version:[[:space:]]*//p' "$1" 2>/dev/null | sed -n '1p'
}

# Get the version currently installed
get_local_version() {
    local skill_file="$TARGET_DIR/SKILL.md"
    if [ -f "$skill_file" ]; then
        extract_version "$skill_file"
    fi
}

# Get the version from the source that will be used for installation
get_source_version() {
    local local_skill
    local_skill="$(dirname "$0")/../$SKILL_SUBPATH/SKILL.md"
    if [ -f "$local_skill" ] 2>/dev/null; then
        extract_version "$local_skill"
    else
        curl -sL "$RAW_URL/$SKILL_SUBPATH/SKILL.md" | sed -n 's/^[[:space:]]*version:[[:space:]]*//p' | sed -n '1p'
    fi
}

install_from_local() {
    local source_dir
    source_dir="$(cd "$(dirname "$0")/../$SKILLS_SUBPATH" && pwd)"
    if [ ! -d "$source_dir" ]; then
        echo "Error: source directory not found: $source_dir"
        exit 1
    fi
    cp -R "$source_dir"/. "$TARGET_SKILLS_DIR"/
}

install_from_remote() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    echo "Downloading from $REPO_URL ..."
    git clone --depth 1 --filter=blob:none --sparse "$REPO_URL" "$tmp_dir/repo" 2>/dev/null
    (cd "$tmp_dir/repo" && git sparse-checkout set "$SKILLS_SUBPATH" 2>/dev/null)

    if [ ! -d "$tmp_dir/repo/$SKILLS_SUBPATH" ]; then
        echo "Error: failed to download skill files."
        exit 1
    fi
    cp -R "$tmp_dir/repo/$SKILLS_SUBPATH"/. "$TARGET_SKILLS_DIR"/
}

do_install() {
    mkdir -p "$TARGET_SKILLS_DIR"
    if [ -f "$(dirname "$0")/../$SKILL_SUBPATH/SKILL.md" ] 2>/dev/null; then
        install_from_local
    else
        install_from_remote
    fi
}

# --- Main ---

if [ -d "$TARGET_DIR" ]; then
    local_version=$(get_local_version)
    source_version=$(get_source_version)

    if [ -z "$source_version" ]; then
        echo "Warning: could not determine source version."
        read -p "Re-install '$SKILL_NAME' (local: v${local_version:-unknown})? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
    elif [ "$local_version" = "$source_version" ]; then
        echo "'$SKILL_NAME' is already up to date (v$local_version)."
        exit 0
    else
        echo "Update available: v${local_version:-unknown} -> v$source_version"
        read -p "Update? [y/N] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
    fi
    for skill in "${BUNDLED_SKILLS[@]}"; do
        rm -rf "$TARGET_SKILLS_DIR/$skill"
    done
fi

do_install

installed_version=$(get_local_version)
echo "Installed bundled skills v${installed_version:-unknown} to $TARGET_SKILLS_DIR"
echo "Restart Cursor to activate the skill."
