ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS)
	@(cd winner; $(MAKE))

%.html : %.t
	$(ACTION) $<
