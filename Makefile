ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
SOBJS := daily.shtml main.shtml index.shtml status.shtml \
	bugs.shtml requests.shtml
OBJS := $(SRC:%.t=%.html) $(SOBJS)

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
	@(cd manual; $(MAKE))
	@(cd manual-1.2; $(MAKE))
	@(cd tshirt-contest; $(MAKE))

main.html: main.t activity.html

main.shtml: main.t activity.html

index.shtml: main.shtml
	ln -s main.shtml index.shtml

daily.shtml: daily.t

clean:
	find . -name "*html" | xargs rm
