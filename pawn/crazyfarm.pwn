#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define CAT 0
#define DOG 1
#define MOUSE 2
#define PIG 3
#define CHICKEN 4
#define BUNNY 5
#define COW 6
#define HORSE 7
#define HAY 8
#define SEEDS 9
#define SUGAR 10
#define MUSHROOM 11
#define FISH 12
#define WORM 13
#define STEAK 14
#define ROTTEN_STEAK 15
#define LETTUCE 16
#define CARROT 17
#define APPLE 18
#define ROTTEN_LETTUCE 19
#define MILK 20
#define CHEESE 21
#define BONE 22
#define ANIMAL_EXCREMENTS 23
#define RAINBOW 24
#define ARROW 29
#define HEALTH_FULL 30
#define HEALTH_HIGH 31
#define HEALTH_LOW 32
#define HEALTH_CRITICAL 33

#define TEXT_SIZE 8

new string[4];

new score = 0;
new highscore = 10000;
new items[3];
new lives[8] = [HEALTH_CRITICAL, HEALTH_HIGH, HEALTH_HIGH, HEALTH_HIGH, HEALTH_HIGH, HEALTH_HIGH, HEALTH_HIGH, HEALTH_HIGH];

new highscore_location[2] = [0, 1]
new score_location[2];
new mute_location[2];
new exit_location[2];
new cat_location[2] = [0, 0];
new dog_location[2];
new mouse_location[2];
new pig_location[2];
new chicken_location[2];
new bunny_location[2];
new cow_location[2];
new horse_location[2];

