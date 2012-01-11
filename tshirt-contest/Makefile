ACTION=@echo preprocessing $@; rm -f $@; fcpp -WWW -I.. -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS)
	@(cd winner; $(MAKE))

%.html : %.t
	$(ACTION) $<
