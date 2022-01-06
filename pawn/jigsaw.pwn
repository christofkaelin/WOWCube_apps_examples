#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define FONT_SIZE 10

#define SET_0_COMPLETE 25
#define SET_1_COMPLETE 26
#define SET_2_COMPLETE 27
#define SET_3_COMPLETE 28
#define SET_4_COMPLETE 29
#define SET_5_COMPLETE 30

new background = 24;
new figures[24];
new position[8][3][6]; //position[cube][face][group]
new score = 100;
new countCompleted = 0;
new countMoves = 0;
new count_delay;
new bool:is_in_reset = false;

ONTICK() {
    CheckAngles();
    check_match();
    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}

ON_PHYSICS_TICK() {
    if (is_in_reset) {
        count_delay++;
        reset();
    }
}

RENDER() {
    CheckAngles();
    for (new screen = 0; screen < 3; screen++) {
        abi_CMD_G2D_BEGIN_DISPLAY(screen, true);
        if ((abi_cubeN == 0) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[0], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 0) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[1], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 0) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[2], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 1) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[3], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 1) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[4], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 1) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[5], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 2) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[6], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 2) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[7], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 2) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[8], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 3) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[9], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 3) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[10], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 3) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[11], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 4) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[12], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 4) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[13], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 4) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[14], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 5) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[15], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 5) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[16], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 5) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[17], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 6) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[18], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 6) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[19], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 6) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[20], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if ((abi_cubeN == 7) && (screen == 0)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[21], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 7) && (screen == 1)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[22], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        } else if ((abi_cubeN == 7) && (screen == 2)) {
            abi_CMD_G2D_ADD_SPRITE(background, false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(figures[23], false, 120, 120, 0xFF, 0, newAngles[screen], MIRROR_BLANK);
        }
        if (!is_in_reset) {
            draw_HUD(screen);
        }
        abi_CMD_G2D_END();        
    }
}
ON_CMD_NET_RX(const pkt[]) {}

ON_LOAD_GAME_DATA() {}

ON_INIT() {
    init_variables_3_sets_1()
}
ON_CHECK_ROTATE() {
    countMoves++;
    score = score - 5;
}


init_variables_3_sets_1() {
    figures[0] = 1;
    figures[1] = 5;
    figures[2] = 3;
    figures[3] = 2;
    figures[4] = 6;
    figures[5] = 11;
    figures[6] = 0;
    figures[7] = 10;
    figures[8] = 8;
    figures[9] = 9;
    figures[10] = 4;
    figures[11] = 7;
    figures[12] = 0;
    figures[13] = 10;
    figures[14] = 8;
    figures[15] = 9;
    figures[16] = 4;
    figures[17] = 7;
    figures[18] = 3;
    figures[19] = 2;
    figures[20] = 6;
    figures[21] = 11;
    figures[22] = 4;
    figures[23] = 7;

    track_position();
}

init_variables_3_sets_2() {
    figures[0] = 3;
    figures[1] = 10;
    figures[2] = 11;
    figures[3] = 6;
    figures[4] = 2;
    figures[5] = 1;
    figures[6] = 8;
    figures[7] = 7;
    figures[8] = 0;
    figures[9] = 9;
    figures[10] = 5;
    figures[11] = 4;
    figures[12] = 7;
    figures[13] = 0;
    figures[14] = 9;
    figures[15] = 10;
    figures[16] = 11;
    figures[17] = 6;
    figures[18] = 2;
    figures[19] = 7;
    figures[20] = 0;
    figures[21] = 9;
    figures[22] = 5;
    figures[23] = 4;

    track_position();
}

init_variables_3_sets_3() {
    figures[0] = 8;
    figures[1] = 1;
    figures[2] = 7;
    figures[3] = 4;
    figures[4] = 9;
    figures[5] = 11;
    figures[6] = 6;
    figures[7] = 2;
    figures[8] = 10;
    figures[9] = 5;
    figures[10] = 0;
    figures[11] = 3;
    figures[12] = 8;
    figures[13] = 1;
    figures[14] = 7;
    figures[15] = 4;
    figures[16] = 9;
    figures[17] = 2;
    figures[18] = 10;
    figures[19] = 8;
    figures[20] = 1;
    figures[21] = 7;
    figures[22] = 4;
    figures[23] = 9;

    track_position();
}

