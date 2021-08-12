#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"
#include <time>

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define FIRE          0
#define WATER       512
#define EARTH      1024
#define WIND       1536

new picture, element, element_min = FIRE;
new element_max = FIRE + 508;

ONTICK() {
    new screenI;

    //recalculate angle based on trbl
    CheckAngles();

    //clear screen before output
    abi_CMD_FILL(0, 0, 0);

    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //draw bitmap at screen on the frame buffer
        abi_CMD_BITMAP(picture + newAngles[screenI] / 90, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);
        //push buffer at screen
        abi_CMD_REDRAW(screenI);
    }

    if (picture >= element_max) {
        picture = element_min;
    }
    picture = picture + 4;
    delay(40);

    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {
    element = random(4);
    switch (element) {
        case 0: {
            picture, element_min = FIRE;
            element_max = FIRE + 508;
        }
        case 1: {
            picture, element_min = WATER;
            element_max = WATER + 508;
        }
        case 2: {
            picture, element_min = EARTH;
            element_max = EARTH + 508;
        }
        case 3: {
            picture, element_min = WIND;
            element_max = WIND + 508;
        }
    }
    // TODO: play sound on repeat
    //abi_CMD_PLAYSND(element, 100);
}
