#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define CAT 0
#define DOG 1
#define MOUSE 2
#define PIG 3
#define HEN 4
#define RABBIT 5
#define HORSE 6
#define COW 7
#define FISH 8
#define CHICKEN 9
#define STEAK 10
#define CHEESE 11
#define MILK 12
#define SAUSAGE 13
#define WORM 14
#define APPLE 15
#define SUGAR 16
#define CARROT 17
#define SALAD 18
#define SEEDS 19
#define GRASS 20
#define HAY 21
#define ENERGYDRINK 22
#define TRASH 23
#define SPIDERNET 24
#define ROTTENMEAT 25
#define ROTTENSALAD 26

#define TEXT_SIZE       8

new dairy_meats[7] = [FISH, CHICKEN, STEAK, CHEESE, MILK, SAUSAGE, WORM];

new veggies[7] = [APPLE, SUGAR, CARROT, SALAD, SEEDS, GRASS, HAY];

new bad_stuff[5] = [ENERGYDRINK, TRASH, SPIDERNET, ROTTENMEAT, ROTTENSALAD];

new foods[8];

ONTICK() {
    // Set anchors
    new anchorTopCube = abi_bottomCubeN(0, 0);
    new anchorTopFace = abi_bottomFaceN(0, 0);
    new anchorRightCube = abi_bottomCubeN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0));
    new anchorRightFace = abi_bottomFaceN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0));
    new anchorLeftCube = abi_topCubeN(abi_rightCubeN(0, 0), abi_rightFaceN(0, 0));
    new anchorLeftFace = abi_topFaceN(abi_rightCubeN(0, 0), abi_rightFaceN(0, 0));
    new anchorOppositeCube = abi_bottomCubeN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace));
    new anchorOppositeFace = abi_bottomFaceN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace));
    
    CheckAngles();

    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        abi_CMD_FILL(0, 0, 0);
        // TODO: This if/else is a disgrace, but I don't know a better solution :D
        // Render animals and food
        if ((abi_cubeN == 0) && (screenI == 0)) {
            abi_CMD_BITMAP(CAT, 120, 120, newAngles[screenI], MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(0, 0) && screenI == abi_leftFaceN(0, 0)) {
            abi_CMD_BITMAP(DOG, 120, 120, newAngles[screenI], MIRROR_BLANK);
        } else if ((abi_cubeN == anchorRightCube) && (screenI == anchorRightFace)) {
            abi_CMD_BITMAP(MOUSE, 120, 120, newAngles[screenI] + 180, MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(anchorRightCube, anchorRightFace) && screenI == abi_leftFaceN(anchorRightCube, anchorRightFace)) {
            abi_CMD_BITMAP(PIG, 120, 120, newAngles[screenI] + 180, MIRROR_BLANK);
        } else if ((abi_cubeN == anchorOppositeCube) && (screenI == anchorOppositeFace)) {
            abi_CMD_BITMAP(HEN, 120, 120, newAngles[screenI] + 90, MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(anchorOppositeCube, anchorOppositeFace) && screenI == abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)) {
            abi_CMD_BITMAP(RABBIT, 120, 120, newAngles[screenI] + 90, MIRROR_BLANK);
        } else if ((abi_cubeN == anchorLeftCube) && (screenI == anchorLeftFace)) {
            abi_CMD_BITMAP(HORSE, 120, 120, newAngles[screenI] + 270, MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(anchorLeftCube, anchorLeftFace) && screenI == abi_leftFaceN(anchorLeftCube, anchorLeftFace)) {
            abi_CMD_BITMAP(COW, 120, 120, newAngles[screenI] + 270, MIRROR_BLANK);
        } else if (abi_cubeN == abi_topCubeN(0, 0) && screenI == abi_topFaceN(0, 0)) {
            abi_CMD_BITMAP(foods[0], 120, 120, newAngles[screenI], MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0)) && screenI == abi_leftFaceN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0))) {
            abi_CMD_BITMAP(foods[1], 120, 120, newAngles[screenI], MIRROR_BLANK);            
        } else if (abi_cubeN == abi_topCubeN(anchorRightCube, anchorRightFace) && screenI == abi_topFaceN(anchorRightCube, anchorRightFace)) {
            abi_CMD_BITMAP(foods[2], 120, 120, newAngles[screenI] + 180, MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace))) {
            abi_CMD_BITMAP(foods[3], 120, 120, newAngles[screenI] + 180, MIRROR_BLANK);
        } else if (abi_cubeN == abi_topCubeN(anchorOppositeCube, anchorOppositeFace) && screenI == abi_topFaceN(anchorOppositeCube, anchorOppositeFace)) {
            abi_CMD_BITMAP(foods[4], 120, 120, newAngles[screenI] + 90, MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorOppositeCube, anchorOppositeFace), abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorOppositeCube, anchorOppositeFace), abi_leftFaceN(anchorOppositeCube, anchorOppositeFace))) {
            abi_CMD_BITMAP(foods[5], 120, 120, newAngles[screenI] + 90, MIRROR_BLANK);
        } else if (abi_cubeN == abi_topCubeN(anchorLeftCube, anchorLeftFace) && screenI == abi_topFaceN(anchorLeftCube, anchorLeftFace)) {
            abi_CMD_BITMAP(foods[6], 120, 120, newAngles[screenI] + 270, MIRROR_BLANK);
        } else if (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorLeftCube, anchorLeftFace), abi_leftFaceN(anchorLeftCube, anchorLeftFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorLeftCube, anchorLeftFace), abi_leftFaceN(anchorLeftCube, anchorLeftFace))) {
            abi_CMD_BITMAP(foods[7], 120, 120, newAngles[screenI] + 270, MIRROR_BLANK);
        } else {
            abi_CMD_FILL(0, 0, 0);
        }
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
ON_INIT() {
    draw_foods();
}
ON_CHECK_ROTATE() {}

draw_foods() {
    for (new i = 0; i <= 7; i++) {
        if (i == 7) {
            foods[i] = bad_stuff[random(5)];
        } else if ((i % 2) == 0) {
            foods[i] = dairy_meats[random(7)];
        } else if ((i % 2) != 0) {
            foods[i] = veggies[random(7)];
        }
    }
}
