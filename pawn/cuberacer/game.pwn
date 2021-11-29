#define CMD_SEND_ROAD P2P_CMD_BASE_SCRIPT_1 + 2
#define CMD_SEND_CAR P2P_CMD_BASE_SCRIPT_1 + 3

new roads[8][3][3];
new currentCar[5];
new shadowCar[5];
new car_offset;

// TODO: Remove this in case we deem it as completely obsolete
/*new car_current_angles = 180;
new car_position_x = 0;
new car_position_y = 120;
new car_position_module = 0;
new car_position_screen = 0;

new SHIFT_POS = 10;
new SHIFT_ANGLE = 10;
new SCORE_GAIN_BASE = 10;

new bool:is_departing = false;
new count_departing = 0;

new car_neighbour_module = CUBES_MAX;
new car_neighbour_screen = FACES_MAX;*/

//assigns element type according to custom probabilities (see documentation: https://wow-cube.atlassian.net/wiki/spaces/WOWCUBE/pages/17760267/CubeRacer)
draw_road() {
    new rand = Random(100);
    //return 0;
    //Crossroads
    if (rand <= 40) {
        return 0;
    }
    //Straight
    //else if (rand > 40 && rand <= 70) {
    else {
        return 1;
    }
    //Turn
    /*else if (rand > 70 && rand <= 100) {
        return 2;
    }*/
}

draw_item() {
    new rand = Random(100);
    if (rand <= 80) {
        return 0;
    } else if (rand > 80 && rand <= 85) {
        return 1;
    } else if (rand > 86 && rand <= 90) {
        return 2;
    } else if (rand > 90 && rand <= 95) {
        return 3;
    } else if (rand > 95 && rand <= 100) {
        return 4;
    }
}

generate_road(module, face) {
    roads[module][face][0] = draw_road();
    roads[module][face][1] = Random(4);
    roads[module][face][2] = draw_item();
    //printf("INFO - Generated Road(%d/%d/%d) on (%d/%d)\n", roads[module][face][0], roads[module][face][1], roads[module][face][2], module, face);
    // Broadcast generated road to all other processors
    send_road(module, face);
}

getDirectionAngle(direction) {
    return direction * 90;
}

//broadcast information to CPU
// TODO: Remove this in case we deem it as completely obsolete
/*send_car() {
    new data[4];
    data[0] = ((CMD_SEND_CAR & 0xFF) | ((count_departing & 0xFF) << 8));
    data[1] = ((currentCar[0] & 0xFF) | ((currentCar[1] & 0xFF) << 8) | ((currentCar[2] & 0xFF) << 16) | ((currentCar[3] & 0xFF) << 24) | ((currentCar[4] & 0xFF) << 32));

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}*/

send_road(module, face) {
    new data[4];
    data[0] = (CMD_SEND_ROAD & 0xFF);
    data[1] = ((module & 0xFF) | ((face & 0xFF) << 8));
    data[2] = ((roads[module][face][0] & 0xFF) | ((roads[module][face][1] & 0xFF) << 8) | ((roads[module][face][2] & 0xFF) << 16))

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}

move_car(car[]) {
    switch (car[4]) {
        case 0:
            car[2]++;
        case 1:
            car[3]++;
        case 2:
            car[2]--;
        case 3:
            car[3]--;
    }
}

game_init() {
    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        // First field will always be crossroads
        if (!((abi_cubeN == 0) && (screenI == 0))) {
            generate_road(abi_cubeN, screenI);
        }
    }
    // Horizontal start
    /*currentCar[0] = 0;
    currentCar[1] = 0;
    currentCar[2] = 240;
    currentCar[3] = 120;
    currentCar[4] = 2;

    shadowCar[0] = 0;
    shadowCar[1] = 2;
    shadowCar[2] = 120;
    shadowCar[3] = 240;
    shadowCar[4] = 1;*/

    // Vertical start
    currentCar[0] = 0;
    currentCar[1] = 0;
    currentCar[2] = 120;
    currentCar[3] = 240;
    currentCar[4] = 3;

    shadowCar[0] = 0;
    shadowCar[1] = 1;
    shadowCar[2] = 240;
    shadowCar[3] = 120;
    shadowCar[4] = 0;
}

