#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
#define DISPLAY_SHADOW  40

#define PICTURE         0

#define SHIFT_POS       20
#define SHIFT_ANGLE     10

#define CMD_SEND_SHIP   150

#define TEXT_SIZE 8

//Clone of example7 for experimental purposes.
new current_angles = 180;
new position_x = 120;
new position_y = 120;
new position_module = 0;
new position_screen = 0;
new trackId;

new bool:is_departing = false;
new count_departing = 0;

new neighbour_module = CUBES_MAX;
new neighbour_screen = FACES_MAX;

send_ship() {
    new data[4];
    data[0] = ((CMD_SEND_SHIP & 0xFF) | ((count_departing & 0xFF) << 8));
    data[1] = ((position_module & 0xFF) | ((position_screen & 0xFF) << 8) | ((position_x & 0xFF) << 16) | ((position_y & 0xFF) << 24));


    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}

ONTICK() {
    new screenI;

    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        //abi_CMD_FILL(0, 0, 0);

        new red = 31, green = 63, blue = 31;
        //clear screen before output
        abi_CMD_FILL(red, green, blue);
        //abi_CMD_TEXT_ITOA(100, 0, 230, 180, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);

        //draw text
        abi_CMD_TEXT("HELLO WORLD", 0, DISPLAY_WIDTH / 2, 60, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255); {
            new string[4]; // 4 cells is 16 bytes (16 packed characters including null terminator)
            strformat(string, sizeof(string), true, "MODULE %d", abi_cubeN);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
        } {
            new string[4];
            strformat(string, sizeof(string), true, "SCREEN %d", screenI);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 180, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
        }
        /* printf("Top: ");
        printf("C: %d // ", abi_topCubeN(0, 1));
        printf("F: %d\n", abi_topFaceN(0, 1));
        printf("Right: ");
        printf("C: %d // ", abi_rightCubeN(0, 1));
        printf("F: %d\n", abi_rightFaceN(0, 1));
        printf("Bottom: ");
        printf("C: %d // ", abi_bottomCubeN(0, 1));
        printf("F: %d\n", abi_bottomFaceN(0, 1));
        printf("Left: ");
        printf("C: %d // ", abi_leftCubeN(0, 1));
        printf("F: %d\n", abi_leftFaceN(0, 1));
        printf("---------------------------\n");
        //abi_CMD_FILL(255, 255, 255);
        */
        //push buffer at screen
        abi_CMD_REDRAW(screenI);
        /*  if (trackId % 2 == 0) {
              //draw bitmap at screen on the frame buffer
              if (((position_module == abi_cubeN) && (position_screen == screenI)) || ((is_departing) && (neighbour_module == abi_cubeN) && (neighbour_screen == screenI))) {
                  abi_CMD_BITMAP(PICTURE, position_x, position_y, current_angles, MIRROR_BLANK);

                  if ((position_x > 60) || (is_departing)) {
                      position_x = (((position_y == 180) && (current_angles == 180)) ? position_x - SHIFT_POS : position_x);
                      position_y = (((position_x == 180) && (current_angles == 90)) ? position_y + SHIFT_POS : position_y);
                      current_angles = (((position_x == 180) && (position_y == 180) && (current_angles != 180)) ? (current_angles + SHIFT_ANGLE) % 360 : current_angles);
                      //printf("posx = %d\n", position_x);
                  } else {
                      neighbour_module = abi_leftCubeN(abi_cubeN, screenI);
                      neighbour_screen = abi_leftFaceN(abi_cubeN, screenI);
                      if ((neighbour_module < CUBES_MAX) && (neighbour_screen < FACES_MAX)) {
                          is_departing = true;
                          position_module = neighbour_module;
                          position_screen = neighbour_screen;
                          neighbour_module = abi_cubeN;
                          neighbour_screen = screenI;
                          count_departing = (count_departing + 1) % 0xFF;
                          //is_departing = ((position_y < -120) ? false: is_departing);
                      }
                  }
              }
          }*/
        //  if (trackId % 2 != 0) {
        //draw bitmap at screen on the frame buffer
        if (((position_module == abi_cubeN) && (position_screen == screenI)) || ((is_departing) && (neighbour_module == abi_cubeN) && (neighbour_screen == screenI))) {
            abi_CMD_BITMAP(PICTURE, position_x, position_y, current_angles, MIRROR_BLANK);

            if ((position_x > 60) || (is_departing)) {
                position_x = (((position_y == 120) && (current_angles == 180)) ? position_x - SHIFT_POS : position_x);
                position_y = (((position_x == 120) && (current_angles == 90)) ? position_y + SHIFT_POS : position_y);
                //current_angles = (((position_x == 120) && (position_y == 120) && (current_angles != 180)) ? (current_angles + SHIFT_ANGLE) % 360 : current_angles);
                //printf("posx = %d\n", position_x);

            } else {
                neighbour_module = abi_leftCubeN(abi_cubeN, screenI);
                neighbour_screen = abi_leftFaceN(abi_cubeN, screenI);
                if ((neighbour_module < CUBES_MAX) && (neighbour_screen < FACES_MAX)) {
                    is_departing = true;
                    position_module = neighbour_module;
                    position_screen = neighbour_screen;
                    neighbour_module = abi_cubeN;
                    neighbour_screen = screenI;
                    count_departing = (count_departing + 1) % 0xFF;
                    //is_departing = ((position_y < -120) ? false: is_departing);
                    //trackId++;
                }
                if (trackId % 60 == 0) {
                    neighbour_module = abi_bottomCubeN(abi_cubeN, screenI);
                    neighbour_screen = abi_bottomFaceN(abi_cubeN, screenI);
                    if ((neighbour_module < CUBES_MAX) && (neighbour_screen < FACES_MAX)) {
                        is_departing = true;
                        position_module = neighbour_module;
                        position_screen = neighbour_screen;
                        neighbour_module = abi_cubeN;
                        neighbour_screen = screenI;
                        count_departing = (count_departing + 1) % 0xFF;
                        //is_departing = ((position_y < -120) ? false: is_departing);
                        //trackId++;
                    }
                    if ((position_y > 60) || (is_departing)) {
                        position_x = (((position_y == 120) && (current_angles == 180)) ? position_x + SHIFT_POS : position_x);
                        position_y = (((position_x == 120) && (current_angles == 90)) ? position_y - SHIFT_POS : position_y);
                        //current_angles = (((position_x == 120) && (position_y == 120) && (current_angles != 180)) ? (current_angles + SHIFT_ANGLE) % 360 : current_angles);
                        //printf("posx = %d\n", position_x);

                    }
                }
            }
        }
        // }
        //push buffer at screen
        abi_CMD_REDRAW(screenI);

        trackId++;
        printf("trackId: %d\n", trackId);
    }
    if ((position_module == abi_cubeN) || ((is_departing) && (neighbour_module == abi_cubeN))) {
        send_ship();
    }
    if (0 == abi_cubeN) {
        abi_checkShake();
    }

    //printf("count = %d module =%d screen = %d\n", count_departing, position_module, position_screen);
}
ON_CMD_NET_RX(const pkt[]) {
    switch (abi_ByteN(pkt, 4)) {
        case CMD_SEND_SHIP:  {
            if ((abi_ByteN(pkt, 5) > count_departing) || ((abi_ByteN(pkt, 5) == 0) && (count_departing != 0))) {
                position_module = abi_ByteN(pkt, 8);
                position_screen = abi_ByteN(pkt, 9);

                is_departing = (((neighbour_module == abi_cubeN) && (position_x > -120)) ? true : false);

                if (position_module == abi_cubeN) {
                    position_y = -abi_ByteN(pkt, 10) - DISPLAY_SHADOW;
                    position_x = abi_ByteN(pkt, 11);
                    count_departing = abi_ByteN(pkt, 5) + 1;
                    current_angles = 90;
                }
            }
        }
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}