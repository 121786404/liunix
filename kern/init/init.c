#include <defs.h>
#include <stdio.h>
#include <string.h>
#include <console.h>
#include <picirq.h>
#include <trap.h>
#include <clock.h>
#include <intr.h>
#include <pmm.h>

void kern_init(void) __attribute__((noreturn));


void
kern_init(void){
    extern char etext, edata, end;
    memset(&edata, 0, &end - &edata);

    cons_init();                // init the console

    cprintf("%s\n\n", "liunix is loading ...");
    cprintf("Special kernel symbols:\n");
    cprintf("  entry  0x%08x (phys)\n", kern_init);
    cprintf("  etext  0x%08x (phys)\n", &etext);
    cprintf("  edata  0x%08x (phys)\n", &edata);
    cprintf("  end    0x%08x (phys)\n", &end);
    cprintf("Kernel executable memory footprint: %dKB\n\n", (&end - (char*)kern_init + 1023)/1024);

    pmm_init();                 // init physical memory management

    pic_init();                 // init interrupt controller
    idt_init();                 // init interrupt descriptor table

    clock_init();               // init clock interrupt
    intr_enable();              // enable irq interrupt

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test


    /* do nothing */
    while (1);
}

