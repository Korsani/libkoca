#$Id: Makefile 1161 2013-01-03 10:28:56Z gab $
PROJECT=libkoca.sh
CATEGORY=autre
DISTNAME=shlibkoca
VERSIONFROM=make version
DESCRIPTION='Useful shell functions'
MAKEFLAGS += --no-print-directory --silent

PREFIX=/usr/local/include
FN=libkoca.sh
FNMODE=0644
WWW_DIR:=/var/www/files
LIBS:=$(wildcard libs/*.sh)
OUT:=$(addprefix out/,$(notdir $(LIBS)))

.PHONY : version 
.DEFAULT_GOAL := $(FN)


$(FN): $(OUT)
	cat $(OUT) | sed -e "s/__libname__/$(FN)/" > $@

$(OUT): out/%.sh: t/%.sh
	echo -n "$< ? "
	bash $< >/dev/null && cp libs/$(notdir $<) $@ && echo OK

clean: bclean dclean
	rm -f $(OUT)

version:
	@bash $(FN) version

ifneq "" "$(shell getent passwd www-data)"
ifneq "" "$(wildcard /var/www/files)"
install: $(PREFIX)/$(FN) $(WWW_DIR)/$(FN)
else
install: $(PREFIX)/$(FN)
endif
else
install: $(PREFIX)/$(FN)
endif

$(PREFIX)/$(FN): $(FN)
	install -D -m0644 $< $@
	rm -f $(PREFIX)/commun.sh
	echo 'echo "Unused" >&2' > $(PREFIX)/commun.sh
	$(info Installed in $(PREFIX))

# If dest file has to be installed in /var/www/files, it should exists BEFORE, as I won't create it
$(WWW_DIR)/$(FN): $(FN) /var/www/files
	install -o www-data -m0644 $< $@

-include commun.mk
