ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS)

%.html : %.t
	$(ACTION) $<
