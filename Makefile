ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
SOBJS := index.shtml manual.shtml recent.shtml

OBJS := $(SRC:%.t=%.html) $(SOBJS) head.tmpl

.SUFFIXES: .t .html

%.html : %.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

%.shtml : %.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

all: $(OBJS)
	@(cd irc && $(MAKE))
	@(cd mail && $(MAKE))
	@(cd devcon && $(MAKE))
	@(cd digest && $(MAKE))
	@(cd doom && $(MAKE))

head.tmpl: head.t
	$(ACTION) -DTWIKI $<
	sed -i '/^$$/d' $@

indextop.html: indextop.t head.t

clean:
	rm $(OBJS)
	@(cd irc && $(MAKE) clean)
	@(cd mail && $(MAKE) clean)
	@(cd devcon && $(MAKE) clean)
	@(cd digest && $(MAKE) clean)
	@(cd doom && $(MAKE) clean)
