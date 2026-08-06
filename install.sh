#!/usr/bin/env bash
# Symlink every tracked dotfile into $HOME.
# Existing real files are backed up to ~/dotfiles-backup-<date>/ first.
# Safe to re-run: already-correct symlinks are skipped.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

git -C "$REPO" ls-files | while IFS= read -r f; do
    case "$f" in
        install.sh|README*|.gitignore) continue ;;
    esac
    src="$REPO/$f"
    dst="$HOME/$f"

    # already correctly linked
    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$src" ]; then
        continue
    fi

    mkdir -p "$(dirname "$dst")"

    # back up anything real that's in the way
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        mkdir -p "$BACKUP/$(dirname "$f")"
        mv "$dst" "$BACKUP/$f"
        echo "backed up: $f"
    fi

    ln -s "$src" "$dst"
    echo "linked: $f"
done

[ -d "$BACKUP" ] && echo "Backups in: $BACKUP" || true
echo "Done."
