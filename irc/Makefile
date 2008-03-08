ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -I.. -Uunix -H -C -V -LL >$@

OBJS = index.shtml

all: index.shtml cgiirc current.txt head.html reader.txt

index.shtml: index.t ../head.t ../foot.t
	$(ACTION) $<

cgiirc:
	rm -f cgiirc
	ln -s cgiirc-0.5.7 cgiirc

current.txt:
	rm -f current.txt
	ln -s /home/bjst/logbot/logfile current.txt

head.html:
	rm -f head.html
	ln -s ../head.html

reader.txt:
	rm -f reader.txt
	ln -s reader.pl reader.txt

clean:
	rm -f $(OBJS)
