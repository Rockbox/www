ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html) daily.shtml main.shtml index.shtml

.SUFFIXES: .t .html

%.html : %.t
	$(ACTION) $<

%.shtml : %.t
	$(ACTION) $<

all: $(OBJS)
	@(cd schematics; $(MAKE))
	@(cd docs; $(MAKE))
	@(cd mods; $(MAKE))
	@(cd internals; $(MAKE))
	@(cd irc; $(MAKE))
	@(cd devcon; $(MAKE))
	@(cd sh-win; $(MAKE))
	@(cd download; $(MAKE))

main.html: main.t activity.html

main.shtml: main.t activity.html

index.shtml: main.shtml
	ln -s main.shtml index.shtml

daily.shtml: daily.t

