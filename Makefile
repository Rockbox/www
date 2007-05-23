ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
SOBJS := daily.shtml main.shtml index.shtml status.shtml \
	bugs.shtml requests.shtml patches.shtml manual.shtml

OBJS := $(SRC:%.t=%.html) $(SOBJS) head.tmpl

.SUFFIXES: .t .html

%.html : %.t
	$(ACTION) $<

%.shtml : %.t
	$(ACTION) $<

all: $(OBJS) since25.html since20060801.html since-4weeks.html
	@(cd schematics; $(MAKE))
	@(cd docs; $(MAKE))
	@(cd mods; $(MAKE))
	@(cd internals; $(MAKE))
	@(cd irc; $(MAKE))
	@(cd mail; $(MAKE))
	@(cd devcon; $(MAKE))
	@(cd sh-win; $(MAKE))
	@(cd download; $(MAKE))
	@(cd manual; $(MAKE))
	@(cd manual-1.2; $(MAKE))
#	@(cd fonts; $(MAKE))
	@(cd screenshots; $(MAKE))
	@(cd digest; $(MAKE))
	@(cd playerhistory; $(MAKE))
#	@(cd devcon2006; $(MAKE))
	@(cd doom; $(MAKE))

since20060801.html:
	ln -sf /home/dast/daniel_html/rockbox/since-200608.html since20060801.html

since-4weeks.html:
	ln -sf /home/dast/daniel_html/rockbox/since-4weeks.html .

head.tmpl: head.t
	$(ACTION) -DTWIKI $<
	sed -i '/^$$/d' $@

main.html: main.t activity.html head.t

main.shtml: main.t activity.html head.t

index.shtml: main.shtml head.t
	ln -sf main.shtml index.shtml

indextop.html: indextop.t head.t

daily.shtml: daily.t head.t

manual.shtml: manual.t head.t

since25.html:
	ln -sf /home/dast/daniel_html/rockbox/since25.html since25.html

clean:
	rm $(OBJS)
	@(cd schematics; $(MAKE) clean)
	@(cd docs; $(MAKE) clean)
	@(cd mods; $(MAKE) clean)
	@(cd internals; $(MAKE) clean)
	@(cd irc; $(MAKE) clean)
	@(cd mail; $(MAKE) clean)
	@(cd devcon; $(MAKE) clean)
	@(cd sh-win; $(MAKE) clean)
	@(cd download; $(MAKE) clean)
	@(cd manual; $(MAKE) clean)
	@(cd manual-1.2; $(MAKE) clean)
#	@(cd fonts; $(MAKE) clean)
	@(cd screenshots; $(MAKE) clean)
	@(cd digest; $(MAKE) clean)
	@(cd playerhistory; $(MAKE) clean)
#	@(cd devcon2006; $(MAKE) clean)
	@(cd doom; $(MAKE) clean)