ONTICK() {
    // Animal locations
    score_location[0] = abi_leftCubeN(highscore_location[0], highscore_location[1]);
    score_location[1] = abi_leftFaceN(highscore_location[0], highscore_location[1]);
    mute_location[0] = abi_leftCubeN(score_location[0], score_location[1]);
    mute_location[1] = abi_leftFaceN(score_location[0], score_location[1]);
    exit_location[0] = abi_topCubeN(highscore_location[0], highscore_location[1]);
    exit_location[1] = abi_topFaceN(highscore_location[0], highscore_location[1]);
    dog_location[0] = abi_leftCubeN(cat_location[0], cat_location[1]);
    dog_location[1] = abi_leftFaceN(cat_location[0], cat_location[1]);
    mouse_location[0] = abi_bottomCubeN(dog_location[0], dog_location[1]);
    mouse_location[1] = abi_bottomFaceN(dog_location[0], dog_location[1]);
    pig_location[0] = abi_leftCubeN(mouse_location[0], mouse_location[1]);
    pig_location[1] = abi_leftFaceN(mouse_location[0], mouse_location[1]);
    chicken_location[0] = abi_bottomCubeN(pig_location[0], pig_location[1]);
    chicken_location[1] = abi_bottomFaceN(pig_location[0], pig_location[1]);
    bunny_location[0] = abi_leftCubeN(chicken_location[0], chicken_location[1]);
    bunny_location[1] = abi_leftFaceN(chicken_location[0], chicken_location[1]);
    cow_location[0] = abi_bottomCubeN(bunny_location[0], bunny_location[1]);
    cow_location[1] = abi_bottomFaceN(bunny_location[0], bunny_location[1]);
    horse_location[0] = abi_leftCubeN(cow_location[0], cow_location[1]);
    horse_location[1] = abi_leftFaceN(cow_location[0], cow_location[1]);
    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        abi_CMD_FILL(0, 0, 0);
        if ((abi_cubeN == highscore_location[0]) && (screenI == highscore_location[1])) {
            strformat(string, sizeof(string), true, "Best: %d", highscore);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
        } else if ((abi_cubeN == score_location[0]) && (screenI == score_location[1])) {
            strformat(string, sizeof(string), true, "Score: %d", score);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 270, TEXT_ALIGN_CENTER, 255, 255, 255);
        } else if ((abi_cubeN == mute_location[0]) && (screenI == mute_location[1])) {
            strformat(string, sizeof(string), true, "Mute");
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 180, TEXT_ALIGN_CENTER, 255, 255, 255);
        } else if ((abi_cubeN == exit_location[0]) && (screenI == exit_location[1])) {
            strformat(string, sizeof(string), true, "Exit");
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 90, TEXT_ALIGN_CENTER, 255, 255, 255);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                abi_exit();
            }
        } else if ((abi_cubeN == cat_location[0]) && (screenI == cat_location[1])) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(CAT, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[CAT], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == dog_location[0] && screenI == dog_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(DOG, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[DOG], 120, 120, 90, MIRROR_BLANK);
        } else if (abi_cubeN == mouse_location[0] && screenI == mouse_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(MOUSE, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[MOUSE], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == pig_location[0] && screenI == pig_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(PIG, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[PIG], 120, 120, 90, MIRROR_BLANK);
        } else if (abi_cubeN == chicken_location[0] && screenI == chicken_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(CHICKEN, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[CHICKEN], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == bunny_location[0] && screenI == bunny_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(BUNNY, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[BUNNY], 120, 120, 90, MIRROR_BLANK);
        } else if (abi_cubeN == cow_location[0] && screenI == cow_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(COW, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[COW], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == horse_location[0] && screenI == horse_location[1]) {
            abi_CMD_FILL(7, 54, 14);
            abi_CMD_BITMAP(HORSE, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(lives[HORSE], 120, 120, 90, MIRROR_BLANK);
        } else {
            abi_CMD_BITMAP(items[screenI], 120, 120, get_item_angle(abi_cubeN, screenI), MIRROR_BLANK);
            abi_CMD_BITMAP(ARROW, 120, 120, 270, MIRROR_BLANK);
            if (screenI == abi_MTD_GetTapFace() && abi_MTD_GetTapsCount() >= 1) {
                if (abi_MTD_GetTapsCount() == 1) {
                    feed_animal();
                } else if (abi_MTD_GetTapsCount() == 2) {
                    move_items();
                } else {
                    //TODO: Implement freeze for this cube when player draws new items
                    draw_items(random(100));
                }
            }
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
    draw_items(abi_cubeN % 4);
}
ON_CHECK_ROTATE() {}

draw_items(category) {
    if (category != 0 || category != 4) {
        category = category % 4;
        new droppedItem = random(4);
        items[0] = ((droppedItem + 1) % 4) + 8 + (category * 4);
        items[1] = ((droppedItem + 2) % 4) + 8 + (category * 4);
        items[2] = ((droppedItem + 3) % 4) + 8 + (category * 4);
    } else {
        items[0] = 24;
        items[1] = 24;
        items[2] = 24;
    }
}

get_item_angle(cube, face) {
    if (
        ((abi_leftCubeN(cube, face) == cat_location[0]) && (abi_leftFaceN(cube, face) == cat_location[1])) ||        
        ((abi_leftCubeN(cube, face) == mouse_location[0]) && (abi_leftFaceN(cube, face) == mouse_location[1])) ||        
        ((abi_leftCubeN(cube, face) == chicken_location[0]) && (abi_leftFaceN(cube, face) == chicken_location[1])) ||        
        ((abi_leftCubeN(cube, face) == cow_location[0]) && (abi_leftFaceN(cube, face) == cow_location[1]))
    ) {
        return 270;
    } else if (
        ((abi_topCubeN(cube, face) == dog_location[0]) && (abi_topFaceN(cube, face) == dog_location[1])) ||        
        ((abi_topCubeN(cube, face) == pig_location[0]) && (abi_topFaceN(cube, face) == pig_location[1])) ||        
        ((abi_topCubeN(cube, face) == bunny_location[0]) && (abi_topFaceN(cube, face) == bunny_location[1])) ||        
        ((abi_topCubeN(cube, face) == horse_location[0]) && (abi_topFaceN(cube, face) == horse_location[1]))
    ) {
        return 0;
    } else {
        return 135;
    }
}

move_items() {
    new overflow = items[2];
    items[2] = items[1];
    items[1] = items[0];
    items[0] = overflow;
}

feed_animal() {
    //TODO: Implement animal feed logic.
}
