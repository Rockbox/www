ACTION=@echo preprocessing $@; rm -f $@; fcpp -WWW -I.. -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS)

clean:
	rm $(OBJS)

%.html : %.t
	$(ACTION) $<
