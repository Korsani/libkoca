#!/usr/bin/env bash
# Efface certains fichiers a la sortie du programme
# Utilisation:
# cleanOnExit <liste de fichiers>
# Bug : si 'cleanOnExit' est utilisé dans une fonction chargé dans l'environnement du shell courant, alors rien ne sera fait à la sortie de la fonctions, ni à la sortie du shell
# En d'autres termes, dans ce cas :
# $ cat plop
# f()
#	{
#	t=`mktemp`
#	cleanOnExit $t
# }
# $ . libkoca.sh
# $ . plop
# $ f
# Le fichier temporaire ne sera jamais effacé
function koca_cleanOnExit { # Remove specified file on script exit. Usage: $0 <file>
	local file
	for file in "$@"
	do
		local t;t="$(trap -p 0)"
		[ -n "$t" ] && _oldTrap0="$(echo "$t ;" | sed -e "s/trap -- '\(.*\)' EXIT/\1/")"
		trap "$(printf '%s rm -f "%s"' "$_oldTrap0" "$file")" 0
	done
}
