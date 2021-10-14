#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240


new background = 24;
new figures[24];
new group[24];

//TODO:
// 1. Implement multidimensional array to save figures.
// 2. Implement function to draw figures randomly.
// 3. Implement detection functions for:
//    3.1 User Input
//    3.2 Association
//    3.3 Arrangement

ONTICK() {
    // CheckAngles();
    // for (new screenI = 0; screenI < FACES_MAX; screenI++) {
    // }
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
        draw_figures(screen);
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
    //Fill array with 0-23
    for (new n = 0; n < 24; n++) {
        figures[n] = n;
    }
    //Shuffle the array
    for (new n = 0; n < 24; n++) {
        new rand = random(24);
        swap_slots(figures, n, rand);
    }
    //Index group affiliation
    for (new n = 0; n < 24; n++) {
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

draw_figures(screen) {
    CheckAngles();
    abi_CMD_G2D_ADD_SPRITE(figures[screen], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
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

check_match() {
    for (new cube = 0; cube < 8; cube++) {
        for (new face = 0; face < 3; face++) {
            new leftCube = abi_leftCubeN(cube, face);
            new leftFace = abi_leftFaceN(cube, face);
            new topCube = abi_topCubeN(cube, face);
            new topFace = abi_topFaceN(cube, face);
            new diagonalCube;
            new diagonalFace;
            if (topCube < 8) {
                diagonalCube = abi_topCubeN(topCube, topFace);
                if (diagonalCube < 8) {
                    diagonalFace = abi_topFaceN(topCube, topFace);
                }
            }
            if (((face == leftFace) && (leftFace == topCube) && (topCube == diagonalFace) && (diagonalFace == face)) &&
                ((cube != leftCube) && (leftCube != topCube) && (topCube != diagonalCube) && (diagonalCube != cube))) {
                //figures[cube] = 25;
                //draw_figures(cube);
                return;
            }
        }
    }
}

swap_slots(figures[], n, rand) {
    new temp = figures[rand];
    figures[rand] = figures[n];
    figures[n] = temp;
}