#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240
#define DISPLAY_SHADOW  40

#define CMD_SEND_CAR   150

new map = 1;
// TODO: Work on a concept for car skins and add car effects (boost, guardian angel)
new car = 22;

new roads[8][3][2];

new car_current_angles = 180;
new car_position_x = 120;
new car_position_y = 120;
new car_position_module = 0;
new car_position_screen = 0;

new SHIFT_POS = 10;
new SHIFT_ANGLE = 10;
new SCORE_GAIN_BASE = 10;

new bool:is_departing = false;
new count_departing = 0;

new car_neighbour_module = CUBES_MAX;
new car_neighbour_screen = FACES_MAX;

new delay = 0;
new rand;

//broadcast information to CPU
send_car() {
    new data[4];
    data[0] = ((CMD_SEND_CAR & 0xFF) | ((count_departing & 0xFF) << 8));
    data[1] = ((car_position_module & 0xFF) | ((car_position_screen & 0xFF) << 8) | ((car_position_x & 0xFF) << 16) | ((car_position_y & 0xFF) << 24));


    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}
//assigns element type according to custom probabilities (see documentation: https://wow-cube.atlassian.net/wiki/spaces/WOWCUBE/pages/17760267/CubeRacer)
draw_road() {

    rand = random(100);

    //Straight
    if (rand <= 35) {
        return 0 + (map * 11);
    }
    //Turn
    else if (rand > 35 && rand <= 70) {
        return 1 + (map * 11);
    }
    //U-Turn
    else if (rand > 70 && rand <= 75) {
        return 2 + (map * 11);
    }
    //bomb
    else if (rand > 75 && rand <= 80) {
        //bomb-straight
        if (rand <= 78) {
            return 3 + (map * 11);
        }
        //bomb-turn
        else {
            return 4 + (map * 11);
        }
    }
    //jump
    else if (rand > 80 && rand <= 85) {
        return 5 + (map * 11);
    }
    //boost
    else if (rand > 85 && rand <= 90) {
        //boost-straight
        if (rand <= 88) {
            return 6 + (map * 11);
        }
        //boost-turn
        else {
            return 7 + (map * 11);
        }
    }
    //guardian
    else if (rand > 90 && rand <= 95) {
        //guardian-straight
        if (rand <= 93) {
            return 8 + (map * 11);
        }
        //guardian-turn
        else {
            return 9 + (map * 11);
        }
    }
    //warp
    else if (rand > 95 && rand <= 100) {
        return 10 + (map * 11);
    }
}

ONTICK() {
    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        // Tapping the screen rotates the displayed element by 90 degrees clockwise.
        if (screenI == (abi_MTD_GetTapFace())) {
            abi_CMD_FILL(0, 0, 0);
            roads[abi_cubeN][screenI][1] = roads[abi_cubeN][screenI][1] + (90 * abi_MTD_GetTapsCount());
            abi_CMD_BITMAP(roads[abi_cubeN][screenI][0], DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + roads[abi_cubeN][screenI][1], MIRROR_BLANK);
            abi_CMD_REDRAW(screenI);
        }

        if (((car_position_module == abi_cubeN) && (car_position_screen == screenI)) || ((is_departing) && (car_neighbour_module == abi_cubeN) && (car_neighbour_screen == screenI))) {
            abi_CMD_BITMAP(car, car_position_x, car_position_y, car_current_angles, MIRROR_BLANK);

            if ((car_position_x > 60) || (is_departing)) {
                car_position_x = (((car_position_y == 120) && (car_current_angles == 180)) ? car_position_x - SHIFT_POS : car_position_x);
                car_position_y = (((car_position_x == 120) && (car_current_angles == 90)) ? car_position_y + SHIFT_POS : car_position_y);
                car_current_angles = (((car_position_x == 120) && (car_position_y == 120) && (car_current_angles != 180)) ? (car_current_angles + SHIFT_ANGLE) % 360 : car_current_angles);
                //printf("posx = %d\n", car_position_x);
            } else {
                car_neighbour_module = abi_leftCubeN(abi_cubeN, screenI);
                car_neighbour_screen = abi_leftFaceN(abi_cubeN, screenI);
                if ((car_neighbour_module < CUBES_MAX) && (car_neighbour_screen < FACES_MAX)) {
                    is_departing = true;
                    car_position_module = car_neighbour_module;
                    car_position_screen = car_neighbour_screen;
                    car_neighbour_module = abi_cubeN;
                    car_neighbour_screen = screenI;
                    count_departing = (count_departing + 1) % 0xFF;
                    //is_departing = ((position_y < -120) ? false: is_departing);
                }
            }
            //push buffer at screen
            abi_CMD_REDRAW(screenI);
        }
        delay++;
        //printf("posM = %d\n", car_position_module);
        //printf("posS = %d\n", car_position_screen);
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
    }
*/
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
    }
}

ON_PHYSICS_TICK() {}
RENDER() {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {
    // First field will always be a straight road
    roads[0][0][0] = 0 + (map * 11);
    roads[0][0][1] = 0;

    roads[0][1][0] = draw_road();
    roads[0][2][0] = draw_road();
    roads[1][0][0] = draw_road();
    roads[1][1][0] = draw_road();
    roads[1][2][0] = draw_road();
    roads[2][0][0] = draw_road();
    roads[2][1][0] = draw_road();
    roads[2][2][0] = draw_road();
    roads[3][0][0] = draw_road();
    roads[3][1][0] = draw_road();
    roads[3][2][0] = draw_road();
    roads[4][0][0] = draw_road();
    roads[4][1][0] = draw_road();
    roads[4][2][0] = draw_road();
    roads[5][0][0] = draw_road();
    roads[5][1][0] = draw_road();
    roads[5][2][0] = draw_road();
    roads[6][0][0] = draw_road();
    roads[6][1][0] = draw_road();
    roads[6][2][0] = draw_road();
    roads[7][0][0] = draw_road();
    roads[7][1][0] = draw_road();
    roads[7][2][0] = draw_road();

    // Randomly generate rotation of the roads
    roads[0][1][1] = random(3) * 90;
    roads[0][2][1] = random(3) * 90;
    roads[1][0][1] = random(3) * 90;
    roads[1][1][1] = random(3) * 90;
    roads[1][2][1] = random(3) * 90;
    roads[2][0][1] = random(3) * 90;
    roads[2][1][1] = random(3) * 90;
    roads[2][2][1] = random(3) * 90;
    roads[3][0][1] = random(3) * 90;
    roads[3][1][1] = random(3) * 90;
    roads[3][2][1] = random(3) * 90;
    roads[4][0][1] = random(3) * 90;
    roads[4][1][1] = random(3) * 90;
    roads[4][2][1] = random(3) * 90;
    roads[5][0][1] = random(3) * 90;
    roads[5][1][1] = random(3) * 90;
    roads[5][2][1] = random(3) * 90;
    roads[6][0][1] = random(3) * 90;
    roads[6][1][1] = random(3) * 90;
    roads[6][2][1] = random(3) * 90;
    roads[7][0][1] = random(3) * 90;
    roads[7][1][1] = random(3) * 90;
    roads[7][2][1] = random(3) * 90;
    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        abi_CMD_FILL(0, 0, 0);
        abi_CMD_BITMAP(roads[abi_cubeN][screenI][0], DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + roads[abi_cubeN][screenI][1], MIRROR_BLANK);
        abi_CMD_REDRAW(screenI);
    }
}
ON_CHECK_ROTATE() {}