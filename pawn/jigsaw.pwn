#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define TEXT_SIZE 28
#define BACKGROUND 24

#define SET_0_COMPLETE 25
#define SET_1_COMPLETE 26
#define SET_2_COMPLETE 27
#define SET_3_COMPLETE 28
#define SET_4_COMPLETE 29
#define SET_5_COMPLETE 30

new figures[24];
//position[cube][face][group]
new position[8][3][6];
new score = 0;
new countCompleted = 0;
new countMoves = 0;

ONTICK() {
    CheckAngles();
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
        if ((abi_cubeN == 0) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[0], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 0) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[1], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 0) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[2], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 1) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[3], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 1) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[4], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 1) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[5], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 2) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[6], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 2) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[7], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 2) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[8], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 3) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[9], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 3) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[10], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 3) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[11], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 4) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[12], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 4) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[13], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 4) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[14], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 5) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[15], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 5) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[16], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 5) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[17], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 6) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[18], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 6) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[19], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 6) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[20], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 7) && (screen == 0)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[21], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 7) && (screen == 1)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[22], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 7) && (screen == 2)) {
            draw_background(screen);
            abi_CMD_G2D_ADD_SPRITE(figures[23], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        abi_CMD_G2D_END();
    }
}
ON_CMD_NET_RX(const pkt[]) {}

ON_LOAD_GAME_DATA() {}

ON_INIT() {
    initialize();
}
ON_CHECK_ROTATE() {
    countMoves++;
}

initialize(){
  for (new n = 0; n < 12; n++) {
        figures[n] = n;
    }
    for (new n = 0; n < 12; n++) {
        figures[n + 12] = n;
    }
    track_position();  
}

init_variables_3_sets() {
    for (new n = 0; n < 12; n++) {
        figures[n] = n;
    }
    for (new n = 0; n < 12; n++) {
        figures[n + 12] = n;
    }
    //Shuffle the array
    for (new n = 0; n < 24; n++) {
        new rand = Random(0, 23);
        swap_slots(figures, n, rand);
    }
    track_position();
}

init_variables_4_sets() {
    for (new n = 0; n < 16; n++) {
        figures[n] = n;
    }
    for (new n = 0; n < 8; n++) {
        figures[n + 16] = n;
    }
    //Shuffle the array
    for (new n = 0; n < 24; n++) {
        new rand = Random(0, 23);
        swap_slots(figures, n, rand);
    }
    track_position();
}

init_variables_5_sets() {
    for (new n = 0; n < 20; n++) {
        figures[n] = n;
    }
    for (new n = 0; n < 4; n++) {
        figures[n + 20] = n;
    }
    //Shuffle the array
    for (new n = 0; n < 24; n++) {
        new rand = Random(0, 23);
        swap_slots(figures, n, rand);
    }
    track_position();
}

init_variables_6_sets() {
    for (new n = 0; n < 24; n++) {
        figures[n] = n;
    }
    //Shuffle the array
    for (new n = 0; n < 24; n++) {
        new rand = Random(0, 23);
        swap_slots(figures, n, rand);
    }
    track_position();
}

//Tracks group affiliation of the figures on the cube coordinates.
track_position() {
    //position[cube][face][group]
    position[0][0][0] = assign_group(figures[0]);
    position[0][1][0] = assign_group(figures[1]);
    position[0][2][0] = assign_group(figures[2]);
    position[1][0][0] = assign_group(figures[3]);
    position[1][1][0] = assign_group(figures[4]);
    position[1][2][0] = assign_group(figures[5]);
    position[2][0][0] = assign_group(figures[6]);
    position[2][1][0] = assign_group(figures[7]);
    position[2][2][0] = assign_group(figures[8]);
    position[3][0][0] = assign_group(figures[9]);
    position[3][1][0] = assign_group(figures[10]);
    position[3][2][0] = assign_group(figures[11]);
    position[4][0][0] = assign_group(figures[12]);
    position[4][1][0] = assign_group(figures[13]);
    position[4][2][0] = assign_group(figures[14]);
    position[5][0][0] = assign_group(figures[15]);
    position[5][1][0] = assign_group(figures[16]);
    position[5][2][0] = assign_group(figures[17]);
    position[6][0][0] = assign_group(figures[18]);
    position[6][1][0] = assign_group(figures[19]);
    position[6][2][0] = assign_group(figures[20]);
    position[7][0][0] = assign_group(figures[21]);
    position[7][1][0] = assign_group(figures[22]);
    position[7][2][0] = assign_group(figures[23]);
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
        abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
        abi_CMD_G2D_ADD_SPRITE(BACKGROUND, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        abi_CMD_G2D_END();
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
            /*printf("Cube : %d\n", cube);
            printf("Face : %d\n", face);
            printf("Figure : %d\n", figures[face]);
            printf("Group: %d\n", groupCurrent);
            printf("\n--------------------------------------------\n");*/
            new tempFigure = figures[cube];
            if ((groupCurrent == groupLeft) && (groupCurrent == groupTop) && (groupCurrent == groupDiagonal)) {
                countCompleted++;
                switch (groupCurrent) {
                    case 0 :  {
                        for (new n = 0; n < 24; n++) {
                            figures[n] = SET_0_COMPLETE;
                        }
                    }
                    case 1 :  {
                        for (new n = 0; n < 24; n++) {
                            figures[n] = SET_1_COMPLETE;
                        }
                    }
                    case 2 :  {
                        for (new n = 0; n < 24; n++) {
                            figures[n] = SET_2_COMPLETE;
                        }
                    }
                    case 3 :  {
                        for (new n = 0; n < 24; n++) {
                            figures[n] = SET_3_COMPLETE;
                        }
                    }
                    case 4 :  {
                        for (new n = 0; n < 24; n++) {
                            figures[n] = SET_4_COMPLETE;
                        }
                    }
                    case 5 :  {
                        for (new n = 0; n < 24; n++) {
                            figures[n] = SET_5_COMPLETE;
                        }
                    }
                }
                reset();
                return;
            }
        }
    }
}

reset() {
    RENDER();
    delay();
    for (new n = 0; n < 24; n++) {
        figures[n] = BACKGROUND;
    }
    if (countCompleted <= 2) {
        score = score + 100;
    } else if ((countCompleted > 2) && (countCompleted <= 5)) {
        score = score + 300;
    } else if ((countCompleted > 5) && (countCompleted <= 8)) {
        score = score + 600;
    } else if (countCompleted > 8) {
        score = score + 1000;
    }
    score = score - (countMoves * 5);
    countMoves = 0;
    CheckAngles();
    for (new screen = 0; screen < 3; screen++) {
        abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
        draw_background(screen);
        abi_CMD_TEXT_ITOA(score, 0, 120, 120, TEXT_SIZE, newAngles[screen], TEXT_ALIGN_CENTER, 255, 255, 255);
        abi_CMD_REDRAW(screen);
        abi_CMD_G2D_END();
    }
    delay();
    if (countCompleted <= 2) {
        init_variables_3_sets();
    } else if ((countCompleted > 2) && (countCompleted <= 5)) {
        init_variables_4_sets();
    } else if ((countCompleted > 5) && (countCompleted <= 8)) {
        init_variables_5_sets();
    } else if (countCompleted > 8) {
        init_variables_6_sets();
    }
}

swap_slots(figures[], n, rand) {
    new temp = figures[rand];
    figures[rand] = figures[n];
    figures[n] = temp;
}

delay() {
    for (new n = 0; n < 90000000; n++) {
        new x = 1 + 1;
    }
}