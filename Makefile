ACTION=@echo preprocessing $@; rm -f $@; $(HOME)/bin/fcpp -WWW -Uunix -H -C -V -LL >$@

SRC := $(wildcard *.t)
SOBJS := daily.shtml main.shtml index.shtml status.shtml \
	bugs.shtml requests.shtml patches.shtml manual.shtml \
	recent.shtml

OBJS := $(SRC:%.t=%.html) $(SOBJS) head.tmpl

.SUFFIXES: .t .html

%.html : %.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

%.shtml : %.t
	$(ACTION) $<
	@sed -i '/^$$/d' $@

all: $(OBJS) since25.html since20060801.html since-4weeks.html
	@(cd irc && $(MAKE))
	@(cd mail && $(MAKE))
	@(cd devcon && $(MAKE))
	@(cd digest && $(MAKE))
	@(cd doom && $(MAKE))

since20060801.html:
	ln -sf /home/dast/daniel_html/rockbox/since-200608.html since20060801.html

since-4weeks.html:
	ln -sf /home/dast/daniel_html/rockbox/since-4weeks.html .

head.tmpl: head.t
	$(ACTION) -DTWIKI $<
	sed -i '/^$$/d' $@

main.html: main.t head.t

main.shtml: main.t head.t

index.shtml: main.shtml head.t
	ln -sf main.shtml index.shtml

indextop.html: indextop.t head.t

daily.shtml: daily.t head.t

manual.shtml: manual.t head.t

since25.html:
	ln -sf /home/dast/daniel_html/rockbox/since25.html since25.html

clean:
	rm $(OBJS)
	@(cd irc && $(MAKE) clean)
	@(cd mail && $(MAKE) clean)
	@(cd devcon && $(MAKE) clean)
	@(cd digest && $(MAKE) clean)
	@(cd doom && $(MAKE) clean)
