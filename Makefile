PROJECT=libkoca.sh
DISTNAME=libkoca
DESCRIPTION='Useful shell functions'
MAKEFLAGS += --no-print-directory --silent
BRANCH="$(shell git rev-parse --abbrev-ref HEAD)"
SHUNIT="$(shell bash -c "type -P shunit2")"
#VERSION=$(shell git log -1 --pretty=format:"%as")-$(BRANCH)
D="$(shell date '+%s')"
# Ok, that's arbitrary
VERSION=0.$(shell echo "($(D)-1587892548)/100"|bc )

PREFIX=/usr/local
MAN_SECTION=3
OS=$(shell uname)
MAN_PAGE=libkoca.$(MAN_SECTION)
FN=libkoca.sh
LIBS:=$(sort $(wildcard libs/*.sh))
OUT:=$(addprefix out/,$(notdir $(LIBS)))

ifeq "" "$(SHUNIT)"
$(warning shunit2 not found. Lib will be built WITHOUT testing)
endif

ifeq "FreeBSD" "$(OS)"
MAN_DIR:=$(PREFIX)/man/man$(MAN_SECTION)
MAKE:=gmake
else
MAN_DIR:=$(PREFIX)/share/man/man$(MAN_SECTION)
endif

ifeq "Darwin" "$(OS)"
ECHO=/usr/local/opt/coreutils/libexec/gnubin/echo
else
ECHO=echo
endif

.PHONY: version man update

DEFAULT_GOAL: all

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
	bash $(subst .sh,Test.sh,$(subst libs,t,$<)) >/dev/null && sed -e '1d' -e "s/%VERSION%/$(VERSION)/" < libs/$(notdir $<) > $@ && echo OK

clean: bclean dclean
	$(info Cleaning)
	rm -f $(OUT)
	rm -f libkoca.$(MAN_SECTION) $(FN)

version:
	@bash $(FN) version

$(PREFIX)/include/$(FN): $(FN)
	mkdir -p $(PREFIX)/include
	install -m0644 $< $@
	rm -f $(PREFIX)/include/commun.sh
	$(ECHO) 'echo "Unused" >&2' > $(PREFIX)/include/commun.sh
	$(info Installed in $(PREFIX)/include)

$(MAN_DIR)/$(MAN_PAGE).gz: libkoca.$(MAN_SECTION)
	mkdir -p $(MAN_DIR)
	gzip -c $< > $@
	chmod 0644 $@
	$(info Man page installed)

install: $(PREFIX)/include/$(FN) $(MAN_DIR)/$(MAN_PAGE).gz

update:
	git pull
	$(MAKE)

help:
	$(info update help install)

-include commun.mk
