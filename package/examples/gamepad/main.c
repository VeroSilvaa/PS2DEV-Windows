// Mostra na tela os botoes pressionados no controle 1.
#include <stdio.h>
#include <kernel.h>
#include <sifrpc.h>
#include <loadfile.h>
#include <libpad.h>
#include <debug.h>

static char pad_buffer[256] __attribute__((aligned(64)));

static void wait_pad_ready(void)
{
    int state = padGetState(0, 0);
    while (state != PAD_STATE_STABLE && state != PAD_STATE_FINDCTP1)
        state = padGetState(0, 0);
}

int main(void)
{
    struct padButtonStatus buttons;
    unsigned int last = 0;

    SifInitRpc(0);
    init_scr();
    scr_printf("Pressione os botoes do controle 1.\n");

    SifLoadModule("rom0:SIO2MAN", 0, NULL);
    SifLoadModule("rom0:PADMAN", 0, NULL);
    padInit(0);
    padPortOpen(0, 0, pad_buffer);
    wait_pad_ready();
    printf("gamepad: ok\n");

    while (1) {
        unsigned int pressed;

        wait_pad_ready();
        if (padRead(0, 0, &buttons) == 0)
            continue;

        pressed = 0xffff ^ buttons.btns;
        if (pressed != last) {
            scr_printf("Botoes: 0x%04x\n", pressed);
            last = pressed;
        }
    }
    return 0;
}
