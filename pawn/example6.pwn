#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define PICTURE         0

#define SHIFT_POS       5
#define SHIFT_ANGLE     5 

new current_angles[FACES_MAX] = [0, 0, 0];
new position_x[FACES_MAX] = [60, 60, 60];
new position_y[FACES_MAX] = [60, 60, 60];

ONTICK() {
    new screenI;
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        abi_CMD_FILL(0, 0, 0);
        //draw bitmap at screen on the frame buffer
        abi_CMD_BITMAP(PICTURE, position_x[screenI], position_y[screenI], current_angles[screenI], MIRROR_BLANK);

        //recalculate positions and angles
        position_x[screenI] = (((position_y[screenI] == 60) && (current_angles[screenI] == 0)) ? position_x[screenI] + SHIFT_POS :
            ((position_y[screenI] == 180) && (current_angles[screenI] == 180)) ? position_x[screenI] - SHIFT_POS : position_x[screenI]);

        position_y[screenI] = (((position_x[screenI] == 60) && (current_angles[screenI] == 270)) ? position_y[screenI] - SHIFT_POS :
            ((position_x[screenI] == 180) && (current_angles[screenI] == 90)) ? position_y[screenI] + SHIFT_POS : position_y[screenI]);


        current_angles[screenI] = ((((position_x[screenI] == 180) && (position_y[screenI] == 60) && (current_angles[screenI] != 90)) ||
            ((position_x[screenI] == 180) && (position_y[screenI] == 180) && (current_angles[screenI] != 180)) ||
            ((position_x[screenI] == 60) && (position_y[screenI] == 180) && (current_angles[screenI] != 270)) ||
            ((position_x[screenI] == 60) && (position_y[screenI] == 60) && (current_angles[screenI] != 0))) ? (current_angles[screenI] + SHIFT_ANGLE) % 360 : current_angles[screenI]);
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
