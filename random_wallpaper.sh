#!/usr/bin/env bash

# Exit immediately on:
# - any command failure (-e)
# - use of unset variables (-u)
# - failure in any part of a pipeline (-o pipefail)
# This prevents silent bad states in a long-running daemon.
set -euo pipefail

# ============================================================================
# CONFIGURATION: Set your wallpaper directory path here
# ============================================================================
# Replace the path below with the actual path to your wallpapers directory.
# This directory can contain image files directly or subdirectories with images.
# Example: BASE_DIR="$HOME/Pictures/Wallpapers/"
BASE_DIR="$HOME/path/to/wallpapers-directory/"

# Persistent on-disk cache (avoids rescanning the filesystem every loop)
CACHE_DIR="$HOME/.cache/random-wallpaper"
IMAGE_LIST="$CACHE_DIR/images.txt"

# Runtime configuration file (editable while the service is running)
# Used instead of environment variables, which are immutable at runtime
CONFIG_FILE="$HOME/.config/random-wallpaper.conf"

# Safe defaults to avoid aggressive GNOME behavior
DEFAULT_SLEEP=180          # seconds between wallpaper changes
DEFAULT_REFRESH=300       # seconds between filesystem rescans

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Rebuilds the image list on disk.
# Uses a temp file + atomic move to avoid partial reads while updating.
refresh_image_list() {
  find "$BASE_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    > "$IMAGE_LIST.tmp"
  mv "$IMAGE_LIST.tmp" "$IMAGE_LIST"
}

# Tracks the last time the filesystem was scanned
# Kept in memory to avoid touching disk unnecessarily
LAST_REFRESH=0

while true; do
  # Current wall-clock time (seconds since epoch)
  NOW=$(date +%s)

  # Load runtime configuration if present.
  # This allows live behavior changes without restarting the service.
  if [ -f "$CONFIG_FILE" ]; then
    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
  fi

  # Apply defaults if config values are missing or unset
  SLEEP_SECONDS="${SLEEP_SECONDS:-$DEFAULT_SLEEP}"
  REFRESH_SECONDS="${REFRESH_SECONDS:-$DEFAULT_REFRESH}"

  # Refresh the image cache only if:
  # - it doesn't exist yet, or
  # - enough time has passed since the last refresh
  #
  # This bounds CPU, memory, and IO usage while still
  # picking up newly added images automatically.
  if [ ! -f "$IMAGE_LIST" ] || (( NOW - LAST_REFRESH >= REFRESH_SECONDS )); then
    refresh_image_list
    LAST_REFRESH=$NOW
  fi

  # Select a random image from the cached list.
  # shuf operates on a file here, avoiding large in-memory buffers.
  IMAGE=$(shuf -n 1 "$IMAGE_LIST")

  # Defensive checks:
  # - ensure the path is non-empty
  # - ensure the file still exists (may have been deleted)
  if [ -n "$IMAGE" ] && [ -f "$IMAGE" ]; then
    # Update both light and dark wallpapers to keep them in sync
    gsettings set org.gnome.desktop.background picture-uri "file://$IMAGE"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMAGE"
  fi

  # Sleep before the next iteration.
  # This is the primary throttle controlling GNOME load.
  sleep "$SLEEP_SECONDS"
done
