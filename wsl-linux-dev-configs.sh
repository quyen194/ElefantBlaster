#!/usr/bin/env bash

set -euo pipefail

# ────────────────────────────────────────────────
# CONFIGURATION
# ────────────────────────────────────────────────

MNT_ROOT="/mnt/k/git/ElefantBlaster"
HOME_ROOT="${HOME}/projects/ElefantBlaster"
BRANCH="wsl"

# List of relative paths (relative to MNT_ROOT)
# Order here determines the order shown in help
REPO_PATHS=(
    "."                             # main repo (root)
    "ElefantBlasterClient"
    "ElefantBlasterServer"
    "ElefantBlasterServerInterface"
    "ElefantBlasterCommon"
    "libs/aries_base"
    "libs/aries_base/third_party/spdlog"
    "libs/abseil-cpp"
    "libs/asio"
    "libs/glm"
    "libs/json"
    "libs/protobuf"
    "libs/SDL"
    "libs/SDL_image"
    "libs/SDL_mixer"
    "libs/SDL_net"
    "libs/SDL_ttf"
    "libs/websocketpp"
    "libs/imgui"
    "libs/wxWidgets"
)

# ────────────────────────────────────────────────
# Helper functions
# ────────────────────────────────────────────────

# Create worktree and mark directories as safe
add_worktree() {
    local src_dir="$1"
    local dest_dir="$2"

    git config --global --add safe.directory "$src_dir" 2>/dev/null || true
    mkdir -p "$(dirname "$dest_dir")"

    if [[ -d "$dest_dir" ]]; then
        echo "→ Already exists: $dest_dir (skipping)"
        return 0
    fi

    echo "→ Creating worktree: $dest_dir  ←  $src_dir"

    cd "$src_dir" || { echo "Cannot cd to $src_dir" >&2; return 1; }

    if git worktree list --porcelain | grep -qF "$dest_dir"; then
        echo "  Worktree already registered → skipping"
        return 0
    fi

    git worktree add "$dest_dir" "$BRANCH" || {
        echo "Failed to create worktree for $src_dir" >&2
        return 1
    }

    git config --global --add safe.directory "$dest_dir" 2>/dev/null || true
    echo "  OK"
}

# Convert relative path to display name (special case: "." → "main")
get_dest_name() {
    local rel_path="$1"

    if [[ "$rel_path" == "." ]]; then
        echo "main"
    else
        basename "$rel_path"
    fi
}

# Display usage information
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [REPO_NAME]

Creates git worktrees from $MNT_ROOT to $HOME_ROOT for WSL/development.

Options:
  --help, -h              Show this help message and exit

No arguments:           Create worktrees for ALL repositories
REPO_NAME:              Create worktree only for the specified repository

Examples:
  $(basename "$0")                        # Create all
  $(basename "$0") main                   # Root repo
  $(basename "$0") ElefantBlasterClient
  $(basename "$0") libs/glm

Available repositories:
EOF

    for path in "${REPO_PATHS[@]}"; do
        name=$(get_dest_name "$path")
        echo "  - $name"
    done | sort

    echo ""
    exit 0
}

# ────────────────────────────────────────────────
# Main logic
# ────────────────────────────────────────────────

# Show help if requested
if [[ $# -eq 1 ]] && { [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; }; then
    show_help
fi

# Validate source root
if [[ ! -d "$MNT_ROOT" ]]; then
    echo "Error: $MNT_ROOT does not exist." >&2
    exit 1
fi

mkdir -p "$HOME_ROOT"

if [[ $# -eq 0 ]]; then
    # Create worktrees for all repositories
    echo "Creating worktrees for ALL repositories..."
    for rel_path in "${REPO_PATHS[@]}"; do
        src="${MNT_ROOT}/${rel_path}"
        dest_name=$(get_dest_name "$rel_path")
        dest="${HOME_ROOT}/${dest_name}"

        [[ -d "$src" ]] || {
            echo "Skipping (not found): $src"
            continue
        }

        add_worktree "$src" "$dest"
    done

elif [[ $# -eq 1 ]]; then
    # Create worktree for a single specified repo
    requested="$1"
    found=false

    for rel_path in "${REPO_PATHS[@]}"; do
        name=$(get_dest_name "$rel_path")

        if [[ "$name" == "$requested" || "$rel_path" == "$requested" ]]; then
            src="${MNT_ROOT}/${rel_path}"
            dest="${HOME_ROOT}/${name}"

            if [[ ! -d "$src" ]]; then
                echo "Error: Source not found: $src" >&2
                exit 1
            fi

            found=true
            add_worktree "$src" "$dest"
            break
        fi
    done

    if [[ $found == false ]]; then
        echo "No matching repo found: $requested" >&2
        echo ""
        echo "Available:"
        for p in "${REPO_PATHS[@]}"; do
            echo "  - $(get_dest_name "$p")"
        done | sort
        echo ""
        echo "Run with --help for more information."
        exit 1
    fi

else
    echo "Too many arguments." >&2
    echo "Run with --help for usage."
    exit 1
fi

echo ""
echo "Done."
