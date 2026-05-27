# Évaluation Bash & Automatisation

Sanata DAO
2026-05-27

## Ce que j'ai réalisé

Dans ce TP d'évaluation, j'ai audité un dossier serveur fictif (`webstudio/`),
analysé un fichier de logs Apache avec des commandes `awk`, `grep` et `sort` et 
écrit un script Bash de qualité professionnelle (`audit-serveur.sh`).

## Usage du script

```bash
./audit-serveur.sh [-o fichier] [-v] [-h] <dossier>

# Exemple — rapport simple
./audit-serveur.sh webstudio

# Exemple — rapport sauvegardé dans un fichier
./audit-serveur.sh -o rapport.txt webstudio

# Exemple — mode verbose
./audit-serveur.sh -v webstudio
```

##Difficultés
Dans la partie 2, j'ai beaucoup testé avec beaucoup d'erreurs car il y avait beaucoup de pipe |

Dans la partie 3, j'ai mis beaucoup de temps à déterminer quelles fonctions il fallait
construire et dans la fonction afficher_fichier_sensibles notamment il a fallu déterminer 
quels sont les mots clés sensibles et comment rediriger le grep dans la boucle (white read)

Aussi le shellcheck renvoyait beaucoup d'erreurs de syntaxe
