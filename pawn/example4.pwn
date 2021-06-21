#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define PICTURE 0

ONTICK() {
    new screenI;
    //recalculate angle based on trbl
    CheckAngles();
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        abi_CMD_FILL(0, 0, 0);
        //draw bitmap at screen on the frame buffer
        abi_CMD_BITMAP(PICTURE, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);
        //push buffer at screen
        abi_CMD_REDRAW(screenI);
    }
    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}
