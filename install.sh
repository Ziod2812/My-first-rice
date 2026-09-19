#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PKG_DIR="$SCRIPT_DIR/packages"
CONFIG_SRC=""

YES=0
DO_UPGRADE=1
DO_PACKAGES=1
DO_CONFIGS=1

DEFAULT_ARCH_PKGS=(
  hyprland hyprlock hypridle xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  'quickshell|quickshell-git' qt6-wayland qt6-svg qt6-imageformats
  alacritty kitty fish starship fastfetch btop thunar
  cliphist wl-clipboard grim slurp playerctl brightnessctl libnotify xdg-utils
  pipewire pipewire-pulse wireplumber pavucontrol
  networkmanager network-manager-applet bluez bluez-utils blueman
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji
  'awww|awww-git' 'wallust|wallust-git' 'matugen|matugen-bin'
)
DEFAULT_AUR_PKGS=()

if [[ -t 1 ]]; then
  C_B=$'\e[1m'; C_R=$'\e[31m'; C_G=$'\e[32m'; C_Y=$'\e[33m'; C_C=$'\e[36m'; C_0=$'\e[0m'
else
  C_B=''; C_R=''; C_G=''; C_Y=''; C_C=''; C_0=''
fi
step() { printf '\n%s==> %s%s\n' "$C_B$C_C" "$*" "$C_0"; }
info() { printf '    %s\n' "$*"; }
ok()   { printf '  %s✔%s %s\n' "$C_G" "$C_0" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_Y" "$C_0" "$*" >&2; }
die()  { printf '%s✘ %s%s\n' "$C_R" "$*" "$C_0" >&2; exit 1; }

usage() {
  cat <<'USAGE'
Astra installer (Hyprland Lua config + Quickshell)
Supports Arch Linux, CachyOS and other Arch-based distros.

Usage: ./install.sh [options]

  -y, --yes          do not prompt (pacman/paru run with --noconfirm)
      --no-upgrade   skip 'pacman -Syu'
      --skip-packages  only copy configs, do not install packages
      --skip-configs   only install packages, do not copy configs
  -h, --help         show this help

Place this file at the root of the repository, next to .config/ (or config/),
matugen/ and packages/. Overwritten configs are backed up to
~/.local/share/astra/backups/<timestamp>/.
USAGE
}

confirm() {
  if [[ $YES -eq 1 || ! -t 0 ]]; then return 0; fi
  local ans
  read -r -p "  $1 [Y/n] " ans || return 0
  [[ -z $ans || $ans =~ ^[Yy] ]]
}

STAGE=""
SUDO_KEEPALIVE_PID=""
cleanup() {
  [[ -n $STAGE ]] && rm -rf "$STAGE"
  [[ -n $SUDO_KEEPALIVE_PID ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
}
trap cleanup EXIT
trap 'printf "%s✘ Script aborted by an error on line %s%s\n" "$C_R" "$LINENO" "$C_0" >&2' ERR

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -y|--yes)          YES=1 ;;
      --no-upgrade)      DO_UPGRADE=0 ;;
      --skip-packages)   DO_PACKAGES=0 ;;
      --skip-configs)    DO_CONFIGS=0 ;;
      -h|--help)         usage; exit 0 ;;
      *) die "Unknown option: $1 (use --help for usage)" ;;
    esac
    shift
  done
}

preflight() {
  step "Checking environment"
  [[ $EUID -ne 0 ]] || die "Do not run as root. Run as a regular user; sudo is called when needed."
  [[ -n ${HOME:-} && -d $HOME ]] || die "HOME is not set or is not a directory."
  local d
  for d in .config config; do
    if [[ -d $SCRIPT_DIR/$d ]]; then CONFIG_SRC="$SCRIPT_DIR/$d"; break; fi
  done
  [[ -n $CONFIG_SRC ]] || die "Cannot find a .config (or config) directory next to install.sh. Place install.sh at the root of the repository."

  if [[ $DO_PACKAGES -eq 1 ]]; then
    command -v pacman >/dev/null 2>&1 || die "pacman not found. This script supports Arch/CachyOS only (use --skip-packages to only copy configs)."
    command -v sudo   >/dev/null 2>&1 || die "sudo is required to install packages."
    sudo -v || die "Could not obtain sudo privileges."
    ( while true; do sudo -n true 2>/dev/null; sleep 50; kill -0 "$$" 2>/dev/null || exit 0; done ) &
    SUDO_KEEPALIVE_PID=$!
  fi
  ok "OK (user: ${USER:-$(id -un)}, source: $SCRIPT_DIR)"
}

read_list() {
  local file="$1"
  [[ -f $file ]] || return 0
  sed -e 's/#.*$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e '/^$/d' "$file"
}

pkg_satisfied() { pacman -T "$1" >/dev/null 2>&1; }
in_repo()       { pacman -Si "$1" >/dev/null 2>&1; }

