#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

new picture;
new figures[24][24][6];
new index[24] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23};

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
        abi_CMD_BITMAP(picture, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);
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
    /* @Vinz: sizeof ist keine Funktion und sizeof von einem Value geht nicht.
    Meinst du sowas? */
    new n = sizeof index / index[0];
    
    // @Vinz: Welche Array willst du hier randomizen ("arr" ist nicht defined)? Ich gehe mal von "index" aus
    randomize(index, n);

    for (new i = 0; i < n; i++) {
        new indx;
        indx = index[i];
        //figures[24][indx][6]; @Vinz: Diese Zeile macht nichts
        printf("%2d - %s\n", i+1, index[indx]); 
    }
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
    new group;
    for (new i = 0; i < 24; i++) {
        // @Vinz: bei draw_picture() braucht es irgendeinen return-Value, sonst wird hier 0 assigned.
        picture = draw_picture();
        group = assign_group(picture);
        figures[i][picture][group]; // @Vinz: Wir haben keinen pictures-array. Denke du meinst figures?
    }
}

swap(a, b) {
    new temp = a;
    a = b;
    b = temp;
}

randomize(arr[], n) {
    //srand(time(NULL)); @Vinz: srand gibt es in Pawn nicht
    for (new i = n - 1; i > 0; i--) {
        new j = random(256) % (i + 1);
        swap(arr[i], arr[j]);
    }
}
