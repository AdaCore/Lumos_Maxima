
SOURCE= spec implem pair_set partial_map simple_hashtbl interface
SOURCEMLW=$(addsuffix .mlw,$(SOURCE))

all: doc session

doc/index.html: $(SOURCEMLW)
	mkdir -p doc
	why3 doc -L . $(SOURCEMLW) -o doc

# TODO doc to be opened on doc/ for the session files
doc: doc/index.html

SOURCESESSION=$(addprefix doc/, $(addsuffix session.html,$(SOURCE)))

doc/%session.html: %.mlw
	mkdir -p doc
	why3 session html -L . -o doc $^
	mv doc/why3session.html $@

session: $(SOURCESESSION)

replay:
	@for i in $(SOURCE); do \
		printf "== Replaying session '$$i'\n" ;  \
		why3 replay -L . $$i; \
	done

extract:
	why3 extract -L . --recursive -D driver/ocaml_ext.drv code/code.mlw -o extract/all.ml
	dune build extract/code__Top.exe

clean:
	rm -f extract/all.ml
	rm -rf doc

.PHONY: extract doc
