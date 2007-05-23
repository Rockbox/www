ACTION=echo preprocessing $@; rm -f $@; \
       $(HOME)/bin/fcpp -WWW -I.. -Uunix -H -C -V -LL $< $@

OBJS := index.shtml old.html 25.html

all: $(OBJS)

index.shtml: index.t ../head.t ../foot.t
	$(ACTION)

25.html: 25.t ../head.t ../foot.t
	$(ACTION)

old.html: old.t
	$(ACTION)

clean:
	rm -f $(OBJS)