AUR_HELPER=""
detect_aur_helper() {
  local h
  for h in paru yay; do
    if command -v "$h" >/dev/null 2>&1; then AUR_HELPER="$h"; return 0; fi
  done
  return 1
}

ensure_aur_helper() {
  if detect_aur_helper; then return 0; fi
  warn "No AUR helper (paru/yay) found, but it is needed for: ${AUR_SPECS[*]}"
  confirm "Install paru now?" || return 1

  if in_repo paru; then
    sudo pacman -S --needed "${PAC_YES[@]}" paru
  else
    sudo pacman -S --needed "${PAC_YES[@]}" base-devel git
    local tmp; tmp="$(mktemp -d)"
    git clone --depth 1 https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
    ( cd "$tmp/paru-bin" && makepkg -si --needed "${PAC_YES[@]}" )
    rm -rf "$tmp"
  fi
  detect_aur_helper
}

FAILED_PKGS=()
REPO_BATCH=()
AUR_SPECS=()
PAC_YES=()

classify() {
  local spec="$1" force_aur="$2" c picked=""
  local -a cands
  IFS='|' read -ra cands <<<"$spec"

  for c in "${cands[@]}"; do
    if pkg_satisfied "$c"; then return 0; fi
  done

  if [[ $force_aur -eq 0 ]]; then
    for c in "${cands[@]}"; do
      if in_repo "$c"; then picked="$c"; break; fi
    done
  fi

  if [[ -n $picked ]]; then REPO_BATCH+=("$picked"); else AUR_SPECS+=("$spec"); fi
}

