#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240


new background = 24;
new figures[24];
new group [24];

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
    CheckAngles();
    for (new screen = 0; screen < 3; screen++) {
        abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
        draw_background(screen);
        draw_pictures(screen);
        abi_CMD_G2D_END();
    }
}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {
    init_variables();
}
ON_CHECK_ROTATE() {}

init_variables() {
    for (new n; n < 24; n++) {
        figures[n] = random(24);
        group[n] = assign_group(figures[n])
    }
}

draw_background(screen) {
    abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
}

anchor_background() {
    #ifndef G2D
    return;
    #endif
    CheckAngles();
    for (new screen = 0; screen < 3; screen++) {
        abi_CMD_G2D_BEGIN_BITMAP(screen, DISPLAY_WIDTH, DISPLAY_HEIGHT, true);
        abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        abi_CMD_G2D_END();
    }
}

draw_pictures(screen) {    
    abi_CMD_G2D_ADD_SPRITE(figures[screen], false, 120, 120, 0xFF, 0, 0, MIRROR_BLANK);
   
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