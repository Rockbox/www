ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -I.. -Uunix -H -C -V -LL >$@

OBJS = index.shtml

all: $(OBJS)

index.shtml: index.t ../head.t ../foot.t
	$(ACTION) $<

clean:
	rm -f $(OBJS)
