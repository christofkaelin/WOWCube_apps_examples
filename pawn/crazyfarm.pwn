#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "topology.pwn"
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
#define CURRENT_SCORE 25
#define HIGHSCORE_GOLD 26
#define HIGHSCORE_SILVER 27
#define HIGHSCORE_BRONZE 28
#define ARROW_CURVED 29
#define ARROW_STRAIGHT 30
#define HEALTH_CRITICAL 31
#define HEALTH_LOW 32
#define HEALTH_HIGH 33
#define HEALTH_FULL 34

#define TEXT_SIZE 8

#define CMD_SEND_ITEM P2P_CMD_BASE_SCRIPT_1 + 1

new string[4];

new current_score = 0;
new highscore = 10000;
new items[3];
new health[8] = [HEALTH_LOW, HEALTH_LOW, HEALTH_LOW, HEALTH_LOW, HEALTH_LOW, HEALTH_LOW, HEALTH_LOW, HEALTH_LOW];

new highscore_location[2] = [0, 1]
new score_location[2];
new instruction_location[2];
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
    score_location[0] = abi_leftCubeN(highscore_location[0], highscore_location[1]);
    score_location[1] = abi_leftFaceN(highscore_location[0], highscore_location[1]);
    instruction_location[0] = abi_leftCubeN(score_location[0], score_location[1]);
    instruction_location[1] = abi_leftFaceN(score_location[0], score_location[1]);
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
        Topology_FindTopMostModule(1);
        abi_CMD_FILL(7, 54, 14);
        /*if ((abi_cubeN == highscore_location[0]) && (screenI == highscore_location[1])) {
            abi_CMD_BITMAP(HIGHSCORE_GOLD, 120, 120, 180, MIRROR_BLANK);
        } else if ((abi_cubeN == score_location[0]) && (screenI == score_location[1])) {
            strformat(string, sizeof(string), true, "Score: %d", current_score);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 270, TEXT_ALIGN_CENTER, 255, 255, 255);
        } else if ((abi_cubeN == instruction_location[0]) && (screenI == instruction_location[1])) {
            strformat(string, sizeof(string), true, "1x Tap: ");
            abi_CMD_TEXT(string, 0, 230, 160, TEXT_SIZE, 180, TEXT_ALIGN_LEFT_TOP_CORNER, 255, 255, 255);
            strformat(string, sizeof(string), true, " Feed or swap");
            abi_CMD_TEXT(string, 0, 230, 140, TEXT_SIZE, 180, TEXT_ALIGN_LEFT_TOP_CORNER, 255, 255, 255);
            strformat(string, sizeof(string), true, "3x Tap: ");
            abi_CMD_TEXT(string, 0, 230, 110, TEXT_SIZE, 180, TEXT_ALIGN_LEFT_TOP_CORNER, 255, 255, 255);
            strformat(string, sizeof(string), true, " new foods");
            abi_CMD_TEXT(string, 0, 230, 90, TEXT_SIZE, 180, TEXT_ALIGN_LEFT_TOP_CORNER, 255, 255, 255);
        } else if ((abi_cubeN == exit_location[0]) && (screenI == exit_location[1])) {
            abi_CMD_BITMAP(HIGHSCORE_BRONZE, 120, 120, 180, MIRROR_BLANK);
        } else if ((abi_cubeN == cat_location[0]) && (screenI == cat_location[1])) {
            abi_CMD_BITMAP(CAT, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(health[CAT], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == dog_location[0] && screenI == dog_location[1]) {
            abi_CMD_BITMAP(DOG, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(health[DOG], 120, 120, 90, MIRROR_BLANK);
        } else if (abi_cubeN == mouse_location[0] && screenI == mouse_location[1]) {
            abi_CMD_BITMAP(MOUSE, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(health[MOUSE], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == pig_location[0] && screenI == pig_location[1]) {
            abi_CMD_BITMAP(PIG, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(health[PIG], 120, 120, 90, MIRROR_BLANK);
        } else if (abi_cubeN == chicken_location[0] && screenI == chicken_location[1]) {
            abi_CMD_BITMAP(CHICKEN, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(health[CHICKEN], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == bunny_location[0] && screenI == bunny_location[1]) {
            abi_CMD_BITMAP(BUNNY, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(health[BUNNY], 120, 120, 90, MIRROR_BLANK);
        } else if (abi_cubeN == cow_location[0] && screenI == cow_location[1]) {
            abi_CMD_BITMAP(COW, 120, 120, 180, MIRROR_BLANK);
            abi_CMD_BITMAP(health[COW], 120, 120, 180, MIRROR_BLANK);
        } else if (abi_cubeN == horse_location[0] && screenI == horse_location[1]) {
            abi_CMD_BITMAP(HORSE, 120, 120, 90, MIRROR_BLANK);
            abi_CMD_BITMAP(health[HORSE], 120, 120, 90, MIRROR_BLANK);
        } else {
            if (items[screenI] != 0) {
                abi_CMD_BITMAP(items[screenI], 120, 120, get_item_angle(screenI), MIRROR_BLANK);
            }
            if (
                (abi_cubeN == topology_TopmostModule) &&
                (screenI == topology_TopmostScreen)
            ) {
                if (is_inventory_item(screenI)) {
                    abi_CMD_BITMAP(ARROW_CURVED, 120, 120, 270, MIRROR_BLANK);
                } else {
                    abi_CMD_BITMAP(ARROW_STRAIGHT, 120, 120, get_item_angle(screenI), MIRROR_BLANK);
                }
                if (abi_MTD_GetTapsCount() == 1) {
                    use_item(screenI);
                }
                if (abi_MTD_GetTapsCount() == 3) {
                    draw_items(Random(0, 100));
                }
            }
        }*/
        strformat(string, sizeof(string), true, "Module: %d", topology_TopmostModules[0]);
        abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 270, TEXT_ALIGN_CENTER, 255, 255, 255);
        abi_CMD_REDRAW(screenI);
    }
    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {
    switch (abi_ByteN(pkt, 4)) {
        case CMD_SEND_ITEM:  {
            health[abi_ByteN(pkt, 8)] = abi_ByteN(pkt, 9);
            current_score = abi_ByteN(pkt, 10);
        }
    }
}
ON_LOAD_GAME_DATA() {}
ON_INIT() {
    draw_items(abi_cubeN % 4);
}
ON_CHECK_ROTATE() {}

