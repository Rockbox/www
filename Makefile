ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

SRC := $(wildcard *.t)
SOBJS := index.shtml manual.shtml recent.shtml daily.shtml

OBJS := $(SRC:%.t=%.html) $(SOBJS) head.tmpl

.SUFFIXES: .t .html

%.html : %.t head.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

%.shtml : %.t head.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

all: $(OBJS)
	@(cd irc && $(MAKE))
	@(cd mail && $(MAKE))
	@(cd devcon && $(MAKE))
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
