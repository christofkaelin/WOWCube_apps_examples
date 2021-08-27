#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#include "cuberacer/game.pwn"

#define CMD_SEND_SETTINGS P2P_CMD_BASE_SCRIPT_1 + 1

#define DISPLAY_SHADOW  40

new settings[2] = { 0, 0 };

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

new bool:game_running = false;
new bool:game_initialized = false;

// SEND MENU SETTINGS
// TODO: Modularize this
send_settings() {
    new data[4];

    data[0] = ((CMD_SEND_SETTINGS & 0xFF));
    data[1] = ((game_running & 0xFF) | ((settings[0] & 0xFF) << 8) | ((settings[1] & 0xFF) << 16));

    // send message through UART
    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data);
}


ONTICK() {
    if (game_running) {
        if (!game_initialized) {
            game_init(settings[1]);
            game_initialized = true;
        }
        game_run(settings[0]);
    } else {
        // MENU LOGIC
        // TODO: Modularize this
        CheckAngles();
        for (new screenI = 0; screenI < FACES_MAX; screenI++) {
            abi_CMD_FILL(0, 0, 0);
            switch (newAngles[screenI]) {
                case 180:
                    abi_CMD_BITMAP(0, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);

                case 90:
                    abi_CMD_BITMAP(2, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);

                case 270:
                    abi_CMD_BITMAP(settings[0] + 10, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);

                case 0:
                    abi_CMD_BITMAP(settings[1] + 13, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);
            }
            abi_CMD_REDRAW(screenI);

            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                abi_CMD_FILL(0, 0, 0);

                switch (newAngles[screenI]) {
                    case 90 :  {
                        printf("INFO - Tapped start\n");
                        game_running = true;
                        send_settings();
                        //abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, game_running);
                    }

                    case 270 :  {
                        settings[0] = (settings[0] + abi_MTD_GetTapsCount()) % 3;
                        printf("INFO - Changed car, new car: %d\n", settings[0]);
                        send_settings();
                    }

                    case 0 : {
                        settings[1] = (settings[1] + abi_MTD_GetTapsCount()) % 3;
                        printf("INFO - Changed map, new map: %d\n", settings[1]);
                        send_settings();
                    }
                }
            }
        }
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
ON_INIT() {
    //init_menu();
    //game_running = true;
}
ON_CHECK_ROTATE() {}