game_run(car_skin, map_skin, car_length) {
    car_offset = car_length - 120;
    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        // Tapping the screen rotates the displayed element by 90 degrees clockwise.
        if ((((screenI == abi_MTD_GetTapFace() && (abi_MTD_GetTapsCount() >= 1)))) && (!((abi_cubeN == currentCar[0]) && (screenI == currentCar[1])))) {
            roads[abi_cubeN][screenI][1] = (roads[abi_cubeN][screenI][1] + abi_MTD_GetTapsCount()) % 4;
            send_road(abi_cubeN, screenI);
        }

        // Render roads and items
        abi_CMD_FILL(0, 0, 0);
        abi_CMD_BITMAP(roads[abi_cubeN][screenI][0] + ((map_skin * 5) + 104), 240 / 2, 240 / 2, roads[abi_cubeN][screenI][1] * 90, MIRROR_BLANK);
        if (roads[abi_cubeN][screenI][2] != 0) {
            abi_CMD_BITMAP(roads[abi_cubeN][screenI][2] + 99, 240 / 2, 240 / 2, roads[abi_cubeN][screenI][1], MIRROR_BLANK);
        }

        // Render car
        if ((abi_cubeN == currentCar[0]) && (screenI == currentCar[1])) {
            abi_CMD_BITMAP(car_skin * 8 + 36, currentCar[2], currentCar[3], getDirectionAngle(currentCar[4]), MIRROR_BLANK);
        }
        if ((abi_cubeN == shadowCar[0]) && (screenI == shadowCar[1])) {
            abi_CMD_BITMAP(car_skin * 8 + 36, shadowCar[2], shadowCar[3], getDirectionAngle(shadowCar[4]), MIRROR_BLANK);
        }
        abi_CMD_REDRAW(screenI);
        move_car(currentCar);
        move_car(shadowCar);
        //printf("INFO - currentCar(5)[\"%d\", \"%d\", \"%d\", \"%d\", \"%d\"]\n", currentCar[0], currentCar[1], currentCar[2], currentCar[3], currentCar[4]);
        //printf("INFO - shadowCar(5)[\"%d\", \"%d\", \"%d\", \"%d\", \"%d\"]\n\n", shadowCar[0], shadowCar[1], shadowCar[2], shadowCar[3], shadowCar[4]);
        switch (currentCar[4]) {
            case 0 :  {
                // Car is at the edge
                if (currentCar[2] == 240 - car_offset) {
                    // Crash logic straight road
                    if(roads[abi_rightCubeN(currentCar[0], currentCar[1])][abi_rightFaceN(currentCar[0], currentCar[1])][0] == 1 && (roads[abi_rightCubeN(currentCar[0], currentCar[1])][abi_rightFaceN(currentCar[0], currentCar[1])][1] == 0 || roads[abi_rightCubeN(currentCar[0], currentCar[1])][abi_rightFaceN(currentCar[0], currentCar[1])][1] == 2)) {
                        abi_exit();
                    }
                    shadowCar[0] = currentCar[0];
                    shadowCar[1] = currentCar[1];
                    shadowCar[2] = currentCar[2];
                    shadowCar[3] = currentCar[3];
                    shadowCar[4] = currentCar[4];
                    currentCar[0] = abi_rightCubeN(shadowCar[0], shadowCar[1]);
                    currentCar[1] = abi_rightFaceN(shadowCar[0], shadowCar[1]);
                    currentCar[2] = 120;
                    currentCar[3] = 240 + car_offset;
                    currentCar[4] = 3;
                }
            }
            case 1 :  {
                // Car is at the edge
                if (currentCar[3] == 240 - car_offset) {
                    // Crash logic straight road
                    if(roads[abi_bottomCubeN(currentCar[0], currentCar[1])][abi_bottomFaceN(currentCar[0], currentCar[1])][0] == 1 && (roads[abi_bottomCubeN(currentCar[0], currentCar[1])][abi_bottomFaceN(currentCar[0], currentCar[1])][1] == 1 || roads[abi_bottomCubeN(currentCar[0], currentCar[1])][abi_bottomFaceN(currentCar[0], currentCar[1])][1] == 3)) {
                        abi_exit();
                    }
                    shadowCar[0] = currentCar[0];
                    shadowCar[1] = currentCar[1];
                    shadowCar[2] = currentCar[2];
                    shadowCar[3] = currentCar[3];
                    shadowCar[4] = currentCar[4];
                    currentCar[0] = abi_bottomCubeN(shadowCar[0], shadowCar[1]);
                    currentCar[1] = abi_bottomFaceN(shadowCar[0], shadowCar[1]);
                    currentCar[2] = 240 + car_offset;
                    currentCar[3] = 120;
                    currentCar[4] = 2;
                }
            }
            case 2 :  {
                // Car is at the edge
                if (currentCar[2] == car_offset) {
                    // Crash logic straight road
                    if(roads[abi_leftCubeN(currentCar[0], currentCar[1])][abi_leftFaceN(currentCar[0], currentCar[1])][0] == 1 && (roads[abi_leftCubeN(currentCar[0], currentCar[1])][abi_leftFaceN(currentCar[0], currentCar[1])][1] == 0 || roads[abi_leftCubeN(currentCar[0], currentCar[1])][abi_leftFaceN(currentCar[0], currentCar[1])][1] == 2)) {
                        abi_exit();
                    }
                    shadowCar[0] = currentCar[0];
                    shadowCar[1] = currentCar[1];
                    shadowCar[2] = currentCar[2];
                    shadowCar[3] = currentCar[3];
                    shadowCar[4] = currentCar[4];
                    currentCar[0] = abi_leftCubeN(shadowCar[0], shadowCar[1]);
                    currentCar[1] = abi_leftFaceN(shadowCar[0], shadowCar[1]);
                    currentCar[2] = 120;
                    currentCar[3] = -car_offset;
                    currentCar[4] = 1;
                }
            }
            case 3 :  {
                // Car is at the edge
                if (currentCar[3] == car_offset) {
                    // Crash logic straight road
                    if(roads[abi_topCubeN(currentCar[0], currentCar[1])][abi_topFaceN(currentCar[0], currentCar[1])][0] == 1 && (roads[abi_topCubeN(currentCar[0], currentCar[1])][abi_topFaceN(currentCar[0], currentCar[1])][1] == 1 || roads[abi_topCubeN(currentCar[0], currentCar[1])][abi_topFaceN(currentCar[0], currentCar[1])][1] == 3)) {
                        abi_exit();
                    }
                    shadowCar[0] = currentCar[0];
                    shadowCar[1] = currentCar[1];
                    shadowCar[2] = currentCar[2];
                    shadowCar[3] = currentCar[3];
                    shadowCar[4] = currentCar[4];
                    currentCar[0] = abi_topCubeN(shadowCar[0], shadowCar[1]);
                    currentCar[1] = abi_topFaceN(shadowCar[0], shadowCar[1]);
                    currentCar[2] = -car_offset;
                    currentCar[3] = 120;
                    currentCar[4] = 0;
                }
            }
        }
        /*if (((car_position_module == abi_cubeN) && (car_position_screen == screenI)) || ((is_departing) && (car_neighbour_module == abi_cubeN) && (car_neighbour_screen == screenI))) {
            abi_CMD_BITMAP(car_skin * 8 + 36, car_position_x, car_position_y, car_current_angles, MIRROR_BLANK);

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
            printf("INFO - Car{position_x: %d, position_y: %d, angle: %d, module: %d, screen: %d}\n", car_position_x, car_position_y, car_current_angles, car_position_module, car_position_screen);
        }*/
    }
}