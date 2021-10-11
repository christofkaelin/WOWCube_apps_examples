#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240


new background = 24;
new figures[24][24][6];
new pictures[24] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23];

//TODO:
// 1. Implement multidimensional array to save figures.
// 2. Implement function to draw figures randomly.
// 3. Implement detection functions for:
//    3.1 User Input
//    3.2 Association
//    3.3 Arrangement

ONTICK() {
    //recalculate angle based on trbl
    CheckAngles();

    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        //abi_CMD_G2D_BEGIN_DISPLAY(screenI, true);
    }

    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_PHYSICS_TICK() {}
RENDER() {

    anchor_background();

    for (new screen = 0; screen < FACES_MAX; screen++) {   
        abi_CMD_G2D_BEGIN_DISPLAY(screen, true);       
        draw_background();      
        abi_CMD_G2D_END();
    }
}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}

draw_background() {
    abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, 0, MIRROR_BLANK);
}

anchor_background() {
    #ifndef G2D
    return;
    #endif
    for (new screen = 0; screen < FACES_MAX; screen++) {
        abi_CMD_G2D_BEGIN_BITMAP(screen, DISPLAY_WIDTH, DISPLAY_HEIGHT, true);
        abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, 0, MIRROR_BLANK);
        abi_CMD_G2D_END();
    }
}
//Returns 0 - 23 in random order.
draw_pictures() {

}

assign_group(picture) {

    if (picture <= 3) {
        return 0;
    } else if (picture > 3 && picture <= 7) {
        return 1;
    } else if (picture > 7 && picture <= 11) {
        return 2;
    } else if (picture > 11 && picture <= 15) {
        return 3;
    } else if (picture > 15 && picture <= 19) {
        return 4;
    } else if (picture > 19 && picture <= 23) {
        return 5;
    }
}