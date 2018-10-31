LIBFILES=$(wildcard ../libs/*.sh)
TESTFILES=$(wildcard *Test.sh)

t: $(LIBFILES)

${LIBFILES}: ../libs/%.sh: %Test.sh
	bash $< && touch $@
