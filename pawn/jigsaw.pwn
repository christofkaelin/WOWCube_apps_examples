#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

new picture;
new figures[24][24][6];
new index[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23]

//TODO:
// 1. Implement multidimensional array to save figures.
// 2. Implement function to draw figures randomly.
// 3. Implement detection functions for:
//    3.1 User Input
//    3.2 Association
//    3.3 Arrangement

ONTICK() {
    new screenI;

    //recalculate angle based on trbl
    CheckAngles();

    draw_map();
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        abi_CMD_FILL(0, 0, 0);

        //draw bitmap at screen on the frame buffer
        // Bitmap for backgrounds.
        abi_CMD_BITMAP(PICTURE, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);
        //push buffer at screen
        abi_CMD_REDRAW(screenI);

        //pictures as sprites.
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

//Returns 0 - 23 in random order.
draw_picture() {
    new n = sizeof(index) / sizeof(index[0]);
    
    randomize (arr, n);

    for (new i = 0; i < n; i++) {
        new int indx = index[i];
        figures[24][indx][6];
    }

    printf("%2d - %s\n", i+1, index[indx]);
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

draw_map() {
    for (new i = 0; i < 24; i++) {
        picture = draw_picture();
        group = assign_group(picture);
        pictures[i][picture][group];
    }
}

swap(int a, int b) {
    int temp = a;
    a = b;
    b = temp;
}

randomize(arr[], n) {
    srand(time(NULL));
    for (new i = n - 1; i > 0; i--) {
        int j = random(256) % (i + 1);
        swap(arr[i], arr[j]);
    }
}