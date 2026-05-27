#!/bin/bash
#
# audit-serveur.sh - génère un rapport d'audit d'un dossier serveur
# Usage : ./audit-serveur.sh [-o fichier] [-v] [-h] <dossier>
# Auteur : Sanata DAO
# Date : 2026-05-27

set -euo pipefail
IFS=$'\n\t'

# ========== CONFIGURATION ==========
SCRIPT_NAME=$(basename "$0")
readonly SCRIPT_NAME

# ========== VARIABLES OPTIONS ==========
output_file=""
verbose=0

# ========== USAGE ==========
usage() {
  cat <<USAGE
Usage: $SCRIPT_NAME [-o fichier] [-v] [-h] <dossier>

Options :
  -o FICHIER   Sauvegarde le rapport dans FICHIER (en plus de l'écran)
  -v           Mode verbose (affiche aussi la liste des fichiers vides et des TODOs)
  -h           Affiche l'aide
USAGE
  exit 0
}

# ========== LECTURE DES OPTIONS ==========
while getopts "o:vh" opt; do
  case "$opt" in
    o) output_file="$OPTARG" ;;
    v) verbose=1 ;;
    h) usage ;;
    *) echo "Option inconnue. Utilisez -h pour l'aide." >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# ========== VALIDATION DES ARGUMENTS ==========
if [ "$#" -lt 1 ]; then
  echo "Usage : $SCRIPT_NAME [-o fichier] [-v] [-h] <dossier>" >&2
  exit 1
fi

dossier="$1"

if [ ! -d "$dossier" ]; then
  echo "Erreur : '$dossier' n'existe pas ou n'est pas un dossier." >&2
  exit 1
fi

# ========== FONCTIONS ==========

afficher_statistiques() {
  local nb_fichiers nb_dossiers taille nb_vides
  nb_fichiers=$(find "$dossier" -type f | wc -l)
  nb_dossiers=$(find "$dossier" -type d | wc -l)
  taille=$(du -sh "$dossier" | cut -f1)
  nb_vides=$(find "$dossier" -type f -empty | wc -l)

  echo ""
  echo "📁 Dossier analysé  : $dossier"
  echo "📊 STATISTIQUES"
  echo "  Nombre de fichiers  : $nb_fichiers"
  echo "  Nombre de dossiers  : $nb_dossiers"
  echo "  Taille totale       : $taille"
  echo "  Fichiers vides      : $nb_vides"
}


afficher_fichiers_sensibles() {
  local mots_cles="DB_HOST|API_KEY|PASSWORD|SECRET|TOKEN"
  echo ""
  echo "🔒 FICHIERS SENSIBLES DÉTECTÉS"

  while IFS= read -r fichier; do
    local mot_trouve
    mot_trouve=$(grep -oE "$mots_cles" "$fichier" | head -1)
    echo "  $fichier  (contient : $mot_trouve)"
  done < <(grep -rlE "$mots_cles" "$dossier")
}

afficher_section_verbose() {
  echo ""
  echo "📋 FICHIERS VIDES DÉTAILLÉS"
  find "$dossier" -type f -empty | while IFS= read -r f; do
    echo "  $f"
  done

  echo ""
  echo "📝 TODOs TROUVÉS"
  local nb_todos
  nb_todos=$(grep -r "TODO" "$dossier" 2>/dev/null | wc -l)
  if [ "$nb_todos" -gt 0 ]; then
    grep -rn "TODO" "$dossier" 2>/dev/null | while IFS= read -r ligne; do
      echo "  $ligne"
    done
  else
    echo "  (aucun TODO trouvé)"
  fi
}

# ========== FONCTION PRINCIPALE DU RAPPORT ==========
generer_rapport() {
  local date_heure
  date_heure=$(date '+%Y-%m-%d %H:%M:%S')

  echo "========================================="
  echo "   AUDIT SERVEUR - $date_heure"
  echo "========================================="

  afficher_statistiques
  afficher_fichiers_sensibles

  if [ "$verbose" -eq 1 ]; then
    afficher_section_verbose
  fi

  echo ""
  echo "========================================="
  echo "   FIN DU RAPPORT"
  echo "========================================="
}

# ========== MAIN ==========
if [ -n "$output_file" ]; then
  generer_rapport | tee "$output_file"
else
  generer_rapport
fi
