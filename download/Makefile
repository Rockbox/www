ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -I.. -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

%.html : %.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

all: $(OBJS)

clean:
	rm -f $(OBJS)
