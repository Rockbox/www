ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

HTML = etiquette.html

all : $(HTML)

etiquette.html: etiquette.t ../head.t ../foot.t
	$(ACTION) $<

clean:
	rm -f $(HTML)
