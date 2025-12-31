#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
proto_generate.py - FINAL VERSION
- Supports MULTIPLE output directories per group
- Each group has its own cache file (defined in config)
- .pb.cc: generated once, copied to all output dirs
- .pb.h: generated once, copied to all output dirs

"""

import os
import sys
import json
import hashlib
import platform
import subprocess
from pathlib import Path

# ========================================
# CONFIG
# ========================================
CONFIG_FILE = "proto_configs.json"  # Main configuration file
TOOLS_DIR = Path("tools/protoc")    # Directory containing protoc binaries

# ========================================
# Get protoc executable path based on OS and architecture
# ========================================
def get_protoc_path():
    system = platform.system()
    machine = platform.machine().lower()  # Detect CPU architecture

    # Windows
    if system == "Windows":
        # Choose win64 for 64-bit, win32 for 32-bit
        if "64" in machine:
            protoc = TOOLS_DIR / "bin" / "win64" / "protoc.exe"
        else:
            protoc = TOOLS_DIR / "bin" / "win32" / "protoc.exe"

    # Linux
    elif system == "Linux":
        if "x86_64" in machine:
            protoc = TOOLS_DIR / "bin" / "linux-x86_64" / "protoc"
        elif "x86" in machine:  # 32-bit
            protoc = TOOLS_DIR / "bin" / "linux-x86_32" / "protoc"
        elif "aarch64" in machine or "arm64" in machine:
            protoc = TOOLS_DIR / "bin" / "linux-aarch_64" / "protoc"
        elif "ppc64" in machine:
            protoc = TOOLS_DIR / "bin" / "linux-ppcle_64" / "protoc"
        elif "s390x" in machine:
            protoc = TOOLS_DIR / "bin" / "linux-s390_64" / "protoc"
        else:
            raise RuntimeError(f"Unsupported Linux architecture: {machine}")

    # macOS (Darwin)
    elif system == "Darwin":
        if "x86_64" in machine:
            protoc = TOOLS_DIR / "bin" / "osx-x86_64" / "protoc"
        elif "arm64" in machine or "aarch64" in machine:
            protoc = TOOLS_DIR / "bin" / "osx-aarch_64" / "protoc"
        else:
            # Fallback to universal binary if available
            protoc = TOOLS_DIR / "bin" / "osx-universal_binary" / "protoc"

    else:
        raise RuntimeError(f"Unsupported OS: {system}")

    # Validate existence
    if not protoc.exists():
        raise FileNotFoundError(f"protoc not found: {protoc}")
    return protoc

# ========================================
# Compute MD5 hash of a file
# ========================================
def file_hash(filepath):
    with open(filepath, "rb") as f:
        return hashlib.md5(f.read()).hexdigest()

# ========================================
# Load main configuration file
# ========================================
def load_config():
    config_path = Path(CONFIG_FILE)
    if not config_path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")
    with open(config_path, "r", encoding="utf-8") as f:
        return json.load(f)

# ========================================
# Load cache for a specific group
# ========================================
def load_cache(cache_path):
    cache_file = Path(cache_path)
    if cache_file.exists():
        with open(cache_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}

# ========================================
# Save cache for a specific group
# ========================================
def save_cache(cache_path, cache_data):
    with open(cache_path, "w", encoding="utf-8") as f:
        json.dump(cache_data, f, indent=2, ensure_ascii=False)

# ========================================
# Create .gitignore in output directory
# ========================================
def create_gitignore(output_dir):
    gitignore_path = Path(output_dir) / ".gitignore"
    gitignore_content = "# Generated Protobuf files\n"
    gitignore_content += "*.pb.cc\n"
    gitignore_content += "*.pb.h\n"
    gitignore_content += "# .gitignore itself\n"
    gitignore_content += ".gitignore\n"

    if not gitignore_path.exists():
        with open(gitignore_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(gitignore_content)
        print(f"[CREATE] {gitignore_path}")
    else:
        print(f"[SKIP] .gitignore already exists: {gitignore_path}")

# ========================================
# Generate C++ files for one group
# ========================================
def generate_group(input_files, output_dirs, protoc_path, include_dirs):
    input_paths = [Path(p).resolve() for p in input_files]
    output_paths = [Path(p).resolve() for p in output_dirs]

    # Validate input files
    missing = [p for p in input_paths if not p.exists()]
    if missing:
        print(f"[SKIP] Missing input files: {missing}")
        return False

    # Ensure all output directories exist
    for out_dir in output_paths:
        out_dir.mkdir(parents=True, exist_ok=True)
        # Create .gitignore in each output directory
        create_gitignore(out_dir)

    # Use first output directory as working directory
    work_dir = output_paths[0]

    # Prepare protoc command
    proto_base = input_paths[0].parent
    proto_paths = [proto_base] + include_dirs

    cmd = [
        str(protoc_path),
        f"--cpp_out={work_dir}",
    ]
    for pp in proto_paths:
        cmd += [f"--proto_path={pp}"]
    cmd += [str(p) for p in input_paths]

    print(f"[RUN] {' '.join(cmd)}")

    # Execute protoc
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"[ERROR] protoc failed:\n{result.stderr}\n{result.stdout}")
        return False

    # Copy generated files (.pb.cc and .pb.h) to other output directories
    generated_files = list(work_dir.glob("*.pb.*"))
    for src_file in generated_files:
        for dest_dir in output_paths[1:]:
            dest_file = dest_dir / src_file.name
            if not dest_file.exists() or dest_file.read_bytes() != src_file.read_bytes():
                dest_file.write_bytes(src_file.read_bytes())
                print(f"[COPY] {src_file.name} → {dest_file}")

    print(f"[OK] Generated in: {', '.join(map(str, output_paths))}")
    return True

# ========================================
# Main entry point
# ========================================
def main():
    print("Starting Protobuf C++ code generation...")

    # Get protoc path
    try:
        protoc_path = get_protoc_path()
        print(f"[INFO] Using protoc: {protoc_path}")
    except Exception as e:
        print(f"[ERROR] {e}")
        return 1

    # Load configuration
    try:
        config = load_config()
    except Exception as e:
        print(f"[ERROR] {e}")
        return 1

    include_dirs = [TOOLS_DIR / "include"]

    # Process each group
    for idx, group in enumerate(config):
        input_files = group.get("input", [])
        output_dirs = group.get("output", [])
        cache_path = group.get("cache")

        if not input_files or not output_dirs or not cache_path:
            print(f"[SKIP] Group {idx}: missing input/output/cache")
            continue

        # Load group-specific cache
        cache = load_cache(cache_path)

        # Compute combined hash of all input files
        input_hashes = [file_hash(p) if Path(p).exists() else "missing" for p in input_files]
        combined_hash = "".join(input_hashes)

        old_hash = cache.get("hash")

        if old_hash == combined_hash:
            print(f"[CACHE] Group {idx}: no change")
        else:
            print(f"[GEN] Group {idx}: regenerating...")
            success = generate_group(input_files, output_dirs, protoc_path, include_dirs)
            if success:
                cache["hash"] = combined_hash
                save_cache(cache_path, cache)
                print(f"[CACHE] Updated {cache_path}")
            else:
                return 1

    print("Done!")
    return 0

if __name__ == "__main__":
    sys.exit(main())
