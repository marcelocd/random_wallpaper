# 🖼️ Random Wallpaper Changer

A systemd service for GNOME that automatically changes your desktop wallpaper at regular intervals.

## 📋 Prerequisites

You should already have a directory containing your wallpapers. This directory can contain:

- 📁 Image files directly
- 📂 Subdirectories with image files

> 💡 **Tip for car lovers:** Check out [HD Car Wallpapers](https://www.hdcarwallpapers.com/) for high-quality car wallpapers in various resolutions (HD, 4K, 5K, 8K).

## 🚀 Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/marcelocd/random_wallpaper.git
   cd random_wallpaper
   ```

2. **Configure the wallpaper directory path:**

   Open `random_wallpaper.sh` and edit the `BASE_DIR` variable near the top of the file to point to your wallpapers directory. For example:

   ```bash
   BASE_DIR="$HOME/Pictures/wallpapers/"
   ```

3. **Place the script in your bin directory:**

   ```bash
   cp random_wallpaper.sh ~/bin/random_wallpaper.sh
   chmod +x ~/bin/random_wallpaper.sh
   ```

4. **Place the systemd service file:**

   ```bash
   mkdir -p ~/.config/systemd/user
   cp random-wallpaper.service ~/.config/systemd/user/random-wallpaper.service
   ```

5. **Start the service:**

   ```bash
   systemctl --user daemon-reload
   systemctl --user enable random-wallpaper.service
   systemctl --user start random-wallpaper.service
   ```

6. **Verify the service is running:**

   ```bash
   systemctl --user status random-wallpaper.service
   ```

   After running `enable`, you should see a message like:

   ```
   Created symlink '/home/user/.config/systemd/user/default.target.wants/random-wallpaper.service' → '/home/user/.config/systemd/user/random-wallpaper.service'.
   ```

   When checking the status, you should see something like:

   ```
   ● random-wallpaper.service - Random Wallpaper Changer
        Loaded: loaded (/home/user/.config/systemd/user/random-wallpaper.service; enabled; preset: enabled)
        Active: active (running) since Sun 2026-01-04 13:36:34 -03; 4s ago
   ```

✅ Done. The background changer should be working by now.

## ⚙️ Configuration

### Default Sleep Time

The script has a default sleep time of 3 minutes (180 seconds) between wallpaper changes.

### Customizing Sleep Time

To easily change the sleep time from the terminal, add the following function to your `~/.bashrc` or `~/.zshrc`:

```bash
wallpaper-sleep() {
  printf "SLEEP_SECONDS=%s\n" "$1" > ~/.config/random-wallpaper.conf
}
```

Reload your shell configuration:

```bash
source ~/.bashrc

# or
# source ~/.zshrc
```

Alternatively, you can simply open a new terminal window.

After reloading your shell configuration, you can change the sleep time with:

```bash
wallpaper-sleep 15
```

To verify the change:

```bash
cat ~/.config/random-wallpaper.conf
```

You should see:

```
SLEEP_SECONDS=15
```

Starting from the next iteration, the background will now change every 15 seconds. 🎨