install_packages() {
  step "Installing packages"
  if [[ $YES -eq 1 ]]; then PAC_YES=(--noconfirm); fi

  local -a arch_pkgs aur_pkgs
  mapfile -t arch_pkgs < <(read_list "$PKG_DIR/arch.txt")
  mapfile -t aur_pkgs  < <(read_list "$PKG_DIR/aur.txt")
  if [[ ${#arch_pkgs[@]} -eq 0 ]]; then
    info "packages/arch.txt is empty or missing, using the built-in package list"
    arch_pkgs=("${DEFAULT_ARCH_PKGS[@]}")
    if [[ ${#aur_pkgs[@]} -eq 0 ]]; then aur_pkgs=("${DEFAULT_AUR_PKGS[@]}"); fi
  fi

  if [[ $DO_UPGRADE -eq 1 ]]; then
    info "Syncing databases and upgrading the system (pacman -Syu)..."
    sudo pacman -Syu "${PAC_YES[@]}"
  else
    warn "Skipping -Syu: with stale databases, installs may fail with 404 errors or cause a partial upgrade."
  fi

  local spec
  for spec in "${arch_pkgs[@]}"; do classify "$spec" 0; done
  for spec in "${aur_pkgs[@]}";  do classify "$spec" 1; done

  if [[ ${#REPO_BATCH[@]} -gt 0 ]]; then
    info "From repos (${#REPO_BATCH[@]}): ${REPO_BATCH[*]}"
    if ! sudo pacman -S --needed "${PAC_YES[@]}" "${REPO_BATCH[@]}"; then
      warn "Batch install failed, retrying one package at a time..."
      local p
      for p in "${REPO_BATCH[@]}"; do
        sudo pacman -S --needed "${PAC_YES[@]}" "$p" || FAILED_PKGS+=("$p")
      done
    fi
  else
    ok "Repo packages: all installed"
  fi

  if [[ ${#AUR_SPECS[@]} -gt 0 ]]; then
    info "From AUR (${#AUR_SPECS[@]}): ${AUR_SPECS[*]}"
    if ensure_aur_helper; then
      local cands c done_flag
      for spec in "${AUR_SPECS[@]}"; do
        IFS='|' read -ra cands <<<"$spec"
        done_flag=0
        for c in "${cands[@]}"; do
          if "$AUR_HELPER" -S --needed "${PAC_YES[@]}" "$c"; then done_flag=1; break; fi
        done
        if [[ $done_flag -eq 0 ]]; then FAILED_PKGS+=("$spec"); fi
      done
    else
      FAILED_PKGS+=("${AUR_SPECS[@]}")
    fi
  else
    ok "AUR packages: all installed"
  fi

  check_hyprland_version
}

check_hyprland_version() {
  local v
  v="$(pacman -Q hyprland 2>/dev/null | awk '{print $2}' | sed -E 's/^[0-9]+://; s/-[0-9]+$//' || true)"
  [[ -n $v ]] || return 0
  if [[ "$(printf '%s\n%s\n' 0.55.0 "$v" | sort -V | head -n1)" != "0.55.0" ]]; then
    warn "Hyprland $v is older than 0.55: the Lua config (hyprland.lua) will NOT load. Please update Hyprland."
  else
    ok "Hyprland $v supports the Lua config"
  fi
}

BACKUP_ROOT="$HOME/.local/share/astra/backups/$(date +%Y%m%d-%H%M%S)"
N_INSTALLED=0
N_UNCHANGED=0
N_BACKED_UP=0

backup_file() {
  local dst="$1" rel="${1#"$HOME"/}"
  mkdir -p "$BACKUP_ROOT/$(dirname "$rel")"
  cp -a "$dst" "$BACKUP_ROOT/$rel"
  N_BACKED_UP=$((N_BACKED_UP + 1))
}

install_tree() {
  local src_root="$1" dst_root="$2" src rel dst
  while IFS= read -r -d '' src; do
    rel="${src#"$src_root"/}"
    dst="$dst_root/$rel"
    mkdir -p "$(dirname "$dst")"
    if [[ -e $dst || -L $dst ]]; then
      if [[ -f $dst && ! -L $dst ]] && cmp -s "$src" "$dst"; then
        N_UNCHANGED=$((N_UNCHANGED + 1))
        continue
      fi
      backup_file "$dst"
      rm -f "$dst"
    fi
    cp -p "$src" "$dst"
    N_INSTALLED=$((N_INSTALLED + 1))
  done < <(find "$src_root" -type f -print0)
}

sed_escape() { printf '%s' "$1" | sed 's/[&|\\]/\\&/g'; }

apply_fixups() {
  local home_esc; home_esc="$(sed_escape "$HOME")"

  local ff="$STAGE/config/fastfetch/config.jsonc"
  if [[ -f $ff ]]; then
    sed -i -E "s|(\"source\"[[:space:]]*:[[:space:]]*\")[^\"]*/\.config/fastfetch/logo\.txt\"|\1${home_esc}/.config/fastfetch/logo.txt\"|" "$ff"
  fi

  local mg="$STAGE/matugen/config.toml"
  if [[ -f $mg ]]; then
    sed -i -E "s|^(output_path[[:space:]]*=[[:space:]]*\")[^\"]*(Theme\.qml\")|\1${home_esc}/.config/quickshell/astra/\2|" "$mg"
  fi
}

install_configs() {
  step "Copying configs to \$HOME"
  STAGE="$(mktemp -d)"
  cp -a "$CONFIG_SRC" "$STAGE/config"
  if [[ -d $SCRIPT_DIR/matugen ]]; then cp -a "$SCRIPT_DIR/matugen" "$STAGE/matugen"; fi
  apply_fixups

  install_tree "$STAGE/config" "$HOME/.config"
  if [[ -d $STAGE/matugen ]]; then
    install_tree "$STAGE/matugen" "$HOME/.config/astra/matugen"
  fi

  mkdir -p "$HOME/Pictures/Wallpapers"

  ok "Copied: $N_INSTALLED files | unchanged: $N_UNCHANGED | old files backed up: $N_BACKED_UP"
  if [[ $N_BACKED_UP -gt 0 ]]; then info "Backup location: $BACKUP_ROOT"; fi
  info "Wallpaper directory: ~/Pictures/Wallpapers (put images here for Quickshell to find them)"
}

setup_services() {
  step "System services"

  if systemctl cat bluetooth.service >/dev/null 2>&1; then
    if sudo systemctl enable --now bluetooth.service >/dev/null 2>&1; then
      ok "bluetooth.service enabled"
    else
      warn "Could not enable bluetooth.service (sudo systemctl enable --now bluetooth)"
    fi
  fi

  if systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service >/dev/null 2>&1; then
    ok "PipeWire / WirePlumber (user) enabled"
  else
    warn "Could not enable the PipeWire user services (they usually start on their own when you log in to Hyprland)."
  fi

  if ! systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
    warn "NetworkManager is not running, the bar's Wi-Fi widget needs it: sudo systemctl enable --now NetworkManager"
  fi
}

summary() {
  step "Done"
  if [[ ${#FAILED_PKGS[@]} -gt 0 ]]; then
    warn "Packages that could not be installed: ${FAILED_PKGS[*]}"
    info "Install them manually and re-run ./install.sh --skip-configs, or remove them from packages/*.txt."
  fi
  cat <<'NEXT'

    Next steps:
      1. Log out and back in to Hyprland (a restart is needed for it to pick up hyprland.lua).
      2. Put images in ~/Pictures/Wallpapers, then pick a wallpaper from the bar.
      3. To use starship with fish, add this to ~/.config/fish/config.fish:
             starship init fish | source
      4. The "Lock" button and the idle timeout use hypridle (~/.config/hypr/hypridle.conf):
         the screen locks after 5 minutes and turns off after 5.5 minutes.

NEXT
}

main() {
  parse_args "$@"
  preflight
  if [[ $DO_PACKAGES -eq 1 ]]; then install_packages; fi
  if [[ $DO_CONFIGS  -eq 1 ]]; then install_configs;  fi
  if [[ $DO_PACKAGES -eq 1 ]]; then setup_services;   fi
  summary
}

main "$@"
