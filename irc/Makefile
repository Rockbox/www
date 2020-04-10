ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

OBJS = index.shtml

all: $(OBJS)

index.shtml: index.t ../head.t ../foot.t
	$(ACTION) $<

clean:
	rm -f $(OBJS)
