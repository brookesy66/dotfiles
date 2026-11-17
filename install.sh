#!/usr/bin/env bash
# Symlink tracked dotfiles into $HOME for this machine's profile.
#
#   ./install.sh             auto-detect profile (wsl or arch)
#   ./install.sh wsl|arch    force a profile
#   DRY_RUN=1 ./install.sh   only print what would happen
#
# Shared files are linked to the same path under $HOME. Files under
# hosts/<profile>/ are linked with that prefix stripped (e.g.
# hosts/wsl/.zshrc.local -> ~/.zshrc.local). Desktop-only config (Hyprland,
# waybar, kitty, ...) is skipped on WSL.
# Existing real files are backed up to ~/dotfiles-backup-<date>/ first.
# Safe to re-run: already-correct symlinks are skipped.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-}"

if [ -n "${1:-}" ]; then
    PROFILE="$1"
elif grep -qi microsoft /proc/version 2>/dev/null; then
    PROFILE=wsl
else
    PROFILE=arch
fi
[ -d "$REPO/hosts/$PROFILE" ] || { echo "unknown profile: $PROFILE" >&2; exit 1; }
echo "profile: $PROFILE"

# GUI/desktop config that is pointless (or harmful) without a Linux desktop
desktop_only() {
    case "$1" in
        .config/hypr/*|.config/waybar/*|.config/i3/*|.config/i3blocks/*|\
        .config/i3status/*|.config/kitty/*|.config/dunst/*|.config/picom.conf|\
        .config/fontconfig/*|.Xresources) return 0 ;;
    esac
    return 1
}

run() { if [ -n "$DRY_RUN" ]; then echo "  would: $*"; else "$@"; fi; }

link() {
    local src="$REPO/$1" dst="$HOME/$2"

    # already correctly linked
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$src" ]; then
        return
    fi

    run mkdir -p "$(dirname "$dst")"

    # back up anything real that's in the way
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        run mkdir -p "$BACKUP/$(dirname "$2")"
        run mv "$dst" "$BACKUP/$2"
        echo "backed up: $2"
    fi

    run ln -s "$src" "$dst"
    echo "linked: $2"
}

git -C "$REPO" ls-files | while IFS= read -r f; do
    case "$f" in
        install.sh|README*|.gitignore) continue ;;
        hosts/"$PROFILE"/*) link "$f" "${f#hosts/"$PROFILE"/}" ;;
        hosts/*) continue ;;
        *)
            if [ "$PROFILE" = wsl ] && desktop_only "$f"; then continue; fi
            link "$f" "$f"
            ;;
    esac
done

[ -d "$BACKUP" ] && echo "Backups in: $BACKUP" || true
echo "Done."
