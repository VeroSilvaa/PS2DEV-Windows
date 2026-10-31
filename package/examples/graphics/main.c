// Um quadrado que quica pela tela, desenhado com gsKit.
#include <stdio.h>
#include <gsKit.h>
#include <dmaKit.h>

int main(void)
{
    GSGLOBAL *gs = gsKit_init_global();
    u64 black = GS_SETREG_RGBAQ(0x00, 0x00, 0x00, 0x00, 0x00);
    u64 blue = GS_SETREG_RGBAQ(0x20, 0x60, 0xff, 0x00, 0x00);
    float x = 50.0f, y = 50.0f, dx = 3.0f, dy = 2.0f;
    const float size = 80.0f;

    dmaKit_init(D_CTRL_RELE_OFF, D_CTRL_MFD_OFF, D_CTRL_STS_UNSPEC,
                D_CTRL_STD_OFF, D_CTRL_RCYC_8, 1 << DMA_CHANNEL_GIF);
    dmaKit_chan_init(DMA_CHANNEL_GIF);

    gsKit_init_screen(gs);
    gsKit_mode_switch(gs, GS_ONESHOT);
    printf("graphics: ok\n");

    while (1) {
        x += dx;
        y += dy;
        if (x < 0.0f || x + size > gs->Width)
            dx = -dx;
        if (y < 0.0f || y + size > gs->Height)
            dy = -dy;

        gsKit_clear(gs, black);
        gsKit_prim_sprite(gs, x, y, x + size, y + size, 1, blue);
        gsKit_queue_exec(gs);
        gsKit_sync_flip(gs);
    }
    return 0;
}
