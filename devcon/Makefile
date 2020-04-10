ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS)

clean:
	rm $(OBJS)

%.html : %.t
	$(ACTION) $<
