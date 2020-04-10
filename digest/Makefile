ACTION=@echo preprocessing $@; rm -f $@; cpp -P >$@

SRC := $(wildcard *.t)
OBJS := $(SRC:%.t=%.html)

all: $(OBJS) digest.rss digest.mail

clean:
	rm $(OBJS)

digest.html: digest.t news.t digesthead.t log.t
	$(ACTION)

index.html: index.t ../head.t news.t ../foot.t

%.html : %.t news.t digesthead.t log.t
	$(ACTION)

digest.mail: mail.t log.t mailify.pl
	@echo mailifying $@;
	cpp -P -DMAKE_MAIL $< digest.temp
	./mailify.pl < digest.temp > digest.mail

digest.rss: digest.t digesthead.t log.raw
	@echo rssing $@;
	@rm -f $@;
	@cpp -P -DMAKE_RSS $< digest.temp

log.raw: log.t rssify.pl digesthead.t
	./rssify.pl < $< >$@



