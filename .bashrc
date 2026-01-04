# ...

# Set the sleep time between wallpaper changes (in seconds)
wallpaper-sleep() {
  printf "SLEEP_SECONDS=%s\n" "$1" > ~/.config/random-wallpaper.conf
}

# ..