draw_items(category) {
    if (category != 0 || category != 4) {
        category = category % 4;
        new droppedItem = Random(0, 3);
        items[0] = ((droppedItem + 1) % 4) + 8 + (category * 4);
        items[1] = ((droppedItem + 2) % 4) + 8 + (category * 4);
        items[2] = ((droppedItem + 3) % 4) + 8 + (category * 4);
    } else {
        items[0] = 24;
        items[1] = 24;
        items[2] = 24;
    }
}

get_item_angle(face) {
    if (
        ((abi_leftCubeN(abi_cubeN, face) == cat_location[0]) && (abi_leftFaceN(abi_cubeN, face) == cat_location[1])) ||
        ((abi_leftCubeN(abi_cubeN, face) == mouse_location[0]) && (abi_leftFaceN(abi_cubeN, face) == mouse_location[1])) ||
        ((abi_leftCubeN(abi_cubeN, face) == chicken_location[0]) && (abi_leftFaceN(abi_cubeN, face) == chicken_location[1])) ||
        ((abi_leftCubeN(abi_cubeN, face) == cow_location[0]) && (abi_leftFaceN(abi_cubeN, face) == cow_location[1]))
    ) {
        return 270;
    } else if (
        ((abi_topCubeN(abi_cubeN, face) == dog_location[0]) && (abi_topFaceN(abi_cubeN, face) == dog_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == pig_location[0]) && (abi_topFaceN(abi_cubeN, face) == pig_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == bunny_location[0]) && (abi_topFaceN(abi_cubeN, face) == bunny_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == horse_location[0]) && (abi_topFaceN(abi_cubeN, face) == horse_location[1]))
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

send_item(animal, health, score) {
    new data[2];
    data[0] = ((CMD_SEND_ITEM & 0xFF));
    data[1] = ((animal & 0xFF) | ((health & 0xFF) << 8) | ((score & 0xFF) << 16));

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data);
}

feed_animal(animal, healthpoints, points) {
    health[animal] = health[animal] + healthpoints;
    if (health[animal] < HEALTH_CRITICAL) {
        health[animal] = HEALTH_CRITICAL;
    } else if (health[animal] > HEALTH_FULL) {
        health[animal] = HEALTH_FULL;
    }
    current_score = current_score + points;
    if (current_score < 0) {
        current_score = 0;
    }
    send_item(animal, health[animal], current_score);
}

is_inventory_item(face) {
    return !(
        ((abi_leftCubeN(abi_cubeN, face) == cat_location[0]) && (abi_leftFaceN(abi_cubeN, face) == cat_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == dog_location[0]) && (abi_topFaceN(abi_cubeN, face) == dog_location[1])) ||
        ((abi_leftCubeN(abi_cubeN, face) == mouse_location[0]) && (abi_leftFaceN(abi_cubeN, face) == mouse_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == pig_location[0]) && (abi_topFaceN(abi_cubeN, face) == pig_location[1])) ||
        ((abi_leftCubeN(abi_cubeN, face) == chicken_location[0]) && (abi_leftFaceN(abi_cubeN, face) == chicken_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == bunny_location[0]) && (abi_topFaceN(abi_cubeN, face) == bunny_location[1])) ||
        ((abi_leftCubeN(abi_cubeN, face) == cow_location[0]) && (abi_leftFaceN(abi_cubeN, face) == cow_location[1])) ||
        ((abi_topCubeN(abi_cubeN, face) == horse_location[0]) && (abi_topFaceN(abi_cubeN, face) == horse_location[1]))
    );
}

use_item(face) {
    new selected_item = items[face];
    if (is_inventory_item(face)) {
        move_items(face);
    } else {
        items[face] = 0;
    }
    if ((abi_leftCubeN(abi_cubeN, face) == cat_location[0]) && (abi_leftFaceN(abi_cubeN, face) == cat_location[1])) {
        if (selected_item == FISH) {
            feed_animal(CAT, 1, 20);
        } else if (selected_item == MILK) {
            feed_animal(CAT, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(CAT, -1, -10);
        }
    } else if ((abi_topCubeN(abi_cubeN, face) == dog_location[0]) && (abi_topFaceN(abi_cubeN, face) == dog_location[1])) {
        if (selected_item == BONE) {
            feed_animal(DOG, 1, 20);
        } else if (selected_item == STEAK) {
            feed_animal(DOG, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(DOG, -1, -10);
        }
    } else if ((abi_leftCubeN(abi_cubeN, face) == mouse_location[0]) && (abi_leftFaceN(abi_cubeN, face) == mouse_location[1])) {
        if (selected_item == CHEESE) {
            feed_animal(MOUSE, 1, 20);
        } else if (selected_item == SEEDS) {
            feed_animal(MOUSE, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(MOUSE, -1, -10);
        }
    } else if ((abi_topCubeN(abi_cubeN, face) == pig_location[0]) && (abi_topFaceN(abi_cubeN, face) == pig_location[1])) {
        if (selected_item != MUSHROOM && selected_item != ROTTEN_STEAK && selected_item != ROTTEN_LETTUCE && selected_item != ANIMAL_EXCREMENTS) {
            feed_animal(PIG, 1, 10);
        } else {
            feed_animal(PIG, -1, -10);
        }
    } else if ((abi_leftCubeN(abi_cubeN, face) == chicken_location[0]) && (abi_leftFaceN(abi_cubeN, face) == chicken_location[1])) {
        if (selected_item == WORM) {
            feed_animal(CHICKEN, 1, 20);
        } else if (selected_item == SEEDS) {
            feed_animal(CHICKEN, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(CHICKEN, -1, -10);
        }
    } else if ((abi_topCubeN(abi_cubeN, face) == bunny_location[0]) && (abi_topFaceN(abi_cubeN, face) == bunny_location[1])) {
        if (selected_item == CARROT) {
            feed_animal(BUNNY, 1, 20);
        } else if (selected_item == HAY) {
            feed_animal(BUNNY, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(BUNNY, -1, -10);
        }
    } else if ((abi_leftCubeN(abi_cubeN, face) == cow_location[0]) && (abi_leftFaceN(abi_cubeN, face) == cow_location[1])) {
        if (selected_item == HAY) {
            feed_animal(COW, 1, 20);
        } else if (selected_item == APPLE) {
            feed_animal(COW, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(COW, -1, -10);
        }
    } else if ((abi_topCubeN(abi_cubeN, face) == horse_location[0]) && (abi_topFaceN(abi_cubeN, face) == horse_location[1])) {
        if (selected_item == SUGAR) {
            feed_animal(HORSE, 1, 20);
        } else if (selected_item == APPLE) {
            feed_animal(HORSE, 1, 10);
        } else if (selected_item == MUSHROOM || selected_item == ROTTEN_STEAK || selected_item == ROTTEN_LETTUCE || selected_item == ANIMAL_EXCREMENTS) {
            feed_animal(HORSE, -1, -10);
        }
    }
}
