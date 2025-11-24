#!/usr/bin/env bash

# Define project roots to avoid repeating literal paths
MNT_ROOT="/mnt/k/git/ElefantBlaster"
HOME_ROOT="${HOME}/projects/ElefantBlaster"

# Check if MNT_ROOT directory exists
if ([ ! -d "${MNT_ROOT}" ] ); then
    echo "Error: MNT_ROOT directory '${MNT_ROOT}' does not exist."
    exit 1
fi

# Create HOME_ROOT directory if it doesn't exist
if ([ ! -d "${HOME_ROOT}" ] ); then
    mkdir -p "${HOME_ROOT}"
fi

# Set up git worktrees for WSL development environment
git config --global --add safe.directory "${MNT_ROOT}"
cd "${MNT_ROOT}"
git worktree add "${HOME_ROOT}" wsl
git config --global --add safe.directory "${HOME_ROOT}"

# Set up worktrees for each sub-repository
git config --global --add safe.directory "${MNT_ROOT}/ElefantBlasterClient"
cd "${MNT_ROOT}/ElefantBlasterClient"
git worktree add "${HOME_ROOT}/ElefantBlasterClient" wsl
git config --global --add safe.directory "${HOME_ROOT}/ElefantBlasterClient"

git config --global --add safe.directory "${MNT_ROOT}/ElefantBlasterServer"
cd "${MNT_ROOT}/ElefantBlasterServer"
git worktree add "${HOME_ROOT}/ElefantBlasterServer" wsl
git config --global --add safe.directory "${HOME_ROOT}/ElefantBlasterServer"

git config --global --add safe.directory "${MNT_ROOT}/libs/abseil-cpp"
cd "${MNT_ROOT}/libs/abseil-cpp"
git worktree add "${HOME_ROOT}/libs/abseil-cpp" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/abseil-cpp"

git config --global --add safe.directory "${MNT_ROOT}/libs/aries_base"
cd "${MNT_ROOT}/libs/aries_base"
git worktree add "${HOME_ROOT}/libs/aries_base" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/aries_base"

git config --global --add safe.directory "${MNT_ROOT}/libs/asio"
cd "${MNT_ROOT}/libs/asio"
git worktree add "${HOME_ROOT}/libs/asio" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/asio"

git config --global --add safe.directory "${MNT_ROOT}/libs/glm"
cd "${MNT_ROOT}/libs/glm"
git worktree add "${HOME_ROOT}/libs/glm" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/glm"

git config --global --add safe.directory "${MNT_ROOT}/libs/json"
cd "${MNT_ROOT}/libs/json"
git worktree add "${HOME_ROOT}/libs/json" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/json"

git config --global --add safe.directory "${MNT_ROOT}/libs/protobuf"
cd "${MNT_ROOT}/libs/protobuf"
git worktree add "${HOME_ROOT}/libs/protobuf" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/protobuf"

git config --global --add safe.directory "${MNT_ROOT}/libs/SDL"
cd "${MNT_ROOT}/libs/SDL"
git worktree add "${HOME_ROOT}/libs/SDL" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/SDL"

git config --global --add safe.directory "${MNT_ROOT}/libs/SDL_image"
cd "${MNT_ROOT}/libs/SDL_image"
git worktree add "${HOME_ROOT}/libs/SDL_image" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/SDL_image"

git config --global --add safe.directory "${MNT_ROOT}/libs/SDL_mixer"
cd "${MNT_ROOT}/libs/SDL_mixer"
git worktree add "${HOME_ROOT}/libs/SDL_mixer" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/SDL_mixer"

git config --global --add safe.directory "${MNT_ROOT}/libs/SDL_net"
cd "${MNT_ROOT}/libs/SDL_net"
git worktree add "${HOME_ROOT}/libs/SDL_net" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/SDL_net"

git config --global --add safe.directory "${MNT_ROOT}/libs/SDL_ttf"
cd "${MNT_ROOT}/libs/SDL_ttf"
git worktree add "${HOME_ROOT}/libs/SDL_ttf" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/SDL_ttf"

git config --global --add safe.directory "${MNT_ROOT}/libs/websocketpp"
cd "${MNT_ROOT}/libs/websocketpp"
git worktree add "${HOME_ROOT}/libs/websocketpp" wsl
git config --global --add safe.directory "${HOME_ROOT}/libs/websocketpp"
