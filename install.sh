# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    install.sh                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: tsignori <tsignori@student.42perpignan.fr  +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/12/05 11:52:27 by tsignori          #+#    #+#              #
#    Updated: 2025/12/05 11:52:34 by tsignori         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Dossier source dans le repo (à adapter si besoin)
NVIM_SRC="$SCRIPT_DIR/nvim"

# Destination standard Neovim
NVIM_DEST="$HOME/.config/nvim"

# -------- MENU FLECHES --------
choose_with_arrows() {
  local n __result=$1
  shift
  local options=("$@")
  local index=0
  local key

  while true; do
    clear
    echo "Voulez-vous sauvegarder votre ancienne config Neovim ?"
    echo

    for i in "${!options[@]}"; do
      if [[ $i -eq $index ]]; then
        printf " > %s\n" "${options[$i]}"
      else
        printf "   %s\n" "${options[$i]}"
      fi
    done

    read -rsn1 key

    if [[ $key == "" ]]; then
      __result="${options[$index]}"
      return 0
    fi

    if [[ $key == $'\x1b' ]]; then
      read -rsn2 key
      case "$key" in
        "[A") (( index > 0 )) && (( index-- )) ;;                  # haut
        "[B") (( index < ${#options[@]} - 1 )) && (( index++ )) ;;  # bas
      esac
    fi
  done
}

# -------- LINKER --------
link_with_backup() {
  local src="$1"
  local dest="$2"
  local do_backup="$3"   # "Oui" ou "Non"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [[ "$do_backup" == "Oui" ]]; then
      local backup="${dest}_bak"
      if [ -e "$backup" ] || [ -L "$backup" ]; then
        backup="${backup}_$(date +%Y%m%d-%H%M%S)"
      fi
      echo "Backup: $dest -> $backup"
      mv "$dest" "$backup"
    else
      echo "Suppression de l'ancienne config : $dest"
      rm -rf "$dest"
    fi
  fi

  ln -s "$src" "$dest"
  echo "Symlink créé : $dest → $src"
}

# -------- EXECUTION --------

if [ ! -d "$NVIM_SRC" ]; then
  echo "❌ Dossier source Neovim introuvable : $NVIM_SRC"
  exit 1
fi

mkdir -p "$HOME/.config"

options=("Oui" "Non")
backup_choice=""

choose_with_arrows backup_choice "${options[@]}"

echo
echo "→ Choix backup Neovim : $backup_choice"
echo

echo "[1/1] Installation config Neovim"
link_with_backup "$NVIM_SRC" "$NVIM_DEST" "$backup_choice"

echo
echo "✅ Neovim config installée."
