#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#include "cuberacer/menu.pwn"
#include "cuberacer/game.pwn"

#define DISPLAY_SHADOW  40

/* 
==============================
ASSET CONCEPT
==============================
0-35 MAIN MENU
------------------------------
0-1: LOGO
2: Highscore
3: Start
4: Settings
5: Shop
6-7: Music on/off
8-9: Sound on/off
10: Back
11-15: Credits
16-19: Reserved
20-27: Car seletion 0-7
28-35: Map selection 0-7
------------------------------
36-187 GAME
------------------------------
36-43: Car 0 SKIN/ANIMATIONS
44-51: Car 1 SKIN/ANIMATIONS
52-59: Car 2 SKIN/ANIMATIONS
60-67: Car 3 SKIN/ANIMATIONS
68-75: Car 4 SKIN/ANIMATIONS
76-83: Car 5 SKIN/ANIMATIONS
84-91: Car 6 SKIN/ANIMATIONS
92-99: Car 7 SKIN/ANIMATIONS
------------------------------
100-103: ITMES
------------------------------
104-108: Map 0 SKIN/ANIMATIONS
109-113: Map 1 SKIN/ANIMATIONS
114-119: Map 2 SKIN/ANIMATIONS
120-125: Map 3 SKIN/ANIMATIONS
126-131: Map 4 SKIN/ANIMATIONS
132-137: Map 5 SKIN/ANIMATIONS
138-143: Map 6 SKIN/ANIMATIONS
144-187: Map 7 SKIN/ANIMATIONS
*/

new bool:game_initialized = false;

ONTICK() {
    if (game_running) {
        if (!game_initialized) {
            game_init();
            game_initialized = true;
        }
        game_run(settings[0], settings[1]);
    } else {
        menu();
    }
    //TODO: Remove this in case we deem it as completely obsolete
    /*if ((car_position_module == abi_cubeN) || ((is_departing) && (car_neighbour_module == abi_cubeN))) {
        send_car();
    }*/

    //Increases base speed (SHIFT_POS) after defined interval
    //TODO: Implement score system and elevate gain for each increase in movement speed
    /*if (delay % 100 == 0) {
        if (SHIFT_POS != 40) {
            SHIFT_POS = SHIFT_POS + 10;
            SCORE_GAIN_BASE = SCORE_GAIN_BASE * 2;
            printf("speeeeed = %d\n",SHIFT_POS);
        }
        delay = 0;
    }*/

    //exit program on shake
    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_CMD_NET_RX(const pkt[]) {
    switch (abi_ByteN(pkt, 4)) {
        //TODO: Remove this in case we deem it as completely obsolete
        /*case CMD_SEND_CAR:  {
            if ((abi_ByteN(pkt, 5) > count_departing) || ((abi_ByteN(pkt, 5) == 0) && (count_departing != 0))) {
                car_position_module = abi_ByteN(pkt, 8);
                car_position_screen = abi_ByteN(pkt, 9);

                is_departing = (((car_neighbour_module == abi_cubeN) && (car_position_x > -120)) ? true : false);

                if (car_position_module == abi_cubeN) {
                    car_position_y = -abi_ByteN(pkt, 10) - DISPLAY_SHADOW;
                    car_position_x = abi_ByteN(pkt, 11);
                    count_departing = abi_ByteN(pkt, 5) + 1;
                    car_current_angles = 90;
                }
            }
        }*/

        case CMD_SEND_SETTINGS:  {
            if (abi_ByteN(pkt, 5) == 0) {
                printf("INFO - Received CMD_SEND_SETTINGS{game_running: %d, car (settings[0]): %d, map (settings[1]): %d}\n", abi_ByteN(pkt, 8), abi_ByteN(pkt, 9), abi_ByteN(pkt, 10));
                game_running = abi_ByteN(pkt, 8);
                settings[0] = abi_ByteN(pkt, 9);
                settings[1] = abi_ByteN(pkt, 10);
            }

        }
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {
    // Skip menu screen
    game_running = true;
}
ON_CHECK_ROTATE() {}
