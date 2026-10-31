// Escreve na tela do PS2 e no console do emulador.
#include <stdio.h>
#include <kernel.h>
#include <debug.h>

int main(void)
{
    init_scr();
    scr_printf("Ola do PS2DEV-Windows!\n");
    printf("hello-world: ok\n");

    SleepThread();
    return 0;
}
