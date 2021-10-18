#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define TEXT_SIZE 14
#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
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
    init_variables_test();
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
    track_position();
}
//Fake init for test purposes
init_variables_test() {
    figures[0] = 0;
    figures[1] = 1;
    figures[2] = 2;
    figures[3] = 3;
    figures[4] = 4;
    figures[5] = 5;
    figures[6] = 6;
    figures[7] = 7;
    figures[8] = 0;
    figures[9] = 1;
    figures[10] = 2;
    figures[11] = 3;
    figures[12] = 4;
    figures[13] = 5;
    figures[14] = 6;
    figures[15] = 7;
    figures[16] = 0;
    figures[17] = 1;
    figures[18] = 2;
    figures[19] = 3;
    figures[20] = 4;
    figures[21] = 5;
    figures[22] = 6;
    figures[23] = 7;

    //Shuffle the array
    for (new n = 0; n < 24; n++) {
        new rand = random(24);
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
        abi_CMD_G2D_BEGIN_BITMAP(screen, DISPLAY_WIDTH, DISPLAY_HEIGHT, true);
        abi_CMD_G2D_ADD_SPRITE(BACKGROUND, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        abi_CMD_G2D_END();
    }
}
render_cubes() {
    switch (abi_cubeN) {
        case 0 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeZero[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 1 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeOne[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 2 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeTwo[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 3 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeThree[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 4 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeFour[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 5 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeFive[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 6 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeSix[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
        case 7 :  {
            for (new screen = 0; screen < 3; screen++) {
                abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
                draw_background(cubeSeven[screen]);
                draw_figures(screen);
                abi_CMD_G2D_END();
            }
        }
    }
}

redraw_figures() {
    for (new n = 0; n < 24; n++) {
        if (figures[n] == 25) {
            figures[n] = random(24);
        }
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
            /*printf("Cube : %d\n", cube);
            printf("Face : %d\n", face);
            printf("Figure : %d\n", figures[face]);
            printf("Group: %d\n", groupCurrent);
            printf("\n--------------------------------------------\n");*/
            new tempFigure = figures[cube];
            if ((groupCurrent == groupLeft) && (groupCurrent == groupTop) && (groupCurrent == groupDiagonal)) {
                score = score + 100;
                switch (groupCurrent) {
                    case 0 :  {
                        for (new n = 0; n < 24; n++) {
                            if ((figures[n] == 0) || (figures[n] == 1) || (figures[n] == 2) || (figures[n] == 3)) {
                                figures[n] = SET_0_COMPLETE;
                            }
                        }
                    }
                    case 1 :  {
                        for (new n = 0; n < 24; n++) {
                            if ((figures[n] == 4) || (figures[n] == 5) || (figures[n] == 6) || (figures[n] == 7)) {
                                figures[n] = SET_1_COMPLETE;
                            }
                        }
                    }
                    case 2 :  {
                        for (new n = 0; n < 24; n++) {
                            if ((figures[n] == 8) || (figures[n] == 9) || (figures[n] == 10) || (figures[n] == 11)) {
                                figures[n] = SET_2_COMPLETE;
                            }
                        }
                    }
                    case 3 :  {
                        for (new n = 0; n < 24; n++) {
                            if ((figures[n] == 12) || (figures[n] == 13) || (figures[n] == 14) || (figures[n] == 15)) {
                                figures[n] = SET_3_COMPLETE;
                            }
                        }
                    }
                    case 4 :  {
                        for (new n = 0; n < 24; n++) {
                            if ((figures[n] == 16) || (figures[n] == 17) || (figures[n] == 18) || (figures[n] == 19)) {
                                figures[n] = SET_4_COMPLETE;
                            }
                        }
                    }
                    case 5 :  {
                        for (new n = 0; n < 24; n++) {
                            if ((figures[n] == 20) || (figures[n] == 21) || (figures[n] == 22) || (figures[n] == 23)) {
                                figures[n] = SET_5_COMPLETE;
                            }
                        }
                    }
                }
                //reset();
                return;
            }
        }
    }
}

reset() {
    new ref = abi_GetTime() + 3000;
    new now = 0;
    while (ref > now) {
        now = abi_GetTime();
    }
    for (new n = 0; n < 24; n++) {
        figures[n] = BACKGROUND;
    }
    for (new screen = 0; screen < FACES_MAX; screen++) {
        new string[4];
        strformat(string, sizeof(string), true, "Score: %d", score);
        abi_CMD_TEXT(string, 0, 30, 60, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
    }
}
swap_slots(figures[], n, rand) {
    new temp = figures[rand];
    figures[rand] = figures[n];
    figures[n] = temp;
}