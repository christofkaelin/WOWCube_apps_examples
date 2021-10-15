#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
#define BACKGROUND 24

new figures[24];
new group[24];
//position[cube][face][group]
new position[8][3][6];

ONTICK() {
    check_match();
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
    track_position();
}

//Change assignment to: 0-23 when draw function has been updated accordingly.
track_position() {
    //position[cube][face][group]
    position[0][0][0] = group[0];
    position[0][1][0] = group[1];
    position[0][2][0] = group[2];
    position[1][0][0] = group[0];
    position[1][1][0] = group[1];
    position[1][2][0] = group[2];
    position[2][0][0] = group[0];
    position[2][1][0] = group[1];
    position[2][2][0] = group[2];
    position[3][0][0] = group[0];
    position[3][1][0] = group[1];
    position[3][2][0] = group[2];
    position[4][0][0] = group[0];
    position[4][1][0] = group[1];
    position[4][2][0] = group[2];
    position[5][0][0] = group[0];
    position[5][1][0] = group[1];
    position[5][2][0] = group[2];
    position[6][0][0] = group[0];
    position[6][1][0] = group[1];
    position[6][2][0] = group[0];
    position[7][0][0] = group[0];
    position[7][1][0] = group[1];
    position[7][2][0] = group[2];
}

draw_background(screen) {
    abi_CMD_G2D_ADD_SPRITE(BACKGROUND, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
}

anchor_background() {
    #ifndef G2D
    return;
    #endif
    CheckAngles();
    for (new screen = 0; screen < 3; screen++) {
        abi_CMD_G2D_BEGIN_BITMAP(screen, DISPLAY_WIDTH, DISPLAY_HEIGHT, true);
        abi_CMD_G2D_ADD_SPRITE(BACKGROUND, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        abi_CMD_G2D_END();
    }
}

draw_figures(screen) {
    CheckAngles();
    abi_CMD_G2D_ADD_SPRITE(figures[screen], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
}
redraw_figures(screen) {
    CheckAngles();
    abi_CMD_G2D_BEGIN_BITMAP(screen, DISPLAY_WIDTH, DISPLAY_HEIGHT, true);
    abi_CMD_G2D_ADD_SPRITE(figures[screen], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
    abi_CMD_G2D_END();
    //Index group affiliation
    for (new n = 0; n < 24; n++) {
        group[n] = assign_group(figures[n])
    }
    track_position();
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
            new groupCurrent = position[cube][face][0];
            new groupLeft = position[leftCube][leftFace][0];
            new groupTop = position[topCube][topFace][0];
            new groupDiagonal = position[diagonalCube][diagonalFace][0];
            printf("Cube : %d\n", cube);
            printf("Face : %d\n", face);
            printf("Figure : %d\n", figures[face]);
            printf("Correct Group: %d\n", group[face]);
            printf("Current Group: %d\n", groupCurrent);
            printf("\n--------------------------------------------\n");
            new tempFigure = figures[cube];
            if ((groupCurrent == groupLeft) && (groupCurrent == groupTop) && (groupCurrent == groupDiagonal)) {
                figures[cube] = 25;
                redraw_figures(cube);
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