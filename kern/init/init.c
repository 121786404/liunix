#include <defs.h>
#include <stdio.h>
#include <console.h>


void kern_init(void) __attribute__((noreturn));


void
kern_init(void){
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();                // init the console

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();

    /* do nothing */
    while (1);
}




