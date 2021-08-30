InitVariables() {

    game.is_set_back = false;
    game.is_generated = false;
    game.local_ticks = 0;
    game.countdown = 3;
    game.time_bonus = 500;
    game.health = INIT_HEALTH;
    game.score = 0;
    game.is_set_titres = false;
    game.status = GAME_PLAY;

    ladybug.cube = CUBES_MAX;
    ladybug.face = FACES_MAX;
    ladybug.x = 120;
    ladybug.y = 120;
    ladybug.speed_x = 0;
    ladybug.speed_y = -SPEED;
    ladybug.angle = CalculateAngle();
    ladybug.target_angle = TURN_NULL;

    ladybug.dep_cube = CUBES_MAX;
    ladybug.dep_face = FACES_MAX;
    ladybug.dep_x = 120;
    ladybug.dep_y = 120;
    ladybug.dep_angle = ladybug.angle;
    ladybug.is_departing = false;
    ladybug.count_transition = 0;

    if (abi_cubeN == 0) {
        game.level_trying++;
        game.level_trying %= 0xFF;
    }

    ladybug.slippage = 0;

    for (cube = 0; cube < CUBES_MAX; cube++) {
        for (face = 0; face < FACES_MAX; face++) {
            roadway[cube].fruit[face] = ENUM_FRUITS_MAX;
        }
    }
    for (new counter = 0; counter < FACES_ON_PLANE; counter++) {
        game.titres_cube[counter] = CUBES_MAX;
        game.titres_face[counter] = FACES_MAX;
    }
}
GenerateLevel() {

    if (!((abi_cubeN == 0) && (!game.is_generated))) return;

    new start_cube = CUBES_MAX;
    new start_face = FACES_MAX;
    new neighbor_cube = CUBES_MAX;
    new neighbor_face = FACES_MAX;
    new l_cube;
    new l_figure[ROADS];

    getCubeFaceToResults(abi_cubeN, 0, start_cube, start_face);
    getCubeFaceToResults(abi_cubeN, 1, start_cube, start_face);
    getCubeFaceToResults(abi_cubeN, 2, start_cube, start_face);

    if (!((start_cube < CUBES_MAX) && (start_face < FACES_MAX))) return;

    neighbor_cube = abi_topCubeN(start_cube, start_face);
    neighbor_face = abi_topFaceN(start_cube, start_face);

    if (!((neighbor_cube < CUBES_MAX) && (neighbor_face < FACES_MAX))) return;

    ladybug.cube = start_cube;
    ladybug.face = start_face;

    if (ladybug.cube != abi_cubeN) {
        ladybug.is_departing = true;
        //ladybug.speed_y *= -1;
    }

    for (cube = 0; cube < CUBES_MAX; cube++) {
        l_cube = ((cube == ladybug.cube) ? 0 : ((cube == neighbor_cube) ? Random(1, CUBES_MAX - 2) : Random(1, CUBES_MAX - 1)));
        start_face = ((cube == ladybug.cube) ? ladybug.face : Random(1, FACES_MAX - 1));
        if (cube == neighbor_cube) {
            for (face = 0; face < FACES_MAX; face++) {
                l_figure = models_of_roads[l_cube][face];
                if (((l_figure.road_type == CROSROAD) && (l_figure.angle == ANGLE_90)) ||
                    ((l_figure.road_type == CROSROAD) && (l_figure.angle == ANGLE_180)) ||
                    ((l_figure.road_type == STRAIGHT_ROAD) && (l_figure.angle == ANGLE_0)) ||
                    ((l_figure.road_type == STRAIGHT_ROAD) && (l_figure.angle == ANGLE_180))) {

                    start_face = neighbor_face - face;
                    break;
                }
            }
        }

        roadway[cube].road_cube = l_cube;
        for (face = 0; face < FACES_MAX; face++) {
            roadway[cube].road_face[face] = (FACES_MAX - start_face + face) % FACES_MAX;
        }
    }

    game.level = (game.level + 1) % MAX_LEVEL;

    game.level_trying++;
    game.level_trying %= 0xFF;

    GenerateLandscape();

    GenerateFruits();

    GetPlacesPosition();

    game.is_generated = true;

}
GenerateLandscape() {
    new l_figure[ROADS];
    new l_place;

    for (face = 0; face < FACES_MAX; face++) {
        //landscape[face] = 0xFFFFFFFF;
        l_figure = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[face]];

        for (place_y = 0; place_y < PLACES_Y; place_y++) {
            for (place_x = 0; place_x < PLACES_X; place_x++) {

                l_place = place_x + place_y * PLACES_X;

                if (l_place == PLACE_FRUIT) continue; //center of face
                landscapes[face][l_place].object = LANDSCAPES_MAX;
                switch (l_figure.road_type) {
                    case STRAIGHT_ROAD:  {
                        if (((l_figure.angle == 0) || (l_figure.angle == 2)) && ((l_place == 3) || (l_place == 5))) continue;
                        if (((l_figure.angle == 1) || (l_figure.angle == 3)) && ((l_place == 1) || (l_place == 7))) continue;
                    }
                    case CROSROAD:  {
                        switch (l_figure.angle) {
                            case 0 :  {
                                if ((l_place == 5) || (l_place == 7)) continue;
                            }
                            case 1 :  {
                                if ((l_place == 3) || (l_place == 7)) continue;
                            }
                            case 2 :  {
                                if ((l_place == 1) || (l_place == 3)) continue;
                            }
                            case 3 :  {
                                if ((l_place == 1) || (l_place == 5)) continue;
                            }
                        }
                    }
                    case END_OF_ROAD:  {
                        if (((l_figure.angle == 0) || (l_figure.angle == 2)) && (l_place == 3)) continue;
                        if (((l_figure.angle == 1) || (l_figure.angle == 3)) && ((l_place == 1) || (l_place == 7))) continue;
                    }
                }

                landscapes[face][l_place].object = Random(0, LANDSCAPES_MAX - 1);
            }
        }
    }
}
GenerateFruits() {
    new fruit;

    for (new counter = 0; counter < game.level + 1; counter++) {
        cube = CUBES_MAX;
        face = FACES_MAX;

        while ((cube == CUBES_MAX) && (face == FACES_MAX)) {
            cube = Random(0, CUBES_MAX - 1);
            face = Random(0, FACES_MAX - 1);

            if (((cube == ladybug.cube) && (face == ladybug.face)) || (roadway[cube].fruit[face] == POISON)) {
                cube = CUBES_MAX;
                face = FACES_MAX;
            } else {
                roadway[cube].fruit[face] = POISON;
            }
        }
    }
    for (cube = 0; cube < CUBES_MAX; cube++) {
        for (face = 0; face < FACES_MAX; face++) {

            if (((cube == ladybug.cube) && (face == ladybug.face)) || (roadway[cube].fruit[face] == POISON)) continue;

            fruit = Random(1, ENUM_FRUITS_MAX);

            roadway[cube].fruit[face] = fruit;
        }
    }
    for (face = 0; face < FACES_MAX; face++) {
        landscapes[face][PLACE_FRUIT].object = roadway[abi_cubeN].fruit[face];
    }
}
CalculateAngle() {
    if (ladybug.speed_x > 0) return 90;
    else if (ladybug.speed_x < 0) return 270;
    else if (ladybug.speed_y > 0) return 180;
    else if (ladybug.speed_y < 0) return 0;
    return 0;
}
CheckMigration() {
    if ((ladybug.cube != abi_cubeN) || (game.status != GAME_PLAY)) return;

    new l_cube = CUBES_MAX;
    new l_face = FACES_MAX;
    new l_figure[ROADS];

    new bool:is_migration = true;
    new l_side_to_move = MOVE_NONE;
    if ((ladybug.y + ladybug.speed_y < LADYBUG_SIZE / 2) && (ladybug.speed_y < 0)) {
        l_cube = abi_topCubeN(abi_cubeN, ladybug.face);
        l_face = abi_topFaceN(abi_cubeN, ladybug.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == CROSROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_180))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180)))) {
            l_side_to_move = MOVE_TO_TOP;
        }
    } else if ((ladybug.x + ladybug.speed_x > DISPLAY_WIDTH - LADYBUG_SIZE / 2) && (ladybug.speed_x > 0)) {
        l_cube = abi_rightCubeN(abi_cubeN, ladybug.face);
        l_face = abi_rightFaceN(abi_cubeN, ladybug.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == CROSROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_90))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270)))) {
            l_side_to_move = MOVE_TO_RIGHT;
        }
    } else if ((ladybug.y + ladybug.speed_y > DISPLAY_HEIGHT - LADYBUG_SIZE / 2) && (ladybug.speed_y > 0)) {
        l_cube = abi_bottomCubeN(abi_cubeN, ladybug.face);
        l_face = abi_bottomFaceN(abi_cubeN, ladybug.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == CROSROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180)))) {
            l_side_to_move = MOVE_TO_BOTTOM;
        }
    } else if ((ladybug.x + ladybug.speed_x < LADYBUG_SIZE / 2) && (ladybug.speed_x < 0)) {
        l_cube = abi_leftCubeN(abi_cubeN, ladybug.face);
        l_face = abi_leftFaceN(abi_cubeN, ladybug.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == CROSROAD) && ((l_figure.angle == ANGLE_180) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270)))) {
            l_side_to_move = MOVE_TO_LEFT;
        }
    } else {
        is_migration = false;
    }

    if (l_side_to_move != MOVE_NONE) {

        ladybug.dep_cube = ladybug.cube;
        ladybug.dep_face = ladybug.face;
        ladybug.dep_x = ladybug.x;
        ladybug.dep_y = ladybug.y;
        ladybug.dep_speed_x = ladybug.speed_x;
        ladybug.dep_speed_y = ladybug.speed_y;
        ladybug.dep_angle = ladybug.angle;

        ladybug.cube = l_cube;
        ladybug.face = l_face;

        l_figure = models_of_roads[roadway[ladybug.cube].road_cube][roadway[ladybug.cube].road_face[ladybug.face]];
        switch (l_side_to_move) {
            case MOVE_TO_TOP:  {
                ladybug.x = -ladybug.y - SHADOW_DIST;
                ladybug.y = 120;
                ladybug.speed_x = -ladybug.speed_y;
                ladybug.speed_y = 0;
                ladybug.target_angle = ((l_figure.road_type != CROSROAD) ? TURN_NULL: ((l_figure.angle == ANGLE_180) ? TURN_LEFT : TURN_RIGHT));

                ladybug.is_departing = true;
            }
            case MOVE_TO_RIGHT:  {
                ladybug.y = DISPLAY_HEIGHT + SHADOW_DIST + (DISPLAY_HEIGHT - ladybug.x);
                ladybug.x = 120;
                ladybug.speed_y = -ladybug.speed_x;
                ladybug.speed_x = 0;
                ladybug.target_angle = ((l_figure.road_type != CROSROAD) ? TURN_NULL: ((l_figure.angle == ANGLE_90) ? TURN_LEFT : TURN_RIGHT));
            }
            case MOVE_TO_BOTTOM:  {
                ladybug.x = DISPLAY_WIDTH + SHADOW_DIST + (DISPLAY_WIDTH - ladybug.y);
                ladybug.y = 120;
                ladybug.speed_x = -ladybug.speed_y;
                ladybug.speed_y = 0;
                ladybug.target_angle = ((l_figure.road_type != CROSROAD) ? TURN_NULL: ((l_figure.angle == ANGLE_0) ? TURN_LEFT : TURN_RIGHT));
            }
            case MOVE_TO_LEFT:  {
                ladybug.y = -ladybug.x - SHADOW_DIST;
                ladybug.x = 120;
                ladybug.speed_y = -ladybug.speed_x;
                ladybug.speed_x = 0;
                ladybug.target_angle = ((l_figure.road_type != CROSROAD) ? TURN_NULL: ((l_figure.angle == ANGLE_270) ? TURN_LEFT : TURN_RIGHT));

                ladybug.is_departing = true;
            }
        }
        ladybug.angle = CalculateAngle();
        ladybug.target_angle = (ladybug.angle + 360 + ladybug.target_angle) % 360;

        ladybug.target_angle = (((ladybug.angle == 270) && (ladybug.target_angle == 0)) ? 360 : ladybug.target_angle);
        ladybug.angle = (((ladybug.angle == 0) && (ladybug.target_angle == 270)) ? 360 : ladybug.angle);

        ladybug.count_transition++;
        ladybug.count_transition %= 0xFF;
    } else if (is_migration) {
        ladybug.slippage++;
        if (ladybug.slippage == SLIPPAGE_TICKS) {
            //game.status = GAME_OVER;
            #ifdef SOUND
            abi_CMD_PLAYSND(SOUND_GAMEOVER, SOUND_VOLUME);
            #endif 
            //if (abi_cubeN == 0)
            //    ladybug.count_transition++;
        }
    }
}
CalcGameLogic() {
    game.local_ticks = ((game.local_ticks + 1) % (FRUIT_ANIMATION_MAX * 100));

    if (abi_cubeN == 0) {
        game.time_bonus = ((game.time_bonus == 0 || game.status != GAME_PLAY || game.local_ticks % 10 != 0 || game.countdown != COUNTDOWN_PLAY) ? game.time_bonus : game.time_bonus - 1);
    }
}
CalcMoveLadyBug(l_face) {
    if ((game.status != GAME_PLAY) || (game.countdown != COUNTDOWN_PLAY)) return;

    if ((abi_cubeN == ladybug.cube) && (l_face == ladybug.face)) {

        MoveLadyBug();
    }
    if ((abi_cubeN == ladybug.dep_cube) && (l_face == ladybug.dep_face)) {
        ladybug.dep_x += ladybug.dep_speed_x + GetSign(ladybug.dep_speed_x) * ladybug.multiplier * MULTIPLIER_PKT;
        ladybug.dep_y += ladybug.dep_speed_y + GetSign(ladybug.dep_speed_y) * ladybug.multiplier * MULTIPLIER_PKT;


        if ((ladybug.dep_x < -LADYBUG_SIZE / 2) || (ladybug.dep_y < -LADYBUG_SIZE / 2)) {

            ladybug.dep_cube = CUBES_MAX;
            ladybug.dep_face = FACES_MAX;
        }
    }
}
MoveLadyBug() {
    #define CROSROAD_MIN 60
    #define CROSROAD_MAX 180

    test = 9;
    //DEBUG
    ladybug_debug.x = ladybug.x;
    ladybug_debug.y = ladybug.y;
    ladybug_debug.angle = ladybug.angle;
    ladybug_debug.target_angle = ladybug.target_angle;

    new new_positions[POINT] = [0, 0, 0];
    new last_positions[POINT];

    last_positions.x = ladybug.x;
    last_positions.y = ladybug.y;

    ladybug.multiplier = 0;

    new_positions.x = ladybug.x + ladybug.speed_x + GetSign(ladybug.speed_x) * ladybug.multiplier * MULTIPLIER_PKT;
    new_positions.y = ladybug.y + ladybug.speed_y + GetSign(ladybug.speed_y) * ladybug.multiplier * MULTIPLIER_PKT;

    if (ladybug.slippage) return;

    new l_figure[ROADS];
    l_figure = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[ladybug.face]];

    if (l_figure.road_type == STRAIGHT_ROAD) {
        ladybug.x = new_positions.x;
        ladybug.y = new_positions.y;
    } else if (l_figure.road_type == END_OF_ROAD) {
        if ((ladybug.angle != 0) && (ladybug.y > 120)) {
            ladybug.angle -= 15;
            ladybug.speed_y = -ABS(ladybug.speed_y);
        } else {
            ladybug.x = new_positions.x;
            ladybug.y = new_positions.y;
        }
    } else if (l_figure.road_type == CROSROAD) {
        if (((ladybug.x >= CROSROAD_MIN) && (ladybug.x <= CROSROAD_MAX) && (ladybug.y >= CROSROAD_MIN) && (ladybug.y <= CROSROAD_MAX)) ||
            ((new_positions.x >= CROSROAD_MIN) && (new_positions.x <= CROSROAD_MAX) && (new_positions.y >= CROSROAD_MIN) && (new_positions.y <= CROSROAD_MAX))) {

            new step = ABS(ladybug.speed_x) + ABS(ladybug.speed_y) + ladybug.multiplier * MULTIPLIER_PKT;
            new center[POINT];

            if (ladybug.x < 60) {
                step -= 60 - ladybug.x;
                ladybug.x = 60;
            } else if (ladybug.x > 180) {
                step -= ladybug.x - 180;
                ladybug.x = 180;
            } else if (ladybug.y < 60) {
                step -= 60 - ladybug.y;
                ladybug.y = 60;
            } else if (ladybug.y > 180) {
                step -= ladybug.y - 180;
                ladybug.y = 180;
            }

            switch (l_figure.angle) {
                case 0 :  {
                    center.x = 180;
                    center.y = 180;
                    center.angle = ((ladybug.target_angle == 180) ? 0 : 180);
                }
                case 1 :  {
                    center.x = 60;
                    center.y = 180;
                    center.angle = ((ladybug.target_angle == 180) ? 180 : 0);
                }
                case 2 :  {
                    center.x = 60;
                    center.y = 60;
                    center.angle = ((ladybug.target_angle == 0) ? 0 : 180);
                }
                case 3 :  {
                    center.x = 180;
                    center.y = 60;
                    center.angle = ((ladybug.target_angle == 360) ? 180 : 0);
                }
            }

            if (ABS(ladybug.angle - ladybug.target_angle) < step) {
                step = ABS(ladybug.angle - ladybug.target_angle);
                ladybug.angle = ladybug.target_angle;
            } else {
                //circumference of the circle is around 377 pixels. Thus, we will assume that for 1 degree the bug passes 1 pixel.
                ladybug.angle += ((ladybug.angle > ladybug.target_angle) ? -1 : 1) * step;
                ladybug.angle = ((ladybug.angle < 0) ? ladybug.angle + 360 : ladybug.angle);
                //ladybug.angle %= 360;
            }
            ladybug.x = center.x + (60 * FixedCos(ladybug.angle + center.angle) >> 8);
            ladybug.y = center.y + (60 * FixedSin(ladybug.angle + center.angle) >> 8);

            if (ladybug.angle == ladybug.target_angle) {
                step = ABS(ladybug.speed_x) + ABS(ladybug.speed_y) - step;
                switch (ladybug.angle) {
                    case 0 :  {
                        ladybug.speed_x = 0;
                        ladybug.speed_y = -SPEED;
                    }
                    case 90 :  {
                        ladybug.speed_x = SPEED;
                        ladybug.speed_y = 0;
                    }
                    case 180 :  {
                        ladybug.speed_x = 0;
                        ladybug.speed_y = SPEED;
                    }
                    case 270 :  {
                        ladybug.speed_x = -SPEED;
                        ladybug.speed_y = 0;
                    }
                    case 360 :  {
                        ladybug.speed_x = 0;
                        ladybug.speed_y = -SPEED;
                    }
                }

                ladybug.x += ((ladybug.speed_x != 0) ? GetSign(ladybug.speed_x) * step : 0) + GetSign(ladybug.speed_x) * ladybug.multiplier * MULTIPLIER_PKT;
                ladybug.y += ((ladybug.speed_y != 0) ? GetSign(ladybug.speed_y) * step : 0) + GetSign(ladybug.speed_y) * ladybug.multiplier * MULTIPLIER_PKT;

            }
            new_positions.x = ladybug.x;
            new_positions.y = ladybug.y;
        } else {
            ladybug.x = new_positions.x;
            ladybug.y = new_positions.y;
        }
    }

    new_positions.x = ladybug.x - ABS(ladybug.speed_x + ladybug.speed_y);
    new_positions.y = ladybug.y - ABS(ladybug.speed_x + ladybug.speed_y);
    last_positions.x = ladybug.x + ABS(ladybug.speed_x + ladybug.speed_y);
    last_positions.y = ladybug.y + ABS(ladybug.speed_x + ladybug.speed_y);

    CheckEating(new_positions, last_positions);

    pause = ((!((60 <= ladybug.x && 180 >= ladybug.x) && (60 <= ladybug.y && 180 >= ladybug.y)) && (ladybug.x != 120) && (ladybug.y != 120)) ? true : false);
}
CheckAngles() {
    new far_cubeN = 0;
    new tmp_cubeN = 0;
    new tmp_faceN = 0;
    new neighborCubeN;
    new neighborFaceN;
    FindNewAngles(far_cubeN);

    neighborCubeN = 0;
    neighborFaceN = 0;
    //search far far cuben relative on the 0 cube 0 face = left cube + face, left cube + face, bottom cube + face, left cube + face
    //left cube + face
    tmp_cubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    if (!(tmp_cubeN < CUBES_MAX))
        return;
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;
    tmp_cubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    if (!(tmp_cubeN < CUBES_MAX))
        return;
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;
    tmp_cubeN = abi_bottomCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_bottomFaceN(neighborCubeN, neighborFaceN);
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;
    tmp_cubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    if (!(tmp_cubeN < CUBES_MAX))
        return;
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;

    far_cubeN = neighborCubeN;

    FindNewAngles(far_cubeN);
}
FindNewAngles(farCube) {
    new angle;
    new neighborCubeN;
    new neighborFaceN;
    new tmp_cubeN = 0;
    new tmp_faceN = 0;
    for (new faceN = 0; faceN < FACES_MAX; faceN++) {
        neighborCubeN = farCube;
        neighborFaceN = faceN;
        if (farCube == abi_cubeN) {
            newAngles[faceN] = 180;
        }
        angle = 180;
        for (new count = 0; count < FACES_MAX; count++) {
            tmp_cubeN = abi_topCubeN(neighborCubeN, neighborFaceN);
            tmp_faceN = abi_topFaceN(neighborCubeN, neighborFaceN);
            angle += 90;
            if (angle == 360) {
                angle = 0;
            }
            if (!(tmp_cubeN < CUBES_MAX)) {
                break;
            }
            if (tmp_cubeN == abi_cubeN) {
                newAngles[tmp_faceN] = angle;
            }
            neighborCubeN = tmp_cubeN;
            neighborFaceN = tmp_faceN;
        }
    }
}
RotateAngle(const c_angle, & c_current_angle) {
    if (c_angle != c_current_angle) {
        if (ABS(c_angle - c_current_angle) > 180)
            c_current_angle += ANGLE_ROTATE * GetSign(c_current_angle - c_angle);
        else
            c_current_angle += ANGLE_ROTATE * GetSign(c_angle - c_current_angle);
    }
    if (c_current_angle >= 360) c_current_angle -= 360;
    else if (c_current_angle < 0) c_current_angle += 360;
}
CheckEating(curr_pos[POINT], prev_pos[POINT]) { /*

    new l_figure[LANDSCAPE_TYPE];
    l_figure = landscapes[ladybug.face][PLACE_FRUIT];
    if (l_figure.object == ENUM_FRUITS_MAX) return;

    if ((Min(curr_pos.x, prev_pos.x) <= l_figure.x) && (Max(curr_pos.x, prev_pos.x) >= l_figure.x) &&
        (Min(curr_pos.y, prev_pos.y) <= l_figure.y) && (Max(curr_pos.y, prev_pos.y) >= l_figure.y)) {
        switch (l_figure.object) {
            case 0 :  {
                game.health--;
                if (game.health < 0) {
                    //game.status = GAME_OVER;
                    game.health = 0;
                    #ifdef SOUND
                    abi_CMD_PLAYSND(SOUND_GAMEOVER, 95);
                    #endif
                } else if (game.health >= 0) {
                    #ifdef SOUND
                    abi_CMD_PLAYSND(SOUND_POISON, SOUND_VOLUME);
                    #endif
                }
            }
            default:  {
                game.score++;
                #ifdef SOUND
                abi_CMD_PLAYSND(SOUND_BERRY_EAT, SOUND_VOLUME);
                #endif
            }
        }
        landscapes[ladybug.face][PLACE_FRUIT].object = ENUM_FRUITS_MAX;
        roadway[ladybug.cube].fruit[ladybug.face] = landscapes[ladybug.face][PLACE_FRUIT].object;
    } */
}
CalcCountDown() {
    if ((!game.is_generated) || (abi_cubeN != 0)) return;
    if (game.countdown != COUNTDOWN_PLAY) {
        game.countdown = ((game.local_ticks < COUNTDOWN_PLAY * TICKS_TO_COUNTDOWN) ? COUNTDOWN_PLAY - 1 - game.local_ticks / TICKS_TO_COUNTDOWN : COUNTDOWN_PLAY);
        #ifdef SOUND
        if (game.local_ticks == (COUNTDOWN_PLAY - 1) * TICKS_TO_COUNTDOWN) {
            abi_CMD_PLAYSND(SOUND_STARTING, SOUND_VOLUME);
        }
        #endif
    }
}
GetLeftNeighbor( & l_cube, & l_face) {
    new neighbor_cube = abi_leftCubeN(l_cube, l_face);
    new neighbor_face = abi_leftFaceN(l_cube, l_face);
    l_cube = neighbor_cube;
    l_face = neighbor_face;
}
SetTitresPositions() {
    if (abi_cubeN != 0) return;
    if (!game.is_generated) return;
    if (game.status == GAME_PLAY) return;
    if (game.is_set_titres) return;

    game.titres_cube[0] = ladybug.cube;
    game.titres_face[0] = ladybug.face;
    for (new counter = 1; counter < FACES_ON_PLANE; counter++) {
        game.titres_cube[counter] = game.titres_cube[counter - 1];
        game.titres_face[counter] = game.titres_face[counter - 1];
        GetLeftNeighbor(game.titres_cube[counter], game.titres_face[counter]);
        if ((game.titres_cube[counter] >= CUBES_MAX) || (game.titres_face[counter] >= FACES_MAX))
            return;
    }
    game.is_set_titres = true;
}
//----------------Drawing functions-----------------
DrawBackgroundBitmap(l_face) {
    new l_figure[ROADS];
    new position[POINT];

    if (!game.is_generated) return;

    l_figure = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[l_face]];

    position.angle = l_figure.angle * 90;

    abi_CMD_FILL(background[game.level % MAX_LANDS].red, background[game.level % MAX_LANDS].green, background[game.level % MAX_LANDS].blue);

    switch (l_figure.road_type) {
        case CROSROAD:  {
            switch (position.angle) {
                case 0 :  {
                    position.x = 150;
                    position.y = 150;
                }
                case 90 :  {
                    position.x = 90;
                    position.y = 150;
                }
                case 180 :  {
                    position.x = 90;
                    position.y = 90;
                }
                case 270 :  {
                    position.x = 150;
                    position.y = 90;
                }
            }
            abi_CMD_BITMAP(background[game.level % MAX_LANDS].crosroad, position.x, position.y, position.angle, MIRROR_BLANK);
        }
        case STRAIGHT_ROAD:  {
            position.x = 120;
            position.y = 120;
            abi_CMD_BITMAP(background[game.level % MAX_LANDS].straight_road, position.x, position.y, position.angle, MIRROR_BLANK);
        }
        case END_OF_ROAD:  {
            position.x = 120;
            position.y = 90;
            abi_CMD_BITMAP(background[game.level % MAX_LANDS].end_of_road, position.x, position.y, position.angle, MIRROR_BLANK);
            position.y = 210;
            abi_CMD_BITMAP(background[game.level % MAX_LANDS].turning, position.x, position.y, position.angle, MIRROR_BLANK);
        }
    }
}
RememberBackGroundG2D() {

    #ifndef G2D
    return;
    #endif

    if (!game.is_generated) return;
    if (game.is_set_back) return;

    new l_figure[ROADS];
    new position[POINT];

    for (face = 0; face < FACES_MAX; face++) {

        l_figure = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[face]]; //current_roads[face] >> (abi_cubeN * 4) & 0xF;
        position.angle = l_figure.angle * 90;

        abi_CMD_G2D_BEGIN_BITMAP(face, DISPLAY_WIDTH, DISPLAY_HEIGHT, true);
        abi_CMD_G2D_ADD_RECTANGLE(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT, background[game.level % MAX_LANDS].color);

        switch (l_figure.road_type) {
            case CROSROAD:  {
                switch (position.angle) {
                    case 0 :  {
                        position.x = 150;
                        position.y = 150;
                    }
                    case 90 :  {
                        position.x = 90;
                        position.y = 150;
                    }
                    case 180 :  {
                        position.x = 90;
                        position.y = 90;
                    }
                    case 270 :  {
                        position.x = 150;
                        position.y = 90;
                    }
                }
                abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].crosroad, false, position.x, position.y, 0xFF, 0, position.angle, MIRROR_BLANK);
            }
            case STRAIGHT_ROAD:  {
                position.x = 120;
                position.y = 120;
                abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].straight_road, false, position.x, position.y, 0xFF, 0, position.angle, MIRROR_BLANK);
            }
            case END_OF_ROAD:  {
                position.x = 120;
                position.y = 90;
                abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].end_of_road, false, position.x, position.y, 0xFF, 0, position.angle, MIRROR_BLANK);
                position.y = 210;
                abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].turning, false, position.x, position.y, 0xFF, 0, position.angle, MIRROR_BLANK);
            }
        }
        abi_CMD_G2D_END();
    }
    game.is_set_back = true;
}
DrawBackgroundG2D(l_face) {
    if (!game.is_set_back) return;
    abi_CMD_G2D_ADD_SPRITE(l_face, true, 120, 120, 0xFF, 0, 0, MIRROR_BLANK); //newAngles[l_face], MIRROR_BLANK)
}
DrawLandScape(l_face) {
    #ifdef G2D
    if (!game.is_set_back) return;
    #endif

    new l_place;
    for (place_x = 0; place_x < PLACES_X; place_x++) {
        for (place_y = 0; place_y < PLACES_Y; place_y++) {
            l_place = place_x + place_y * PLACES_X;

            if (l_place == PLACE_FRUIT) continue;

            if (landscapes[l_face][l_place].object < LANDSCAPES_MAX) {
                #ifdef G2D
                abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].landscape_pic + landscapes[l_face][l_place].object,
                    false,
                    landscapes[l_face][l_place].x,
                    landscapes[l_face][l_place].y,
                    0xFF, // alpha
                    0, // color
                    landscapes[l_face][l_place].angle, //newAngles[l_face],
                    landscapes[l_face][l_place].mirror);
                #else
                abi_CMD_BITMAP(background[game.level % MAX_LANDS].landscape_pic + landscapes[l_face][l_place].object,
                    landscapes[l_face][l_place].x,
                    landscapes[l_face][l_place].y,
                    landscapes[l_face][l_place].angle, //newAngles[l_face],
                    landscapes[l_face][l_place].mirror);
                #endif
            }
        }
    }
}
DrawFruits(l_face) { 
    #ifdef G2D
    if (!game.is_set_back) return;
    #endif
    if (!game.is_generated) return;

    new l_figure = landscapes[l_face][PLACE_FRUIT].object;

    new l_road[ROADS];
    l_road = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[l_face]];

    if (l_figure < ENUM_FRUITS_MAX) {

        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].fruit_pic + l_figure,
            false,
            landscapes[l_face][PLACE_FRUIT].x + ((current_angle[l_face] == 90) ? (-(fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 270) ? (fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4) : 0),
            landscapes[l_face][PLACE_FRUIT].y + ((current_angle[l_face] == 0) ? (-(fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 180) ? (fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4) : 0),
            0xFF,
            0,
            current_angle[l_face],
            landscapes[l_face][PLACE_FRUIT].mirror);
        #else
        abi_CMD_BITMAP(background[game.level % MAX_LANDS].fruit_pic + l_figure,
            landscapes[l_face][PLACE_FRUIT].x + ((current_angle[l_face] == 90) ? (-(fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 270) ? (fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4) : 0),
            landscapes[l_face][PLACE_FRUIT].y + ((current_angle[l_face] == 0) ? (-(fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 180) ? (fruits_animation[game.local_ticks % FRUIT_ANIMATION_MAX] - 4) : 0),
            current_angle[l_face],
            landscapes[l_face][PLACE_FRUIT].mirror);
        #endif

        if (newAngles[l_face] == current_angle[l_face]) {
            #ifdef G2D
            abi_CMD_G2D_ADD_SPRITE(PIC_SHADOWS_BIG + friuts_shadows[game.local_ticks % FRUIT_ANIMATION_MAX],
                false,
                landscapes[l_face][PLACE_FRUIT].x + ((current_angle[l_face] == 90) ? -40 : (current_angle[l_face] == 270) ? 40 : 0),
                landscapes[l_face][PLACE_FRUIT].y + ((current_angle[l_face] == 0) ? 40 : (current_angle[l_face] == 180) ? -40 : 0),
                0xA0,
                0,
                current_angle[l_face],
                landscapes[l_face][PLACE_FRUIT].mirror);
            #else
            abi_CMD_BITMAP(PIC_SHADOWS_BIG + friuts_shadows[game.local_ticks % FRUIT_ANIMATION_MAX],
                landscapes[l_face][PLACE_FRUIT].x + ((current_angle[l_face] == 90) ? -40 : (current_angle[l_face] == 270) ? 40 : 0),
                landscapes[l_face][PLACE_FRUIT].y + ((current_angle[l_face] == 0) ? 40 : (current_angle[l_face] == 180) ? -40 : 0),
                current_angle[l_face],
                landscapes[l_face][PLACE_FRUIT].mirror);
            #endif
        }

    }

}
DrawHud(l_face) {
    #ifdef G2D
    if (!game.is_set_back) return;
    #endif
    if (!game.is_generated) return;
    if (game.status != GAME_PLAY) return;

    switch (newAngles[l_face]) {
        case 0 :  {
            abi_CMD_TEXT("SHAKE TO EXIT", 0, 120, 230, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        }
        case 90 :  {
            abi_CMD_TEXT("SCORE", 0, 230, 100, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            abi_CMD_TEXT_ITOA(game.score * 100, 0, 230, 180, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        }
        case 180 :  {
            abi_CMD_TEXT("LEVEL", 0, 120, 230, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            abi_CMD_TEXT_ITOA(game.level + 1, 0, 60, 230, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            #ifdef G2D
            abi_CMD_G2D_ADD_SPRITE(((game.health < 1) ? HUD_HEALTH : HUD_HEALTH_FULL), false, 225, 225, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(((game.health < 2) ? HUD_HEALTH : HUD_HEALTH_FULL), false, 195, 225, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(((game.health < 3) ? HUD_HEALTH : HUD_HEALTH_FULL), false, 225, 195, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
            abi_CMD_G2D_ADD_SPRITE(((game.health < 4) ? HUD_HEALTH : HUD_HEALTH_FULL), false, 195, 195, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
            #else
            abi_CMD_BITMAP(((game.health < 1) ? HUD_HEALTH : HUD_HEALTH_FULL), 225, 225, newAngles[l_face], MIRROR_BLANK);
            abi_CMD_BITMAP(((game.health < 2) ? HUD_HEALTH : HUD_HEALTH_FULL), 195, 225, newAngles[l_face], MIRROR_BLANK);
            abi_CMD_BITMAP(((game.health < 3) ? HUD_HEALTH : HUD_HEALTH_FULL), 225, 195, newAngles[l_face], MIRROR_BLANK);
            abi_CMD_BITMAP(((game.health < 4) ? HUD_HEALTH : HUD_HEALTH_FULL), 195, 195, newAngles[l_face], MIRROR_BLANK);
            #endif
        }
        case 270 :  {
            abi_CMD_TEXT("TIME BONUS", 0, 230, 160, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            abi_CMD_TEXT_ITOA(game.time_bonus, 0, 230, 60, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        }
    }
}
DrawTitres(l_face) {
    if (!(game.status == GAME_OVER || game.status == GAME_COMPLETE)) return;
    if (!game.is_set_titres) return;

    new bool:is_draw = true;
    for (new counter = 0; counter < FACES_ON_PLANE; counter++) {
        if ((game.titres_cube[counter] == abi_cubeN) && (game.titres_face[counter] == l_face)) {
            is_draw = true;
            break;
        }
    }

    if (is_draw) {
        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(PIC_PLATE, false, 120, 120, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
        switch (newAngles[l_face]) {
            case 0 :  {
                abi_CMD_TEXT("SHAKE", 0, 120, 90, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT("TO", 0, 120, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT("EXIT", 0, 120, 150, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            }
            case 90 :  {
                abi_CMD_TEXT("TIME", 0, 160, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT("BONUS", 0, 120, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(game.time_bonus, 0, 90, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            }
            case 180 :  {
                abi_CMD_TEXT("SCORE", 0, 120, 140, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(game.score * 100, 0, 120, 90, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            }
            case 270 :  {
                if (game.status == GAME_OVER) {
                    abi_CMD_TEXT("GAME", 0, 60, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("OVER", 0, 90, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("PLAY AGAIN", 0, 160, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                } else {
                    abi_CMD_TEXT("LEVEL", 0, 60, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("COMPLETE", 0, 90, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("NEXT LEVEL", 0, 160, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                }
            }
        }
        #else
        abi_CMD_BITMAP(PIC_PLATE, 120, 120, newAngles[l_face], MIRROR_BLANK);
        switch (newAngles[l_face]) {
            case 0 :  {
                abi_CMD_TEXT("SHAKE", 0, 120, 90, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT("TO", 0, 120, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT("EXIT", 0, 120, 150, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            }
            case 90 :  {
                abi_CMD_TEXT("TIME", 0, 160, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT("BONUS", 0, 130, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(game.time_bonus, 0, 90, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            }
            case 180 :  {
                abi_CMD_TEXT("SCORE", 0, 120, 140, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(game.score * 100, 0, 120, 90, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
            }
            case 270 :  {
                if (game.status == GAME_OVER) {
                    abi_CMD_TEXT("GAME", 0, 70, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("OVER", 0, 100, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("PLAY AGAIN", 0, 160, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                } else {
                    abi_CMD_TEXT("LEVEL ", 0, 70, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("COMPLETE", 0, 100, 120, 10, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                    abi_CMD_TEXT("LEVEL UP", 0, 160, 120, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                }
            }
        }
        #endif
    } else {
        #if defined G2D
        abi_CMD_G2D_ADD_RECTANGLE(0, 0, 240, 240, 0xC8010101);
        #endif
    }
    is_draw = false;
}
DrawLadyBug(l_face) {
    #ifdef G2D
    if (!game.is_set_back) return;
    #endif

    if (game.status != GAME_PLAY) return;

    new l_figure = PIC_LADYBUG + ((game.countdown == COUNTDOWN_PLAY) ? game.local_ticks % LADYBUG_ANIMATION_MAX : 0);

    if ((abi_cubeN == ladybug.cube) && (l_face == ladybug.face)) {
        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(l_figure, false, ladybug.x, ladybug.y, 0xFF, 0, ladybug.angle, MIRROR_BLANK);
        #else
        abi_CMD_BITMAP(l_figure, ladybug.x, ladybug.y, ladybug.angle, MIRROR_BLANK);
        #endif
    }
    if ((abi_cubeN == ladybug.dep_cube) && (l_face == ladybug.dep_face)) {
        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(l_figure, false, ladybug.dep_x, ladybug.dep_y, 0xFF, 0, ladybug.dep_angle, MIRROR_BLANK);
        #else
        abi_CMD_BITMAP(l_figure, ladybug.dep_x, ladybug.dep_y, ladybug.dep_angle, MIRROR_BLANK);
        #endif
    }
}
DrawCountDown(l_face) {
    new bool:is_draw = true;

    new neighborCubeN = ladybug.cube;
    new neighborFaceN = ladybug.face;
    //new pos_x, pos_y;
    new position[POINT];

    for (new counter = 0; counter < FACES_ON_PLANE; counter++) {
        if (neighborCubeN >= CUBES_MAX || neighborFaceN >= FACES_MAX) break;

        if ((neighborCubeN == abi_cubeN) && (neighborFaceN == l_face)) {
            is_draw = true;
            break;
        } else
            GetLeftNeighbor(neighborCubeN, neighborFaceN);
    }
    switch (game.countdown) {
        case 3 :  {
            switch (newAngles[l_face]) {
                case 0 :  {
                    position.x = 79;
                    position.y = 110;
                }
                case 90 :  {
                    position.x = 106;
                    position.y = 59;
                }
                case 180 :  {
                    position.x = 98;
                    position.y = 110;
                }
                case 270 :  {
                    position.x = 112;
                    position.y = 64;
                }
            }
        }
        case 2 :  {
            switch (newAngles[l_face]) {
                case 0 :  {
                    position.x = 66;
                    position.y = 115;
                }
                case 90 :  {
                    position.x = 113;
                    position.y = 86;
                }
                case 180 :  {
                    position.x = 55;
                    position.y = 149;
                }
                case 270 :  {
                    position.x = 106;
                    position.y = 100;
                }
            }
        }
        case 1 :  {
            switch (newAngles[l_face]) {
                case 0 :  {
                    position.x = 30;
                    position.y = 101;
                }
                case 90 :  {
                    position.x = 107;
                    position.y = 43;
                }
                case 180 :  {
                    position.x = 73;
                    position.y = 105;
                }
                case 270 :  {
                    position.x = 102;
                    position.y = 26;
                }
            }
        }
        case 0 :  {
            switch (newAngles[l_face]) {
                case 0 :  {
                    position.x = 70;
                    position.y = 39;
                }
                case 90 :  {
                    position.x = 120;
                    position.y = 120;
                }
                case 180 :  {
                    position.x = 49;
                    position.y = 86;
                }
                case 270 :  {
                    position.x = 120;
                    position.y = 120;
                }
            }
        }
    }
    if (game.countdown != COUNTDOWN_PLAY) {

        if (is_draw) {
            #if defined G2D
            abi_CMD_G2D_ADD_SPRITE(PIC_COUNTDOWN + game.countdown * 4 + newAngles[l_face] / 90, false, position.x, position.y, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
            #else
            abi_CMD_BITMAP(PIC_COUNTDOWN + game.countdown * 4 + newAngles[l_face] / 90, position.x, position.y, newAngles[l_face], MIRROR_BLANK);
            #endif
        } else {
            #if defined G2D
            abi_CMD_G2D_ADD_RECTANGLE(0, 0, 240, 240, 0xC8010101);
            #endif
        }
    }
    is_draw = false;
}
GetPlacesPosition() {
    new l_place, l_road[ROADS];
    for (face = 0; face < FACES_MAX; face++) {
        for (place_x = 0; place_x < PLACES_X; place_x++) {
            for (place_y = 0; place_y < PLACES_Y; place_y++) {

                l_road = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[face]];

                l_place = place_x + place_y * PLACES_X;

                landscapes[face][l_place].x = 120;
                landscapes[face][l_place].y = 120;
                landscapes[face][l_place].angle = 0;
                landscapes[face][l_place].mirror = MIRROR_BLANK;

                if (l_place == PLACE_FRUIT) {
                    GetFruitsPositions(landscapes[face][l_place], l_road);
                } else
                    GetLandPosiotions(landscapes[face][l_place], l_road, place_x, place_y)

            }
        }
    }
}
GetFruitsPositions(l_position[LANDSCAPE_TYPE], l_figure[ROADS]) {
    if (l_figure.road_type == CROSROAD) {
        switch (l_figure.angle) {
            case 0 :  {
                l_position.x = 138;
                l_position.y = 138;
            }
            case 1 :  {
                l_position.x = 102;
                l_position.y = 138;
            }
            case 2 :  {
                l_position.x = 102;
                l_position.y = 102;
            }
            case 3 :  {
                l_position.x = 138;
                l_position.y = 102;
            }
        }
    }
}
GetLandPosiotions(l_position[LANDSCAPE_TYPE], l_figure[ROADS], l_place_x, l_place_y) {
    switch (l_position.object / LANDSCAPE_OBJECT_TYPE_MAX) {
        case 0 :  {
            l_position.x = 120 - (1 - l_place_x) * 90;
            l_position.y = 120 - (1 - l_place_y) * 90;
        }
        case 1 :  {
            l_position.x = 120 - (1 - l_place_x) * 120;
            l_position.y = 120 - (1 - l_place_y) * 120;
        }
        case 2 :  {
            l_position.x = 120 - (1 - l_place_x) * 70;
            l_position.y = 120 - (1 - l_place_y) * 70;
        }
    }
    switch (l_figure.road_type) {
        case CROSROAD:  {
            switch (l_figure.angle) {
                case 0 :  {
                    if ((l_place_x == 0) && (l_place_y == 0))
                        l_position.angle = 90 + 45;
                    else if ((l_place_x == 2) && (l_place_y == 2))
                        l_position.angle = 270 + 45;
                    else if (l_place_x == 0)
                        l_position.angle = 90;
                    else if (l_place_y == 0)
                        l_position.angle = 180;
                }
                case 1 :  {
                    if ((l_place_x == 2) && (l_place_y == 0))
                        l_position.angle = 180 + 45;
                    else if ((l_place_x == 0) && (l_place_y == 2))
                        l_position.angle = 0 + 45;
                    else if (l_place_x == 2)
                        l_position.angle = 270;
                    else if (l_place_y == 0)
                        l_position.angle = 180;
                }
                case 2 :  {
                    if ((l_place_x == 0) && (l_place_y == 0))
                        l_position.angle = 90 + 45;
                    else if ((l_place_x == 2) && (l_place_y == 2))
                        l_position.angle = 270 + 45;
                    else if (l_place_x == 2)
                        l_position.angle = 270;
                    else if (l_place_y == 2)
                        l_position.angle = 0;
                }
                case 3 :  {
                    if ((l_place_x == 2) && (l_place_y == 0))
                        l_position.angle = 180 + 45;
                    else if ((l_place_x == 0) && (l_place_y == 2))
                        l_position.angle = 0 + 45;
                    else if (l_place_x == 2)
                        l_position.angle = 90;
                    else if (l_place_y == 0)
                        l_position.angle = 0;
                }
            }
        }
        case STRAIGHT_ROAD:  {
            if (l_figure.angle == 0 || l_figure.angle == 2) {
                if (l_place_y == 0)
                    l_position.angle = 180;
                else
                    l_position.angle = 0;

            } else if (l_figure.angle == 1 || l_figure.angle == 3) {
                if (l_place_x == 0)
                    l_position.angle = 90;
                else
                    l_position.angle = 270;
            }
        }
        case END_OF_ROAD:  {
            if (l_figure.angle == 0 || l_figure.angle == 2) {
                if (l_place_y == 0)
                    l_position.angle = 180;
                else
                    l_position.angle = 0;

            } else if (l_figure.angle == 1 || l_figure.angle == 3) {
                if (l_place_x == 0)
                    l_position.angle = 90;
                else
                    l_position.angle = 270;
            }
            if ((l_place_x == 1) && (l_place_y == 2))
                l_position.angle = 0;
        }
    }
}
//--------------Sending functions------------------
SendGameInfo() {
    if (0 != abi_cubeN) return;
    if (!game.is_generated) return;

    new data[4];
    for (cube = 0; cube < CUBES_MAX; cube++) {
        //data = [0, 0, 0, 0];
        data = SerializeGameInfo(cube);

        abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
        abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
        abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
    }
}
SendLadybug() {
    if (!((ladybug.cube == abi_cubeN) || (ladybug.is_departing))) return;

    new data[4];
    data = SerializyLadybug();

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}
SendToMaster() {
    if (abi_cubeN == 0) return;

    new data[4];
    data = SerializeToMaster();

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}
SerializeGameInfo(to_cube) {

    new data[4];
    data[0] = ((CMD_SEND_GAME_INFO & 0xFF) |
        ((game.level & 0xFF) << 8) |
        ((game.level_trying & 0xFF) << 16) |
        ((to_cube & 0x7) << 24) |
        ((game.status & 0x3) << 27));

    data[1] = ((roadway[to_cube].road_cube & 0x7) |
        ((roadway[to_cube].road_face[0] & 0x3) << 3) |
        ((roadway[to_cube].road_face[1] & 0x3) << 5) |
        ((roadway[to_cube].road_face[2] & 0x3) << 7) |
        ((roadway[to_cube].fruit[0] & 0x7) << 9) |
        ((roadway[to_cube].fruit[1] & 0x7) << 12) |
        ((roadway[to_cube].fruit[2] & 0x7) << 15) |
        ((game.countdown & 0x7) << 18));

    data[2] = ((game.time_bonus & 0x1FF) |
        ((game.score & 0x1F) << 9) |
        ((game.health & 0x7) << 14) |
        ((((game.is_set_titres) ? 1 : 0) & 0x1) << 17));

    data[3] = (((game.titres_cube[0] & 0x7)) |
        ((game.titres_cube[1] & 0x7) << 3) |
        ((game.titres_cube[2] & 0x7) << 6) |
        ((game.titres_cube[3] & 0x7) << 9) |
        ((game.titres_face[0] & 0x3) << 12) |
        ((game.titres_face[1] & 0x3) << 14) |
        ((game.titres_face[2] & 0x3) << 16) |
        ((game.titres_face[3] & 0x3) << 18)
    );
    return data;
}
DeSerializeGameInfo(const data[]) {

    if (abi_cubeN == 0) return;

    cube = ((data[1] >> 24) & 0x7);
    roadway[cube].road_cube = data[2] & 0x7;
    roadway[cube].road_face[0] = (data[2] >> 3) & 0x3;
    roadway[cube].road_face[1] = (data[2] >> 5) & 0x3;
    roadway[cube].road_face[2] = (data[2] >> 7) & 0x3;

    if (abi_cubeN != cube) return;

    game.countdown = (data[2] >> 18) & 0x7;
    game.time_bonus = data[3] & 0x1FF;
    game.score = (data[3] >> 9) & 0x1F;
    game.health = (data[3] >> 14) & 0x7;

    //if (!((abi_cubeN == ladybug.cube) && ((game.status == GAME_OVER) || (game.status == GAME_COMPLETE))))
    game.status = ((data[1] >> 27) & 0x3);

    game.is_set_titres = (((data[3] >> 17) & 0x1 == 1) ? true : false);

    //game.is_generated = ((((game.status == GAME_OVER || game.status == GAME_COMPLETE)) && (game.level_trying == ((data[1] >> 16) & 0xFF))) ? false : true);

    game.titres_cube[0] = data[4] & 0x7;
    game.titres_cube[1] = (data[4] >> 3) & 0x7;
    game.titres_cube[2] = (data[4] >> 6) & 0x7;
    game.titres_cube[3] = (data[4] >> 9) & 0x7;

    game.titres_face[0] = (data[4] >> 12) & 0x3;
    game.titres_face[1] = (data[4] >> 14) & 0x3;
    game.titres_face[2] = (data[4] >> 16) & 0x3;
    game.titres_face[3] = (data[4] >> 18) & 0x3;

    if (game.level_trying == ((data[1] >> 16) & 0xFF)) return;

    game.level = (data[1] >> 8) & 0xFF;
    game.level_trying = (data[1] >> 16) & 0xFF;

    //game.status = ((data[1] >> 27) & 0x3);

    game.is_generated = true;
    game.is_set_back = false;

    landscapes[0][PLACE_FRUIT].object = (data[2] >> 9) & 0x7;
    landscapes[1][PLACE_FRUIT].object = (data[2] >> 12) & 0x7;
    landscapes[2][PLACE_FRUIT].object = (data[2] >> 15) & 0x7;

    GenerateLandscape();
    GetPlacesPosition();
}
SerializyLadybug() {
    new data[4];
    data[0] = ((CMD_SEND_LADYBUG) |
        ((ladybug.cube & 0x7) << 8) |
        ((ladybug.face & 0x3) << 11) |
        (((ladybug.angle / 90) & 0x3) << 13) |
        ((ABS(ladybug.speed_x) & 0x7) << 15) |
        (((ladybug.speed_x < 0) ? 1 : 0) << 18) |
        ((ABS(ladybug.speed_y) & 0x7) << 19) |
        (((ladybug.speed_y < 0) ? 1 : 0) << 22) |
        ((ladybug.count_transition & 0xFF) << 23)
    );
    data[1] = (((ABS(ladybug.x) & 0xFF)) |
        (((ladybug.x < 0) ? 1 : 0) << 8) |
        ((ABS(ladybug.y) & 0xFF) << 9) |
        (((ladybug.y < 0) ? 1 : 0) << 17) |
        ((ladybug.target_angle / 90 & 0x3) << 18) |
        ((game.level_trying & 0xFF) << 20)
    );
    return data;
}
DeSerializyLadybug(const data[]) {


    if (((data[2] >> 20) & 0xFF) != game.level_trying) return;
    if ((((data[1] >> 23) & 0xFF) < ladybug.count_transition) && (((data[1] >> 23) & 0xFF) != 0)) return;

    ladybug.cube = (data[1] >> 8) & 0x7;
    ladybug.face = (data[1] >> 11) & 0x3;
    ladybug.angle = ((data[1] >> 13) & 0x3) * 90;
    ladybug.speed_x = ((data[1] >> 15) & 0x7) * ((((data[1] >> 18) & 0x1) == 1) ? -1 : 1);
    ladybug.speed_y = ((data[1] >> 19) & 0x7) * ((((data[1] >> 22) & 0x1) == 1) ? -1 : 1);
    ladybug.count_transition = (data[1] >> 23) & 0xFF;
    ladybug.is_departing = false;

    ladybug.x = (data[2] & 0xFF) * ((((data[2] >> 8) & 0x1) == 1) ? -1 : 1);
    ladybug.y = ((data[2] >> 9) & 0xFF) * ((((data[2] >> 17) & 0x1) == 1) ? -1 : 1);
    ladybug.angle = CalculateAngle();

    ladybug.target_angle = ((data[2] >> 18) & 0x3) * 90;

    if (ladybug.cube == abi_cubeN) {
        ladybug.count_transition = (ladybug.count_transition + 1) % 0xFF;
        ladybug.slippage = 0;
    }
}
SerializeToMaster() {
    new data[4];
    data[0] = ((CMD_SEND_TO_MASTER & 0xFF) |
        ((abi_cubeN & 0x7) << 8) |
        ((landscapes[0][PLACE_FRUIT].object & 0x7) << 11) |
        ((landscapes[1][PLACE_FRUIT].object & 0x7) << 14) |
        ((landscapes[2][PLACE_FRUIT].object & 0x7) << 17) |
        ((ladybug.slippage & 0x1F) << 20)
    );
    data[1] = ((game.level_trying & 0xFF) |
        ((ladybug.count_transition & 0xFF) << 8)
    );
    return data;
}
DeSerializeToMaster(const data[]) {
    if (abi_cubeN != 0) return;

    if ((((data[2] >> 8) & 0xFF) != ladybug.count_transition) || ((data[2] & 0xFF) != game.level_trying)) return;

    new l_cube = (data[1] >> 8) & 0x7;

    roadway[l_cube].fruit[0] = (data[1] >> 11) & 0x7;
    roadway[l_cube].fruit[1] = (data[1] >> 14) & 0x7;
    roadway[l_cube].fruit[2] = (data[1] >> 17) & 0x7;



    //game.status = (data[1] >> 20) & 0x3;
    if (l_cube == ladybug.cube)
        ladybug.slippage = (data[1] >> 20) & 0x1F;

}
CalculateGameStatus() {
    if (abi_cubeN != 0) return;
    if (game.countdown != COUNTDOWN_PLAY) return;

    game.health = INIT_HEALTH - (game.level + 1);
    game.score = CUBES_MAX * FACES_MAX - 1 - (game.level + 1);

    for (cube = 0; cube < CUBES_MAX; cube++) {
        for (face = 0; face < FACES_MAX; face++) {
            if (roadway[cube].fruit[face] == POISON) {
                game.health++;
            } else if (roadway[cube].fruit[face] < ENUM_FRUITS_MAX) {
                game.score--;
            }
        }
    }
    if (game.score == CUBES_MAX * FACES_MAX - 1 - (game.level + 1)) {
        game.status = GAME_COMPLETE;
        ladybug.count_transition++;
    } else if (game.health < 1) {
        game.status = GAME_OVER;
        ladybug.count_transition++;
    } else if (ladybug.slippage == SLIPPAGE_TICKS) {
        game.status = GAME_OVER;
        ladybug.count_transition++;
    }
}