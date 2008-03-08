ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -I.. -H -C -V -LL >$@

HTML = etiquette.html

all : $(HTML) archive

etiquette.html: etiquette.t ../head.t ../foot.t
	$(ACTION) $<

archive:
	rm -f archive
	ln -s /home/maildump/html archive

clean:
	rm -f $(HTML)
