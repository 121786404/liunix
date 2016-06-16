
SUBDIRS =  boot kern tools

all: subdirs

subdirs:
	mkdir -p bin
	for n in $(SUBDIRS); do $(MAKE) -C $$n || exit 1; done

clean:
	rm -Rf bin
	for n in $(SUBDIRS); do $(MAKE) -C $$n clean; done
