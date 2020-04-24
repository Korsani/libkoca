#!/usr/bin/env bash
# Fournit un mechanisme de lock: empeche plusieurs instances 
# de tourner en meme temps.
# Efface le lock s'il est vide, ou s'il ne correspond vraisemblablement pas au processus qui essait de le créer
# Utilisation:
# lockMe [ -q ] <fichier de lock> [ timeout ]
# -q : sort silencieusement si le timeout expire
# PS: le fichier ne devrait pas etre un `mktemp`, sinon ca risque pas de marcher cm prevu :)
function koca_lockMe { # Lock the calling script with the specified file. Usage: $0 <file>
	local src;src='__libkoca__' ; [ -e "$src" ] && eval "$(bash "$src" koca_cleanOnExit)"
	local bn
	if [ -z "$1" ]
	then
		echo "$src: lacking lock file"
		return 1
	else
		local lock="$1"
	fi
	if [ -s "$lock" ]
	then
		c="$(ps -o command= "$(<"$lock")")"
		if [ -z "$c" ]
		then
			[ "$quiet" -eq 0 ] && echo "[__libname__] Removing stall lock"
			rm -f "$lock"
		fi
	else
		if [ -e "$lock" ]
		then
			echo "[__libname__] Empty lock $lock. Removing"
			rm -f "$lock"
		fi
	fi
	if [ -e "$lock" ]
	then
		return 1
	else
		echo "$$" > "$lock"
		koca_cleanOnExit "$lock"
		return 0
	fi
}
function koca_unlockMe { # Remove the lock. Usage: $0 <file>
	rm -f "$1"
	! [ -a "$1" ]
}
# Retourne 1 si le script a été locké par le fonction ci-dessus
# Retourne 0 sinon
function koca_isLocked {	# Check wether lock exists
	local lock;lock="$1"
	[ -a "$lock" ] && return 0
	return 1
}