init_variables_4_sets_1() {
    figures[0] = 3;
    figures[1] = 7;
    figures[2] = 10;
    figures[3] = 4;
    figures[4] = 8;
    figures[5] = 1;
    figures[6] = 9;
    figures[7] = 15;
    figures[8] = 13;
    figures[9] = 14;
    figures[10] = 2;
    figures[11] = 0;
    figures[12] = 11;
    figures[13] = 6;
    figures[14] = 5;
    figures[15] = 12;
    figures[16] = 10;
    figures[17] = 4;
    figures[18] = 8;
    figures[19] = 1;
    figures[20] = 2;
    figures[21] = 0;
    figures[22] = 11;
    figures[23] = 6;

    track_position();
}

init_variables_4_sets_2() {
    figures[0] = 1;
    figures[1] = 10;
    figures[2] = 14;
    figures[3] = 6;
    figures[4] = 12;
    figures[5] = 4;
    figures[6] = 5;
    figures[7] = 13;
    figures[8] = 11;
    figures[9] = 7;
    figures[10] = 2;
    figures[11] = 9;
    figures[12] = 3;
    figures[13] = 0;
    figures[14] = 15;
    figures[15] = 8;
    figures[16] = 9;
    figures[17] = 3;
    figures[18] = 0;
    figures[19] = 15;
    figures[20] = 8;
    figures[21] = 2;
    figures[22] = 9;
    figures[23] = 3;

    track_position();
}

init_variables_4_sets_3() {
    figures[0] = 3;
    figures[1] = 12;
    figures[2] = 8;
    figures[3] = 10;
    figures[4] = 9;
    figures[5] = 5;
    figures[6] = 7;
    figures[7] = 13;
    figures[8] = 1;
    figures[9] = 15;
    figures[10] = 2;
    figures[11] = 14;
    figures[12] = 11;
    figures[13] = 6;
    figures[14] = 4;
    figures[15] = 0;
    figures[16] = 14;
    figures[17] = 11;
    figures[18] = 6;
    figures[19] = 4;
    figures[20] = 0;
    figures[21] = 9;
    figures[22] = 5;
    figures[23] = 7;

    track_position();
}

init_variables_5_sets_1() {
    figures[0] = 9;
    figures[1] = 12;
    figures[2] = 10;
    figures[3] = 14;
    figures[4] = 7;
    figures[5] = 0;
    figures[6] = 5;
    figures[7] = 2;
    figures[8] = 13;
    figures[9] = 6;
    figures[10] = 1;
    figures[11] = 17;
    figures[12] = 3;
    figures[13] = 4;
    figures[14] = 19;
    figures[15] = 16;
    figures[16] = 15;
    figures[17] = 11;
    figures[18] = 18;
    figures[19] = 8;
    figures[20] = 13;
    figures[21] = 6;
    figures[22] = 1;
    figures[23] = 17;

    track_position();
}

init_variables_5_sets_2() {
    figures[0] = 3;
    figures[1] = 15;
    figures[2] = 10;
    figures[3] = 7;
    figures[4] = 2;
    figures[5] = 1;
    figures[6] = 19;
    figures[7] = 18;
    figures[8] = 17;
    figures[9] = 12;
    figures[10] = 16;
    figures[11] = 9;
    figures[12] = 4;
    figures[13] = 5;
    figures[14] = 8;
    figures[15] = 0;
    figures[16] = 6;
    figures[17] = 13;
    figures[18] = 14;
    figures[19] = 11;
    figures[20] = 19;
    figures[21] = 18;
    figures[22] = 17;
    figures[23] = 12;

    track_position();
}

init_variables_5_sets_3() {
    figures[0] = 3;
    figures[1] = 10;
    figures[2] = 8;
    figures[3] = 6;
    figures[4] = 15;
    figures[5] = 17;
    figures[6] = 9;
    figures[7] = 13;
    figures[8] = 0;
    figures[9] = 12;
    figures[10] = 19;
    figures[11] = 11;
    figures[12] = 2;
    figures[13] = 16;
    figures[14] = 4;
    figures[15] = 7;
    figures[16] = 1;
    figures[17] = 5;
    figures[18] = 18;
    figures[19] = 14;
    figures[20] = 6;
    figures[21] = 15;
    figures[22] = 17;
    figures[23] = 9;

    track_position();
}

