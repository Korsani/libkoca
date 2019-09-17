#$Id: Makefile 1161 2013-01-03 10:28:56Z gab $
PROJECT=libkoca.sh
CATEGORY=autre
DISTNAME=libkoca
VERSIONFROM=make version
DESCRIPTION='Useful shell functions'
MAKEFLAGS += --no-print-directory --silent

PREFIX=/usr/local
MAN_SECTION=3
OS=$(shell uname)
ifeq "FreeBSD" "$(OS)"
MAN_DIR=$(PREFIX)/man/man$(MAN_SECTION)
else
MAN_DIR=$(PREFIX)/share/man/man$(MAN_SECTION)
endif
MAN_PAGE=libkoca.$(MAN_SECTION)
FN=libkoca.sh
FNMODE=0644
WWW_DIR:=/var/www/files
LIBS:=$(sort $(wildcard libs/*.sh))
OUT:=$(addprefix out/,$(notdir $(LIBS)))

.PHONY : version man

all: $(FN) man

man: libkoca.$(MAN_SECTION)

libkoca.$(MAN_SECTION): libkoca.pod
	$(info Generating $@)
	podchecker $< && pod2man -name libkoca < $< > $@

$(FN): $(OUT)
	cat $(OUT) | sed -e "s/__libname__/$(FN)/" > $@
	$(info $@ built)

$(OUT): out/%.sh: libs/%.sh t/%Test.sh
	$(ECHO) -n "Testing $< ... "
	bash $(subst .sh,Test.sh,$(subst libs,t,$<)) >/dev/null && cp libs/$(notdir $<) $@ && echo OK

clean: bclean dclean
	$(info Cleaning)
	rm -f $(OUT)
	rm -f libkoca.$(MAN_SECTION) $(FN)

version:
	@bash $(FN) version

# getent doesn't exist on Darwin. And I don't need to install www part on Darwin...
ifeq "" "$(filter $(OS),Darwin)"
# And... echo is echo
ECHO=echo
ifneq "" "$(shell getent passwd www-data)"
ifneq "" "$(wildcard /var/www/files)"
install: $(PREFIX)/include/$(FN) $(WWW_DIR)/$(FN) $(MAN_DIR)/$(MAN_PAGE).gz
else
install: $(PREFIX)/include/$(FN) $(MAN_DIR)/$(MAN_PAGE).gz
endif
else
install: $(PREFIX)/include/$(FN) $(MAN_DIR)/$(MAN_PAGE).gz
endif
else
# and echo is not echo on Darwin
ECHO=/usr/local/opt/coreutils/libexec/gnubin/echo
install: $(PREFIX)/include/$(FN) $(MAN_DIR)/$(MAN_PAGE).gz
endif

$(PREFIX)/include/$(FN): $(FN)
	install -D -m0644 $< $@
	rm -f $(PREFIX)/include/commun.sh
	$(ECHO) 'echo "Unused" >&2' > $(PREFIX)/include/commun.sh
	$(info Installed in $(PREFIX)/include)

# If dest file has to be installed in /var/www/files, it should exists BEFORE, as I won't create it
$(WWW_DIR)/$(FN): $(FN) /var/www/files
	install -o www-data -m0644 $< $@

$(MAN_DIR)/$(MAN_PAGE).gz: $(MAN_DIR)/$(MAN_PAGE)
	gzip -f $<

$(MAN_DIR)/$(MAN_PAGE): libkoca.$(MAN_SECTION)
	install -D -m0644 $< $@

-include commun.mk
