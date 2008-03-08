ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -I.. -H -C -V -LL >$@

HTML = etiquette.html

all : $(HTML)

etiquette.html: etiquette.t ../head.t ../foot.t
	$(ACTION) $<

clean:
	rm -f $(HTML)