init_variables_6_sets_1() {
    figures[0] = 19;
    figures[1] = 8;
    figures[2] = 0;
    figures[3] = 7;
    figures[4] = 13;
    figures[5] = 16;
    figures[6] = 4;
    figures[7] = 5;
    figures[8] = 11;
    figures[9] = 23;
    figures[10] = 21;
    figures[11] = 20;
    figures[12] = 1;
    figures[13] = 10;
    figures[14] = 2;
    figures[15] = 18;
    figures[16] = 22;
    figures[17] = 14;
    figures[18] = 12;
    figures[19] = 9;
    figures[20] = 15;
    figures[21] = 17;
    figures[22] = 6;
    figures[23] = 3;

    track_position();
}

init_variables_6_sets_2() {
    figures[0] = 21;
    figures[1] = 14;
    figures[2] = 23;
    figures[3] = 11;
    figures[4] = 9;
    figures[5] = 1;
    figures[6] = 0;
    figures[7] = 3;
    figures[8] = 6;
    figures[9] = 12;
    figures[10] = 15;
    figures[11] = 4;
    figures[12] = 19;
    figures[13] = 20;
    figures[14] = 16;
    figures[15] = 17;
    figures[16] = 5;
    figures[17] = 18;
    figures[18] = 10;
    figures[19] = 22;
    figures[20] = 13;
    figures[21] = 8;
    figures[22] = 2;
    figures[23] = 7;

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

draw_HUD(screen) {
    switch (newAngles[screen]) {
        case 0 :  {            
            abi_CMD_TEXT_ITOA(score, 0, 200, 220, FONT_SIZE, newAngles[screen], TEXT_ALIGN_CENTER, 255, 255, 255, true);
        }
        case 90 :  {            
            abi_CMD_TEXT_ITOA(score, 0, 20, 200, FONT_SIZE, newAngles[screen], TEXT_ALIGN_CENTER, 255, 255, 255, true);
        }
        case 180 :  {            
            abi_CMD_TEXT_ITOA(score, 0, 40, 20, FONT_SIZE, newAngles[screen], TEXT_ALIGN_CENTER, 255, 255, 255, true);
        }
        case 270 :  {          
            abi_CMD_TEXT_ITOA(score, 0, 220, 40, FONT_SIZE, newAngles[screen], TEXT_ALIGN_CENTER, 255, 255, 255, true);
        }
    }
}

check_match() {
    if (countMoves == 0) {
        return;
    }
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
            new tempFigure = figures[cube];
            if ((groupCurrent == groupLeft) && (groupCurrent == groupTop) && (groupCurrent == groupDiagonal)) {
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
    is_in_reset = true;
    RENDER();

    if (count_delay >= 60) {
        is_in_reset = false;
    }

    if (!is_in_reset) {
        countCompleted++;
        for (new n = 0; n < 24; n++) {
            figures[n] = background;
        }

        if (countCompleted <= 2) {
            score = score + 100;
        } else if ((countCompleted > 2) && (countCompleted <= 5)) {
            score = score + 200;
        } else if ((countCompleted > 5) && (countCompleted <= 8)) {
            score = score + 300;
        } else if (countCompleted > 8) {
            score = score + 500;
        }
        if (countCompleted < 9) {
            switch (countCompleted) {
                case 1 : init_variables_3_sets_2();
                case 2 : init_variables_3_sets_3();
                case 3 :  {
                    background = 31;
                    init_variables_4_sets_1();
                }
                case 4 : init_variables_4_sets_2();

                case 5 : init_variables_4_sets_3();

                case 6 :  {
                    background = 32;
                    init_variables_5_sets_1();
                }
                case 7 : init_variables_5_sets_2();

                case 8 : init_variables_5_sets_3();

            }
        } else {
            background = 33;
            if ((countCompleted % 2) == 0) {
                init_variables_6_sets_1();
            } else {
                init_variables_6_sets_2();
            }
        }
        count_delay = 0;
        countMoves = 0;
    }
}