#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#include "cuberacer/menu.pwn"
#include "cuberacer/game.pwn"

#define DISPLAY_SHADOW  40


/* 
----------------------------
ASSET CONCEPT
----------------------------
0-9: MAIN MENU
10-12: CAR SKIN SELECTION
13-15: MAP SKIN SELECTION
16-23: CAR 1 SKIN/ANIMATIONS
24-31: CAR 2 SKIN/ANIMATIONS
32-39: CAR 3 SKIN/ANIMATIONS
40-50: MAP 1 SKIN/ANIMATIONS
51-61: MAP 2 SKIN/ANIMATIONS
62-72: MAP 3 SKIN/ANIMATIONS
*/

new bool:game_initialized = false;

ONTICK() {
    if (game_running) {
        if (!game_initialized) {
            game_init(settings[1]);
            game_initialized = true;
        }
        game_run(settings[0]);
    } else {
        menu();
    }

    if ((car_position_module == abi_cubeN) || ((is_departing) && (car_neighbour_module == abi_cubeN))) {
        send_car();
    }

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
        case CMD_SEND_CAR:  {
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
        }

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
ON_INIT() {}
ON_CHECK_ROTATE() {}
