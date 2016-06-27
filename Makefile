
SUBDIRS =  tools boot kern

all: image cf

image: subdirs
	tools/sign bin/bootblock.out bin/bootblock
	dd if=/dev/zero of=bin/liunix.img count=10000
	dd if=bin/bootblock of=bin/liunix.img conv=notrunc
	dd if=bin/kernel.elf of=bin/liunix.img seek=1 conv=notrunc
	dd if=/dev/zero of=bin/swap.img bs=1M count=128

subdirs:
	mkdir -p bin
	for n in $(SUBDIRS); do $(MAKE) -C $$n || exit 1; done


RTL2DOT_IGNORE:= "cprintf|__panic|kfree|kmalloc|memset|strlen|strcpy|strcmp"
RTL2DOT_OPT:= --root kern_init --ignore $(RTL2DOT_IGNORE) --local
cg:
	find kern -name '*.expand'| sort | xargs -r tools/rtl2dot.py $(RTL2DOT_OPT) 2>/dev/null | dot -Gsize=8.5,11 -Grankdir=LR -Tsvg -o bin/callgraph.svg


.PHONY:clean
clean:
	rm -Rf bin
	for n in $(SUBDIRS); do $(MAKE) -C $$n clean; done


QEMUOPTS = -parallel stdio -hda bin/liunix.img -drive file=bin/swap.img,media=disk,cache=writeback -serial null

.PHONY:qemu
qemu: image
	qemu-system-i386 $(QEMUOPTS)

.PHONY:debug
debug: image
	qemu-system-i386 -S -s $(QEMUOPTS) &
	sleep 2
	gnome-terminal -e "cgdb -q -x tools/gdbinit_kernel"


.PHONY:debug_boot
debug_boot: image
	qemu-system-i386 -S -s -parallel stdio -hda bin/liunix.img -serial null &
	sleep 2
	gnome-terminal -e "cgdb -q -x tools/gdbinit_boot"