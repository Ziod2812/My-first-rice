# Astra

A Hyprland desktop for Arch-based distros, built on Hyprland's Lua configuration and a custom Quickshell shell.

## Features

- Hyprland configuration written in Lua and split into small modules: variables, animations, settings, environment, monitors, workspaces, window rules, keybinds and autostart
- Custom Quickshell shell (`astra`) with a top bar, an application launcher, notifications, clipboard history, a wallpaper picker and a power menu
- Bar widgets: clock, workspace dots, system stats, network, volume, battery and system tray
- Wallpaper handling with `awww` and dynamic colors with `wallust`
- Quickshell theme generated from a `matugen` template
- Ready-made configs for kitty, alacritty, starship, fastfetch and btop
- Idle handling with `hypridle` and screen locking with `hyprlock`
- One-step installer for Arch Linux, CachyOS and other Arch-based distros

## Requirements

- An Arch-based distribution with `pacman` and `sudo`
- Hyprland 0.55 or newer, which is the first release that loads `hyprland.lua`
- A regular user account (the installer refuses to run as root)

## Installation

```
git clone https://github.com/<your-username>/Astra.git
cd Astra
./install.sh
```

The installer updates the system, installs the packages listed in `packages/arch.txt` and `packages/aur.txt`, copies the configs into your home directory and enables the Bluetooth and PipeWire services.

Options:

| Option | Description |
| --- | --- |
| `-y`, `--yes` | Do not prompt; pacman and paru run with `--noconfirm` |
| `--no-upgrade` | Skip `pacman -Syu` |
| `--skip-packages` | Only copy the configs |
| `--skip-configs` | Only install the packages |
| `-h`, `--help` | Show the help text |

Every file that would be overwritten is first backed up to `~/.local/share/astra/backups/<timestamp>/`. Packages that exist only in the AUR are installed with `paru` or `yay`; if neither is found, the installer offers to install `paru`.

## After installing

1. Log out and back in to Hyprland so it loads `hyprland.lua`.
2. Put images in `~/Pictures/Wallpapers` and pick one from the bar.
3. To use starship with fish, add this line to `~/.config/fish/config.fish`:

```
starship init fish | source
```

The screen locks after 5 minutes of inactivity and turns off after 5.5 minutes. The timeouts are set in `~/.config/hypr/hypridle.conf`.

## Keybindings

`Super` is the main modifier.

| Keys | Action |
| --- | --- |
| `Super` (tap) | Toggle the launcher |
| `Super + T` | Open kitty |
| `Super + E` | Open Thunar |
| `Super + Q` | Close the active window |
| `Super + F` | Toggle fullscreen |
| `Super + Alt + Space` | Toggle floating |
| `Super + P` | Toggle pseudo-tiling |
| `Super + Shift + X` | Lock the screen |
| `Super + Shift + Q` | Exit Hyprland |
| `Super + H / J / K / L` | Focus left / down / up / right |
| `Super + Shift + H / J / K / L` | Move the window left / down / up / right |
| `Super + 1 ... 0` | Go to workspace 1 to 10 |
| `Super + Alt + 1 ... 0` | Move the window to workspace 1 to 10 |
| `Ctrl + Super + 1 ... 0` | Go to workspace 11 to 20 |
| `Ctrl + Super + Alt + 1 ... 0` | Move the window to workspace 11 to 20 |
| `Super + Scroll`, `Super + Page Up / Page Down`, `Ctrl + Super + Left / Right` | Previous / next workspace |
| `Super + Alt + Scroll`, `Ctrl + Super + Shift + Left / Right` | Move the window to the previous / next workspace |
| `Super + S` | Toggle the `magic` scratchpad |
| `Super + Alt + S` | Move the window to the scratchpad |
| `Print` | Copy a screenshot of the whole screen |
| `Super + Shift + S` | Copy a screenshot of a selected region |
| `Super + Left mouse drag` | Move the window |
| `Super + Right mouse drag` | Resize the window |
| Volume, mute, media and brightness keys | Adjust volume, control playback and change brightness |

## Project layout

```
Astra/
├── .config/
│   ├── alacritty/
│   ├── btop/
│   ├── fastfetch/
│   ├── hypr/
│   ├── kitty/
│   ├── quickshell/astra/
│   │   ├── bar/
│   │   │   └── components/
│   │   ├── services/
│   │   ├── Launcher.qml
│   │   ├── Theme.qml
│   │   └── shell.qml
│   └── starship.toml
├── matugen/
│   ├── config.toml
│   └── templates/Theme.qml
├── packages/
│   ├── arch.txt
│   └── aur.txt
└── install.sh
```

## Customization

Paths below are relative to `~/.config/`.

- `hypr/variables.lua`: gaps, borders, rounding, opacity, shadow and blur
- `hypr/settings.lua`: keyboard layout, touchpad and layout options
- `hypr/monitors.lua`: monitor mode, position and scale
- `hypr/user-keybinds.lua`: your keybinds
- `hypr/windowrules.lua`: floating and pinned window rules
- `hypr/autostart.lua`: programs started with Hyprland
- `quickshell/astra/Theme.qml`: shell colors, generated from `matugen/templates/Theme.qml`

The installer places the matugen config in `~/.config/astra/matugen/` and points its output at `~/.config/quickshell/astra/Theme.qml`.

## Restoring your old configs

Copy the files from `~/.local/share/astra/backups/<timestamp>/` back into your home directory.

## Acknowledgements

Astra is inspired by [Caelestia](https://github.com/caelestia-dots/shell) and [illogical-impulse](https://github.com/end-4/dots-hyprland), and is built on [Hyprland](https://github.com/hyprwm/Hyprland), [Quickshell](https://github.com/quickshell-mirror/quickshell) and [matugen](https://github.com/InioX/matugen).

## License

Released under the [MIT License](LICENSE).
