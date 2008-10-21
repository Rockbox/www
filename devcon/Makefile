ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -I.. -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS)

clean:
	rm $(OBJS)

%.html : %.t
	$(ACTION) $<
