# Astra

A clean, themeable Hyprland desktop powered by a custom Quickshell shell.

![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
![Hyprland 0.55+](https://img.shields.io/badge/Hyprland-0.55%2B-58e1ff)
![Arch based](https://img.shields.io/badge/Arch-based-1793d1?logo=archlinux&logoColor=white)

This repository contains the Astra dotfiles: a Hyprland configuration written in Lua, a Quickshell shell with a top bar, launcher and popups, and ready-made configs for the everyday terminal tools. One script installs everything.

## Contents

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [After installing](#after-installing)
- [Keybindings](#keybindings)
- [Project layout](#project-layout)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Restoring your old configs](#restoring-your-old-configs)
- [Acknowledgements](#acknowledgements)
- [License](#license)

## Features

**Desktop**

- Hyprland configuration in Lua, split into small modules: variables, animations, settings, environment, monitors, workspaces, window rules, keybinds and autostart
- Rounded windows, blur, shadows and smooth animations
- 20 workspaces plus a `magic` scratchpad
- Idle locking with `hypridle` and `hyprlock`

**Quickshell shell (`astra`)**

- Top bar with a clock, workspace dots, system stats, network, volume, battery and system tray
- Application launcher opened by tapping `Super`
- Notification popups
- Clipboard history powered by `cliphist`
- Wallpaper picker powered by `awww`
- Power menu

**Theming**

- Dynamic colors from the current wallpaper with `wallust`
- Shell colors generated from a `matugen` template
- A custom btop theme, `astra-galaxy`

**Extras**

- Configs for kitty, alacritty, starship, fastfetch and btop
- Installer with package handling, automatic backups and service setup

## Requirements

- An Arch-based distribution with `pacman` and `sudo`
- Hyprland 0.55 or newer, the first release that loads `hyprland.lua`
- A regular user account; the installer refuses to run as root

## Installation

```
git clone https://github.com/Ziod2812/My-first-rice.git
cd My-first-rice
./install.sh
```

The installer updates the system, installs the packages listed in `packages/arch.txt` and `packages/aur.txt`, copies the configs into your home directory and enables the Bluetooth and PipeWire services. Packages that exist only in the AUR are installed with `paru` or `yay`; if neither is found, the installer offers to install `paru`.

| Option | Description |
| --- | --- |
| `-y`, `--yes` | Do not prompt; pacman and paru run with `--noconfirm` |
| `--no-upgrade` | Skip `pacman -Syu` |
| `--skip-packages` | Only copy the configs |
| `--skip-configs` | Only install the packages |
| `-h`, `--help` | Show the help text |

Every file that would be overwritten is first backed up to `~/.local/share/astra/backups/<timestamp>/`.

## After installing

1. Log out and back in to Hyprland so it loads `hyprland.lua`.
2. Put images in `~/Pictures/Wallpapers`, then pick one from the bar.
3. To use starship with fish, add this line to `~/.config/fish/config.fish`:

```
starship init fish | source
```

The screen locks after 5 minutes of inactivity and turns off after 5.5 minutes. Change the timeouts in `~/.config/hypr/hypridle.conf`.

## Keybindings

`Super` is the main modifier.

**Apps and session**

| Keys | Action |
| --- | --- |
| `Super` (tap) | Toggle the launcher |
| `Super + T` | Open kitty |
| `Super + E` | Open Thunar |
| `Super + Shift + X` | Lock the screen |
| `Super + Shift + Q` | Exit Hyprland |

**Windows**

| Keys | Action |
| --- | --- |
| `Super + Q` | Close the active window |
| `Super + F` | Toggle fullscreen |
| `Super + Alt + Space` | Toggle floating |
| `Super + P` | Toggle pseudo-tiling |
| `Super + H / J / K / L` | Focus left / down / up / right |
| `Super + Shift + H / J / K / L` | Move the window left / down / up / right |
| `Super + Left mouse drag` | Move the window |
| `Super + Right mouse drag` | Resize the window |

**Workspaces**

| Keys | Action |
| --- | --- |
| `Super + 1 ... 0` | Go to workspace 1 to 10 |
| `Super + Alt + 1 ... 0` | Move the window to workspace 1 to 10 |
| `Ctrl + Super + 1 ... 0` | Go to workspace 11 to 20 |
| `Ctrl + Super + Alt + 1 ... 0` | Move the window to workspace 11 to 20 |
| `Super + Scroll`, `Super + Page Up / Page Down`, `Ctrl + Super + Left / Right` | Previous / next workspace |
| `Super + Alt + Scroll`, `Ctrl + Super + Shift + Left / Right` | Move the window to the previous / next workspace |
| `Super + S` | Toggle the `magic` scratchpad |
| `Super + Alt + S` | Move the window to the scratchpad |

**Screenshots and media**

| Keys | Action |
| --- | --- |
| `Print` | Copy a screenshot of the whole screen |
| `Super + Shift + S` | Copy a screenshot of a selected region |
| Volume and mute keys | Change the volume or mute the output |
| Play, previous and next keys | Control media playback |
| Brightness keys | Change the screen brightness |

## Project layout

```
My-first-rice/
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
├── install.sh
├── LICENSE
└── README.md
```

## Customization

Paths are relative to `~/.config/`.

| File | What it controls |
| --- | --- |
| `hypr/variables.lua` | Gaps, borders, rounding, opacity, shadow and blur |
| `hypr/settings.lua` | Keyboard layout, touchpad and layout options |
| `hypr/monitors.lua` | Monitor mode, position and scale |
| `hypr/user-keybinds.lua` | Keybindings |
| `hypr/windowrules.lua` | Floating and pinned window rules |
| `hypr/autostart.lua` | Programs started with Hyprland |
| `quickshell/astra/Theme.qml` | Shell colors, generated from `matugen/templates/Theme.qml` |

The installer places the matugen config in `~/.config/astra/matugen/` and points its output at `~/.config/quickshell/astra/Theme.qml`.

## Troubleshooting

**Hyprland ignores the configuration.** Check your version with `pacman -Q hyprland`. Versions older than 0.55 do not load `hyprland.lua`.

**The wallpaper picker is empty or the wallpaper does not change.** Make sure the images are in `~/Pictures/Wallpapers` and that `awww` is installed.

**Colors do not change after picking a wallpaper.** The shell only runs `wallust` when it is installed. Install it and pick the wallpaper again.

**The network widget does not work.** It needs NetworkManager to be running:

```
sudo systemctl enable --now NetworkManager
```

**Screenshot keys do nothing.** They need `grim` and `slurp`, which the installer adds.

**Some packages failed to install.** The installer lists them at the end. Install them manually, then run `./install.sh --skip-configs`.

## Restoring your old configs

Copy the files from `~/.local/share/astra/backups/<timestamp>/` back into your home directory.

## Acknowledgements

Astra is inspired by [Caelestia](https://github.com/caelestia-dots/shell) and [illogical-impulse](https://github.com/end-4/dots-hyprland), and is built on [Hyprland](https://github.com/hyprwm/Hyprland), [Quickshell](https://github.com/quickshell-mirror/quickshell) and [matugen](https://github.com/InioX/matugen).

## License

Released under the [MIT License](LICENSE).
