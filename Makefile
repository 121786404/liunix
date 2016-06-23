
SUBDIRS =  tools boot kern

all: image cg

image: subdirs
	tools/sign bin/bootblock.out bin/bootblock
	dd if=/dev/zero of=bin/liunix.img count=10000
	dd if=bin/bootblock of=bin/liunix.img conv=notrunc
	dd if=bin/kernel.elf of=bin/liunix.img seek=1 conv=notrunc


subdirs:
	mkdir -p bin
	for n in $(SUBDIRS); do $(MAKE) -C $$n || exit 1; done


RTL2DOT_IGNORE:= "client_send|cprintf|common_*"
RTL2DOT_OPT:= --root kern_init --ignore $(RTL2DOT_IGNORE) --local
cg:
	find kern -name '*.expand'| sort | xargs -r tools/rtl2dot.py $(RTL2DOT_OPT) | dot -Gsize=8.5,11 -Grankdir=LR -Tsvg -o bin/callgraph.svg


cg2:
	@#cflow -b -m kern_init ./kern/init/init.c -o bin/callgraph.txt
	@#cat bin/callgraph.txt | tools/tree2dotx > bin/callgraph.dot
	@#dot bin/callgraph.dot -Tsvg -o bin/callgraph.svg
	cflow -b -m kern_init kern/init/init.c | tools/tree2dotx 2>/dev/null | dot -Tsvg -o ./bin/callgraph.svg

.PHONY:clean
clean:
	rm -Rf bin
	for n in $(SUBDIRS); do $(MAKE) -C $$n clean; done


.PHONY:qemu
qemu: image
	qemu-system-i386 -parallel stdio -hda bin/liunix.img -serial null


.PHONY:debug
debug: image
	qemu-system-i386 -S -s -parallel stdio -hda bin/liunix.img -serial null &
	sleep 2
	gnome-terminal -e "cgdb -q -x tools/gdbinit_kernel"

.PHONY:debug_boot
debug_boot: image
	qemu-system-i386 -S -s -parallel stdio -hda bin/liunix.img -serial null &
	sleep 2
	gnome-terminal -e "cgdb -q -x tools/gdbinit_boot"

.PHONY:debug_mon
debug_mon: image
	gnome-terminal -e "qemu-system-i386 -S -s -d in_asm -D bin/q.log -monitor stdio -hda bin/liunix.img -serial null"
	sleep 2
	gnome-terminal -e "cgdb -q -x tools/gdbinit_kernel"