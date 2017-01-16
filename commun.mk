# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Fichier Makefile (hors du) commun
#
# (c) GPL Gab, from the Cashew Team
# 
# Implémente le make dist
# Mais pour ca, il faut que soient déclarés:
#  - PROJECT: Nom du projet.
#  - VERSIONFROM: Commande à lancer et qui renvoi la version sur une seule ligne.
#  - Que le fichier MANIFEST soit présent, mais un make manifest peut faire l'affaire.
#
#  * Installation:
#  make install
#  Ca l'installera dans /usr/local/include
#  
#  * Utilisation:
#  Dans le Makefile:
#  include commun.mk
#  ou mieux:
#  -include commun.mk
#  comme ca ca ralera pas si commun.mk n'existe pas
#
#  Puis:
#  make dist|dist-clean|xml|id|MANIFEST
#
#  * Aide:
#  make dist		: fait un beau targz
#  make dist-clean	: efface le .version et le xml
#  make xml|id		: crée le xml d'identification
#  make MANIFEST	: crée le fichier MANIFEST en faisant un ls grep grep
#  make binstall	: installation basique: FN est installé dans PREFIX/bin avec le mode FNMODE
#  make bclean		: basique clean (.swp, ~, ...)
#  make dclean		: dist clean (.version, xmlfile)
#  
#
# A FAIRE:
# 	'version' plus beau
# 	Pouvoir inclure du code html dans la description (fait?)
# 	Meilleur protection contre les espaces, dans le code xml
#  
#
# Version 0.6.4
# 
# Changelog:
# 03/05/2005: 0.1	: Création
# 03/05/2005: 0.2	: Implémente dist-clean, qui efface le targz et .version
# 09/05/2005: 0.3	: make xml ok! Merci Magic!
# 					: make-alors-que-VERSION-pas-définie plus cohérent
# 					: plus de doc
# 10/05/2005: 0.4	: make manifest
# 					: rale un peu si DESCRIPTION n'est pas définie
# 					: test si xmllint est présent
# 11/05/2005: 0.4.1 : ne met pas le tag 'repertoire' dans le xml
# 11/05/2005: 0.4.2 : distfile dépend de tt ce qu'il y a dans manifest
# 					: dist-clean ne dépend plus de l'existence de la variable VERSION
# 					: dist regarde si .version n'est pas vide. Si c'est le cas, fait un dist-clean
# 12/05/2005: 0.4.3	: ajout de la date
# 					: make bclean/base-clean
# 					: make dclean/dist-clean
# 					: make mrproper
# 18/05/2005: 0.4.4 : id.xml dépend de ce qu'il y a dans MANIFEST
# 08/06/2005: 0.4.5 : dist dépend de id
# 15/06/2005: 0.5	: Séparation entre le nom du projet et le nom du targz créé: nouvelle variable: DISTNAME
# 					: .version dépend de ce qu'il y a dans MANIFEST
# 					: n'écrase plus le targz s'il existe déjà
# 					: nouvelle variable: WIKI
# 					: j'ai essayé de faire le code plus beau mais c chiant: j'arrive pas à faire un .version propre
# 16/06/2005: 0.5.1	: Ajout de la variable CATEGORY
# 05/10/2005: 0.5.2	: iconv pour convertir en utf8
# 06/10/2005: 0.5.3 : Enleve un pattern lors du faisage du MANIFEST
# 					: make de Gentoo taquin: TMP=/tmp/$$$$ => TMP:=/tmp/$$$$
# 07/11/2005: 0.5.4 : Tar au lieu de cp pour make dist
# 					: Gére différentes extensions de fichiers de compression, et du coup on peut faire
# 					: ZIP:=gzip (ou TAR:=tar) dans un Makefile, puis inclure commun.mk, ca se débrouillera
# 					: make MANIFEST marche bien mieux
# 12/12/2005: 0.5.5 : Bug dans le make xml
# 26/01/2007: 0.5.6 : make bclean récursif (merci find(1)! )
# 03/11/2007: 0.5.7 : rajout de grep -v .svn
# 					: modification du find pour bclean
# 10/01/2008: 0.5.8 : $(DISTDIR) est un tmpfs si on est sous root
# 14/03/2008: 0.6.0 : make binstall :)
# 					: make buninstall
# 03/09/2008: 0.6.1	: + latest.tar.bz2|gz
# 16/09/2008: 0.6.2	: PREFIX devrait maintenant être sans bin/sbin à la fin
# 01/10/2008: 0.6.3	: Si MK_BYPASS est défini, ne check pas la présence de certaines variables
# 						Utile quand on ne veut que bclean
# 21/11/2008: 0.6.4 : VERSIONFROM n'est plus obligatoire, VERSION peut être présent.
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

XMLFILE=id.xml
XMLLINT=/usr/bin/xmllint
ICONV=/usr/bin/iconv
TMP:=/tmp/$(shell echo $$$$)
DATE:=$(shell date +%Y-%m-%d)
TAR?=tar
ZIP?=gzip

EXT_gzip:=gz
EXT_bzip2:=bz2

.PHONY : dist-clean xml dist id

#On commence par traiter les erreurs...
###############################################
ifndef MK_BYPASS
ifndef PROJECT
$(error "La variable PROJECT n'est pas définie. Elle doit contenir le nom du projet. C'est ce nom que portera l'archive.")
endif
export PROJECT

ifndef VERSIONFROM
ifndef VERSION
$(error "Ni VERSION ni VERSIONFROM ne sont définies. VERSION est le numéro de version, VERSIONFROM est une commande permettant de l'obtenir. L'un ou l'autre doivent être présent. Si les deux le sont, VERSION sera utilisé. Le numéro de version ne doit pas avoir de retour chariot à la fin.")
endif
endif
export VERSIONFROM

ifndef DESCRIPTION
$(warning "La variable DESCRIPTION n'est pas définie.")
$(warning "C'est pas bien grave, mais ca serait mieux qu'elle le soit")
endif
export DESCRIPTION
endif

#Les valeurs par défaut
###############################################
ifndef DISTNAME
DISTNAME:=$(PROJECT)
endif
export DISTNAME

ifndef WIKI
WIKI:=$(DISTNAME)
endif
export WIKI

ifdef VERSION
DISTDIR=$(DISTNAME)-$(VERSION)
DISTFILE=$(DISTDIR).tar.$(EXT_$(ZIP))
export VERSION DISTFILE DISTDIR
endif

ifndef CATEGORY
CATEGORY=autre
endif
export CATEGORY

###############################################
# Et c'est parti...
###############################################

MANIFEST:
	$(warning "** **")
	$(warning "* Je veux bien le faire, mais il serait bon de contrôler à la main. *")
	$(warning "** **")
	find . -type f | grep -v _darcs | grep -v CVS | grep -v .svn | grep -v '~' |grep -v '.version' | grep -v $(XMLFILE) |grep -Ev "$(DISTNAME)-.*.$(EXT_$(ZIP))" | sed -e 's/^\.\///' > MANIFEST
	echo MANIFEST >> MANIFEST

mrproper: dclean bclean

dist-clean dclean:
	rm -f .version $(XMLFILE)

base-clean bclean:
	find . \( -name ".*.swp" -print0 \) -or \( -name "*~" -print0  \) -or \( -name "*.tmp" -print0 \)  | xargs -0 rm -f 

binstall: $(PREFIX)/bin/$(FN)

ifdef FN

# Hack de con, mais sinon le else de FNMODE ne s'affiche pas...
/$(FN):

ifdef FNMODE
ifdef PREFIX

buninstall:
	rm -f $(PREFIX)/bin/$(FN)

$(PREFIX)/bin/$(FN): $(FN)
	mkdir -p $(PREFIX)/bin
	install -m$(FNMODE) -o 0 -g 0 $? $(PREFIX)/bin

else
	$(error "PREFIX doit etre defini pour utiliser binstall")
endif

else
	$(error "FNMODE (et PREFIX) doit etre defini pour utiliser binstall")
endif
else
	$(error "FN (et FNMODE, et PREFIX) doit etre defini pour utiliser binstall")
endif

ifdef DISTFILE


dist : $(DISTFILE) id
	
$(DISTFILE): MANIFEST $(shell cat MANIFEST)
	@echo "Fabrication de $(DISTFILE)"
	mkdir -p $(DISTDIR)
	[ "`id -u`" = "0" ] && mount -t tmpfs tmpfs $(DISTDIR) || echo -n
	tar -cf - $(shell cat MANIFEST) | tar -xf - -C $(DISTDIR)
	$(TAR) -cf $(DISTDIR).tar $(DISTDIR)
	$(ZIP) -9 $(DISTDIR).tar
	[ "`id -u`" = "0" ] && ( umount $(DISTDIR) && rmdir $(DISTDIR) ) || rm -rf $(DISTDIR)
	ln -f -s $(DISTDIR).tar.$(EXT_$(ZIP)) latest.tar.$(EXT_$(ZIP))

id xml : $(XMLFILE)

$(XMLFILE): $(shell cat MANIFEST)
# Et une Outterserie magique!
##########################################
	@maisousuisjedonc=();\
	toutcaoui=0;\
	commencer() { \
	echo -n '<?xml version="1.0"?>';\
	};\
	entrer(){\
		maisousuisjedonc[$$((toutcaoui++))]="$$1";\
	    printf "<%s" "$$1";\
		shift;\
		for i in "$$@" ; do printf ' %s"' "$${i/=/=\"}" ; done;\
		printf ">" ;\
	};\
	sortir() {\
		printf "</%s>" "$${maisousuisjedonc[$$((--toutcaoui))]}";\
	};\
	element() {\
		entrer "$$1";\
		printf "%s" "$$2";\
		sortir ;\
	};\
	( \
		commencer;\
		entrer projet titre=$(PROJECT);\
		element categorie $(CATEGORY);\
		element version $(VERSION);\
		element fichier $(DISTFILE);\
		element date $(DATE);\
		element description $(DESCRIPTION);\
		element wiki $(WIKI);\
		sortir\
	) > $(TMP)
	@if [ -e $(XMLLINT) ] && [ -e $(ICONV) ] ;\
	then \
		iconv -t utf8 < $(TMP) | $(XMLLINT)  --format - > $(XMLFILE) ;\
		rm -f $(TMP) ;\
	else \
		mv $(TMP) $(XMLFILE) ;\
	fi
	@cat $(XMLFILE)

else

xml id dist : .version
	@if [ -z "$(shell cat .version)" ] ; \
	then \
		$(MAKE) dist-clean VERSION=$(shell cat .version) $@ ; \
	else  \
		$(MAKE) VERSION=$(shell cat .version) $@ ; \
	fi

.version: $(shell cat MANIFEST)
	$(shell $(VERSIONFROM) > .version)

endif
