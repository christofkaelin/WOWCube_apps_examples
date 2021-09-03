InitVariables() {

    delay = 0;
    game.is_set_back = false;
    game.is_generated = false;
    game.local_ticks = 0;
    game.countdown = 3;
    game.time_bonus = 500;
    game.health = INIT_HEALTH;
    game.score = 0;
    game.is_set_title = false;
    game.status = GAME_PLAY;

    cr.cube = CUBES_MAX;
    cr.face = FACES_MAX;
    cr.x = 120;
    cr.y = 120;
    cr.speed_x = 0;
    cr.speed_y = -SPEED;
    cr.angle = CalculateAngle();
    cr.target_angle = TURN_NULL;

    cr.dep_cube = CUBES_MAX;
    cr.dep_face = FACES_MAX;
    cr.dep_x = 120;
    cr.dep_y = 120;
    cr.dep_angle = cr.angle;
    cr.is_departing = false;
    cr.count_transition = 0;

    if (abi_cubeN == 0) {
        game.level_trying++;
        game.level_trying %= 0xFF;
    }

    cr.slippage = 0;

    for (cube = 0; cube < CUBES_MAX; cube++) {
        for (face = 0; face < FACES_MAX; face++) {
            roadway[cube].item[face] = ENUM_ITEMS_MAX;
        }
    }
    for (new counter = 0; counter < FACES_ON_PLANE; counter++) {
        game.title_cube[counter] = CUBES_MAX;
        game.title_face[counter] = FACES_MAX;
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

    cr.cube = start_cube;
    cr.face = start_face;

    if (cr.cube != abi_cubeN) {
        cr.is_departing = true;
        //cr.speed_y *= -1;
    }

    for (cube = 0; cube < CUBES_MAX; cube++) {
        l_cube = ((cube == cr.cube) ? 0 : ((cube == neighbor_cube) ? Random(1, CUBES_MAX - 2) : Random(1, CUBES_MAX - 1)));
        start_face = ((cube == cr.cube) ? cr.face : Random(1, FACES_MAX - 1));
        if (cube == neighbor_cube) {
            for (face = 0; face < FACES_MAX; face++) {
                l_figure = models_of_roads[l_cube][face];
                if (((l_figure.road_type == TURN) && (l_figure.angle == ANGLE_90)) ||
                    ((l_figure.road_type == TURN) && (l_figure.angle == ANGLE_180)) ||
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
    GenerateItems();
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

                if (l_place == PLACE_ITEM) continue; //center of face
                landscapes[face][l_place].object = LANDSCAPES_MAX;
                switch (l_figure.road_type) {
                    case STRAIGHT_ROAD:  {
                        if (((l_figure.angle == 0) || (l_figure.angle == 2)) && ((l_place == 3) || (l_place == 5))) continue;
                        if (((l_figure.angle == 1) || (l_figure.angle == 3)) && ((l_place == 1) || (l_place == 7))) continue;
                    }
                    case TURN:  {
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
GenerateItems() {
    new item;

    for (new counter = 0; counter < game.level + 1; counter++) {
        cube = CUBES_MAX;
        face = FACES_MAX;

        while ((cube == CUBES_MAX) && (face == FACES_MAX)) {
            cube = Random(0, CUBES_MAX - 1);
            face = Random(0, FACES_MAX - 1);

            if (((cube == cr.cube) && (face == cr.face)) || (roadway[cube].item[face] == ITEM)) {
                cube = CUBES_MAX;
                face = FACES_MAX;
            } else {
                roadway[cube].item[face] = ITEM;
            }
        }
    }
    for (cube = 0; cube < CUBES_MAX; cube++) {
        for (face = 0; face < FACES_MAX; face++) {
            new rand = random(100);
            if (rand < 15) {
                if (((cube == cr.cube) && (face == cr.face)) || (roadway[cube].item[face] == ITEM)) continue;
                item = Random(0, ENUM_ITEMS_MAX);
                roadway[cube].item[face] = item;
            }
        }
    }
    for (face = 0; face < FACES_MAX; face++) {
        landscapes[face][PLACE_ITEM].object = roadway[abi_cubeN].item[face];
    }
}
CalculateAngle() {
    if (cr.speed_x > 0) return 90;
    else if (cr.speed_x < 0) return 270;
    else if (cr.speed_y > 0) return 180;
    else if (cr.speed_y < 0) return 0;
    return 0;
}
CheckMigration() {
    if ((cr.cube != abi_cubeN) || (game.status != GAME_PLAY)) return;

    new l_cube = CUBES_MAX;
    new l_face = FACES_MAX;
    new l_figure[ROADS];

    new bool:is_migration = true;
    new l_side_to_move = MOVE_NONE;
    if ((cr.y + cr.speed_y < CAR_SIZE / 2) && (cr.speed_y < 0)) {
        l_cube = abi_topCubeN(abi_cubeN, cr.face);
        l_face = abi_topFaceN(abi_cubeN, cr.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == TURN) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_180))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180)))) {
            l_side_to_move = MOVE_TO_TOP;
        }
    } else if ((cr.x + cr.speed_x > DISPLAY_WIDTH - CAR_SIZE / 2) && (cr.speed_x > 0)) {
        l_cube = abi_rightCubeN(abi_cubeN, cr.face);
        l_face = abi_rightFaceN(abi_cubeN, cr.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == TURN) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_90))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270)))) {
            l_side_to_move = MOVE_TO_RIGHT;
        }
    } else if ((cr.y + cr.speed_y > DISPLAY_HEIGHT - CAR_SIZE / 2) && (cr.speed_y > 0)) {
        l_cube = abi_bottomCubeN(abi_cubeN, cr.face);
        l_face = abi_bottomFaceN(abi_cubeN, cr.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == TURN) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_0) || (l_figure.angle == ANGLE_180)))) {
            l_side_to_move = MOVE_TO_BOTTOM;
        }
    } else if ((cr.x + cr.speed_x < CAR_SIZE / 2) && (cr.speed_x < 0)) {
        l_cube = abi_leftCubeN(abi_cubeN, cr.face);
        l_face = abi_leftFaceN(abi_cubeN, cr.face);

        l_figure = models_of_roads[roadway[l_cube].road_cube][roadway[l_cube].road_face[l_face]];

        if (((l_figure.road_type == TURN) && ((l_figure.angle == ANGLE_180) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == STRAIGHT_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270))) ||
            ((l_figure.road_type == END_OF_ROAD) && ((l_figure.angle == ANGLE_90) || (l_figure.angle == ANGLE_270)))) {
            l_side_to_move = MOVE_TO_LEFT;
        }
    } else {
        is_migration = false;
    }

    if (l_side_to_move != MOVE_NONE) {

        cr.dep_cube = cr.cube;
        cr.dep_face = cr.face;
        cr.dep_x = cr.x;
        cr.dep_y = cr.y;
        cr.dep_speed_x = cr.speed_x;
        cr.dep_speed_y = cr.speed_y;
        cr.dep_angle = cr.angle;

        cr.cube = l_cube;
        cr.face = l_face;

        l_figure = models_of_roads[roadway[cr.cube].road_cube][roadway[cr.cube].road_face[cr.face]];
        switch (l_side_to_move) {
            case MOVE_TO_TOP:  {
                cr.x = -cr.y - SHADOW_DIST;
                cr.y = 120;
                cr.speed_x = -cr.speed_y;
                cr.speed_y = 0;
                cr.target_angle = ((l_figure.road_type != TURN) ? TURN_NULL: ((l_figure.angle == ANGLE_180) ? TURN_LEFT : TURN_RIGHT));

                cr.is_departing = true;
            }
            case MOVE_TO_RIGHT:  {
                cr.y = DISPLAY_HEIGHT + SHADOW_DIST + (DISPLAY_HEIGHT - cr.x);
                cr.x = 120;
                cr.speed_y = -cr.speed_x;
                cr.speed_x = 0;
                cr.target_angle = ((l_figure.road_type != TURN) ? TURN_NULL: ((l_figure.angle == ANGLE_90) ? TURN_LEFT : TURN_RIGHT));
            }
            case MOVE_TO_BOTTOM:  {
                cr.x = DISPLAY_WIDTH + SHADOW_DIST + (DISPLAY_WIDTH - cr.y);
                cr.y = 120;
                cr.speed_x = -cr.speed_y;
                cr.speed_y = 0;
                cr.target_angle = ((l_figure.road_type != TURN) ? TURN_NULL: ((l_figure.angle == ANGLE_0) ? TURN_LEFT : TURN_RIGHT));
            }
            case MOVE_TO_LEFT:  {
                cr.y = -cr.x - SHADOW_DIST;
                cr.x = 120;
                cr.speed_y = -cr.speed_x;
                cr.speed_x = 0;
                cr.target_angle = ((l_figure.road_type != TURN) ? TURN_NULL: ((l_figure.angle == ANGLE_270) ? TURN_LEFT : TURN_RIGHT));

                cr.is_departing = true;
            }
        }
        cr.angle = CalculateAngle();
        cr.target_angle = (cr.angle + 360 + cr.target_angle) % 360;

        cr.target_angle = (((cr.angle == 270) && (cr.target_angle == 0)) ? 360 : cr.target_angle);
        cr.angle = (((cr.angle == 0) && (cr.target_angle == 270)) ? 360 : cr.angle);

        cr.count_transition++;
        cr.count_transition %= 0xFF;
    } else if (is_migration) {
        cr.slippage++;
        if (cr.slippage == SLIPPAGE_TICKS) {
            //game.status = GAME_OVER;
            #ifdef SOUND
            abi_CMD_PLAYSND(SOUND_GAMEOVER, SOUND_VOLUME);
            #endif 
            //if (abi_cubeN == 0)
            //    cr.count_transition++;
        }
    }
}
CalcGameLogic() {
    game.local_ticks = ((game.local_ticks + 1) % (ITEM_ANIMATION_MAX * 100));

    if (abi_cubeN == 0) {
        game.time_bonus = ((game.time_bonus == 0 || game.status != GAME_PLAY || game.local_ticks % 10 != 0 || game.countdown != COUNTDOWN_PLAY) ? game.time_bonus : game.time_bonus - 1);
    }
}
CalcMoveCar(l_face) {
    if ((game.status != GAME_PLAY) || (game.countdown != COUNTDOWN_PLAY)) return;

    if ((abi_cubeN == cr.cube) && (l_face == cr.face)) {

        MoveCar();
    }
    if ((abi_cubeN == cr.dep_cube) && (l_face == cr.dep_face)) {
        cr.dep_x += cr.dep_speed_x + GetSign(cr.dep_speed_x) * cr.multiplier * MULTIPLIER_PKT;
        cr.dep_y += cr.dep_speed_y + GetSign(cr.dep_speed_y) * cr.multiplier * MULTIPLIER_PKT;


        if ((cr.dep_x < -CAR_SIZE / 2) || (cr.dep_y < -CAR_SIZE / 2)) {

            cr.dep_cube = CUBES_MAX;
            cr.dep_face = FACES_MAX;
        }
    }
}
MoveCar() {
    #define TURN_MIN 60
    #define TURN_MAX 180

    test = 9;
    //DEBUG
    cr_debug.x = cr.x;
    cr_debug.y = cr.y;
    cr_debug.angle = cr.angle;
    cr_debug.target_angle = cr.target_angle;

    new new_positions[POINT] = [0, 0, 0];
    new last_positions[POINT];

    last_positions.x = cr.x;
    last_positions.y = cr.y;

    cr.multiplier = 0;

    new_positions.x = cr.x + cr.speed_x + GetSign(cr.speed_x) * cr.multiplier * MULTIPLIER_PKT;
    new_positions.y = cr.y + cr.speed_y + GetSign(cr.speed_y) * cr.multiplier * MULTIPLIER_PKT;

    if (cr.slippage) return;

    new l_figure[ROADS];
    l_figure = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[cr.face]];

    if (l_figure.road_type == STRAIGHT_ROAD) {
        cr.x = new_positions.x;
        cr.y = new_positions.y;
    } else if (l_figure.road_type == END_OF_ROAD) {
        if ((cr.angle != 0) && (cr.y > 120)) {
            cr.angle -= 15;
            cr.speed_y = -ABS(cr.speed_y);
        } else {
            cr.x = new_positions.x;
            cr.y = new_positions.y;
        }
    } else if (l_figure.road_type == TURN) {
        if (((cr.x >= TURN_MIN) && (cr.x <= TURN_MAX) && (cr.y >= TURN_MIN) && (cr.y <= TURN_MAX)) ||
            ((new_positions.x >= TURN_MIN) && (new_positions.x <= TURN_MAX) && (new_positions.y >= TURN_MIN) && (new_positions.y <= TURN_MAX))) {

            new step = ABS(cr.speed_x) + ABS(cr.speed_y) + cr.multiplier * MULTIPLIER_PKT;
            new center[POINT];

            if (cr.x < 60) {
                step -= 60 - cr.x;
                cr.x = 60;
            } else if (cr.x > 180) {
                step -= cr.x - 180;
                cr.x = 180;
            } else if (cr.y < 60) {
                step -= 60 - cr.y;
                cr.y = 60;
            } else if (cr.y > 180) {
                step -= cr.y - 180;
                cr.y = 180;
            }
            switch (l_figure.angle) {
                case 0 :  {
                    center.x = 180;
                    center.y = 180;
                    center.angle = ((cr.target_angle == 180) ? 0 : 180);
                }
                case 1 :  {
                    center.x = 60;
                    center.y = 180;
                    center.angle = ((cr.target_angle == 180) ? 180 : 0);
                }
                case 2 :  {
                    center.x = 60;
                    center.y = 60;
                    center.angle = ((cr.target_angle == 0) ? 0 : 180);
                }
                case 3 :  {
                    center.x = 180;
                    center.y = 60;
                    center.angle = ((cr.target_angle == 360) ? 180 : 0);
                }
            }
            if (ABS(cr.angle - cr.target_angle) < step) {
                step = ABS(cr.angle - cr.target_angle);
                cr.angle = cr.target_angle;
            } else {
                //circumference of the circle is around 377 pixels. Thus, we will assume that for 1 degree the bug passes 1 pixel.
                cr.angle += ((cr.angle > cr.target_angle) ? -1 : 1) * step;
                cr.angle = ((cr.angle < 0) ? cr.angle + 360 : cr.angle);
                //cr.angle %= 360;
            }
            cr.x = center.x + (60 * FixedCos(cr.angle + center.angle) >> 8);
            cr.y = center.y + (60 * FixedSin(cr.angle + center.angle) >> 8);

            if (cr.angle == cr.target_angle) {
                step = ABS(cr.speed_x) + ABS(cr.speed_y) - step;
                switch (cr.angle) {
                    case 0 :  {
                        cr.speed_x = 0;
                        cr.speed_y = -SPEED;
                    }
                    case 90 :  {
                        cr.speed_x = SPEED;
                        cr.speed_y = 0;
                    }
                    case 180 :  {
                        cr.speed_x = 0;
                        cr.speed_y = SPEED;
                    }
                    case 270 :  {
                        cr.speed_x = -SPEED;
                        cr.speed_y = 0;
                    }
                    case 360 :  {
                        cr.speed_x = 0;
                        cr.speed_y = -SPEED;
                    }
                }
                cr.x += ((cr.speed_x != 0) ? GetSign(cr.speed_x) * step : 0) + GetSign(cr.speed_x) * cr.multiplier * MULTIPLIER_PKT;
                cr.y += ((cr.speed_y != 0) ? GetSign(cr.speed_y) * step : 0) + GetSign(cr.speed_y) * cr.multiplier * MULTIPLIER_PKT;
            }
            new_positions.x = cr.x;
            new_positions.y = cr.y;
        } else {
            cr.x = new_positions.x;
            cr.y = new_positions.y;
        }
    }

    new_positions.x = cr.x - ABS(cr.speed_x + cr.speed_y);
    new_positions.y = cr.y - ABS(cr.speed_x + cr.speed_y);
    last_positions.x = cr.x + ABS(cr.speed_x + cr.speed_y);
    last_positions.y = cr.y + ABS(cr.speed_x + cr.speed_y);

    CheckEating(new_positions, last_positions);

    pause = ((!((60 <= cr.x && 180 >= cr.x) && (60 <= cr.y && 180 >= cr.y)) && (cr.x != 120) && (cr.y != 120)) ? true : false);
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
CheckEating(curr_pos[POINT], prev_pos[POINT]) {

    new l_figure[LANDSCAPE_TYPE];
    l_figure = landscapes[cr.face][PLACE_ITEM];
    if (l_figure.object == ENUM_ITEMS_MAX) return;
    if (l_figure.object == 0) return;

    if ((Min(curr_pos.x, prev_pos.x) <= l_figure.x) && (Max(curr_pos.x, prev_pos.x) >= l_figure.x) &&
        (Min(curr_pos.y, prev_pos.y) <= l_figure.y) && (Max(curr_pos.y, prev_pos.y) >= l_figure.y)) {
        switch (l_figure.object) {
            //Bomb
            case 1 :  {
                abi_CMD_PLAYSND(SOUND_BOMB, SOUND_VOLUME);
                game.status = GAME_OVER;
                //game.is_set_back = true;
            }
            //Boost
            case 2 :  {
                abi_CMD_PLAYSND(SOUND_BOOST, SOUND_VOLUME);
                // TODO: Create new move_car function with SPEED_BOOST as offset, implement counter and revert to originial 
                //move_car function once the counter reaches 600 counter         
            }
            //Guardian
            case 3 :  {
                abi_CMD_PLAYSND(SOUND_GUARDIAN, SOUND_VOLUME);
                /*does not work yet
                guardian_is_active = true;
                ResetGuardian();*/
            }
        }
        landscapes[cr.face][PLACE_ITEM].object = ENUM_ITEMS_MAX;
        roadway[cr.cube].item[cr.face] = landscapes[cr.face][PLACE_ITEM].object;
    }
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
SetTitlePositions() {
    if (abi_cubeN != 0) return;
    if (!game.is_generated) return;
    if (game.status == GAME_PLAY) return;
    if (game.is_set_title) return;

    game.title_cube[0] = cr.cube;
    game.title_face[0] = cr.face;
    for (new counter = 1; counter < FACES_ON_PLANE; counter++) {
        game.title_cube[counter] = game.title_cube[counter - 1];
        game.title_face[counter] = game.title_face[counter - 1];
        GetLeftNeighbor(game.title_cube[counter], game.title_face[counter]);
        if ((game.title_cube[counter] >= CUBES_MAX) || (game.title_face[counter] >= FACES_MAX))
            return;
    }
    game.is_set_title = true;
}
//----------------Drawing functions-----------------
DrawBackgroundBitmap(l_face) {
    new l_figure[ROADS];
    new position[POINT];

    if (!game.is_generated) return;

    l_figure = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[l_face]];

    position.angle = l_figure.angle * 90;

    //Background as static color
    //abi_CMD_FILL(background[game.level % MAX_LANDS].red, background[game.level % MAX_LANDS].green, background[game.level % MAX_LANDS].blue);

    //Background picture as Sprite
    abi_CMD_G2D_ADD_SPRITE(PIC_BACKGROUND, false, 120, 120, 0xFF, 0, 0, MIRROR_BLANK);

    switch (l_figure.road_type) {
        case TURN:  {
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
            abi_CMD_BITMAP(background[game.level % MAX_LANDS].turn, position.x, position.y, position.angle, MIRROR_BLANK);
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

        //Background as static color
        //abi_CMD_G2D_ADD_RECTANGLE(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT, background[game.level % MAX_LANDS].color);

        //Background picture as Sprite
        abi_CMD_G2D_ADD_SPRITE(PIC_BACKGROUND, false, 120, 120, 0xFF, 0, 0, MIRROR_BLANK);

        switch (l_figure.road_type) {
            case TURN:  {
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
                abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].turn, false, position.x, position.y, 0xFF, 0, position.angle, MIRROR_BLANK);
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

            if (l_place == PLACE_ITEM) continue;

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
DrawItems(l_face) {
    #ifdef G2D
    if (!game.is_set_back) return;
    #endif
    if (!game.is_generated) return;

    new l_figure = landscapes[l_face][PLACE_ITEM].object;

    new l_road[ROADS];
    l_road = models_of_roads[roadway[abi_cubeN].road_cube][roadway[abi_cubeN].road_face[l_face]];

    if (l_figure < ENUM_ITEMS_MAX) {

        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(background[game.level % MAX_LANDS].item_pic + l_figure,
            false,
            landscapes[l_face][PLACE_ITEM].x + ((current_angle[l_face] == 90) ? (-(items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 270) ? (items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4) : 0),
            landscapes[l_face][PLACE_ITEM].y + ((current_angle[l_face] == 0) ? (-(items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 180) ? (items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4) : 0),
            0xFF,
            0,
            current_angle[l_face],
            landscapes[l_face][PLACE_ITEM].mirror);
        #else
        abi_CMD_BITMAP(background[game.level % MAX_LANDS].item_pic + l_figure,
            landscapes[l_face][PLACE_ITEM].x + ((current_angle[l_face] == 90) ? (-(items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 270) ? (items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4) : 0),
            landscapes[l_face][PLACE_ITEM].y + ((current_angle[l_face] == 0) ? (-(items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4)) : (current_angle[l_face] == 180) ? (items_animation[game.local_ticks % ITEM_ANIMATION_MAX] - 4) : 0),
            current_angle[l_face],
            landscapes[l_face][PLACE_ITEM].mirror);
        #endif

        if (newAngles[l_face] == current_angle[l_face]) {
            #ifdef G2D
            abi_CMD_G2D_ADD_SPRITE(PIC_SHADOWS_BIG + items_shadows[game.local_ticks % ITEM_ANIMATION_MAX],
                false,
                landscapes[l_face][PLACE_ITEM].x + ((current_angle[l_face] == 90) ? -40 : (current_angle[l_face] == 270) ? 40 : 0),
                landscapes[l_face][PLACE_ITEM].y + ((current_angle[l_face] == 0) ? 40 : (current_angle[l_face] == 180) ? -40 : 0),
                0xA0,
                0,
                current_angle[l_face],
                landscapes[l_face][PLACE_ITEM].mirror);
            #else
            abi_CMD_BITMAP(PIC_SHADOWS_BIG + items_shadows[game.local_ticks % ITEM_ANIMATION_MAX],
                landscapes[l_face][PLACE_ITEM].x + ((current_angle[l_face] == 90) ? -40 : (current_angle[l_face] == 270) ? 40 : 0),
                landscapes[l_face][PLACE_ITEM].y + ((current_angle[l_face] == 0) ? 40 : (current_angle[l_face] == 180) ? -40 : 0),
                current_angle[l_face],
                landscapes[l_face][PLACE_ITEM].mirror);
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

    /*switch (newAngles[l_face]) {
        case 0 :  {
            abi_CMD_TEXT("SHAKE TO EXIT", 0, 120, 230, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
        }
        case 90 :  {
            abi_CMD_TEXT("SCORE", 0, 230, 100, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            abi_CMD_TEXT_ITOA(game.score * 100, 0, 230, 180, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
        }
        case 180 :  {
            abi_CMD_TEXT("LEVEL", 0, 120, 230, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            abi_CMD_TEXT_ITOA(game.level + 1, 0, 60, 230, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
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
            abi_CMD_TEXT("TIME REMAINING", 0, 230, 150, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            abi_CMD_TEXT_ITOA(game.time_bonus, 0, 230, 30, 6, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
        }
    }*/
}
DrawTitle(l_face) {
    if (!(game.status == GAME_OVER || game.status == GAME_COMPLETE)) return;
    if (!game.is_set_title) return;

    new bool:is_draw = true;
    for (new counter = 0; counter < FACES_ON_PLANE; counter++) {
        if ((game.title_cube[counter] == abi_cubeN) && (game.title_face[counter] == l_face)) {
            is_draw = true;
            break;
        }
    }
    if (is_draw) {
        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(PIC_PLATE, false, 120, 120, 0xFF, 0, newAngles[l_face], MIRROR_BLANK);
        switch (newAngles[l_face]) {
            case 0 :  {
                abi_CMD_TEXT("SHAKE", 0, 120, 90, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT("TO", 0, 120, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT("EXIT", 0, 120, 150, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            }
            case 90 :  {
                abi_CMD_TEXT("TIME", 0, 160, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT("REMAINING", 0, 120, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT_ITOA(game.time_bonus, 0, 90, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            }
            case 180 :  {
                abi_CMD_TEXT("SCORE", 0, 120, 140, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT_ITOA(game.score * 100, 0, 120, 90, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            }
            case 270 :  {
                if (game.status == GAME_OVER) {
                    abi_CMD_TEXT("GAME", 0, 60, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("OVER", 0, 90, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("PLAY AGAIN", 0, 160, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                } else {
                    abi_CMD_TEXT("LEVEL", 0, 60, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("COMPLETE", 0, 90, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("NEXT LEVEL", 0, 160, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                }
            }
        }
        #else
        abi_CMD_BITMAP(PIC_PLATE, 120, 120, newAngles[l_face], MIRROR_BLANK);
        switch (newAngles[l_face]) {
            case 0 :  {
                abi_CMD_TEXT("SHAKE", 0, 120, 90, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT("TO", 0, 120, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT("EXIT", 0, 120, 150, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            }
            case 90 :  {
                abi_CMD_TEXT("TIME", 0, 160, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT("REMAINING", 0, 130, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT_ITOA(game.time_bonus, 0, 90, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            }
            case 180 :  {
                abi_CMD_TEXT("SCORE", 0, 120, 140, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                abi_CMD_TEXT_ITOA(game.score * 100, 0, 120, 90, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
            }
            case 270 :  {
                if (game.status == GAME_OVER) {
                    abi_CMD_TEXT("GAME", 0, 70, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("OVER", 0, 100, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("PLAY AGAIN", 0, 160, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                } else {
                    abi_CMD_TEXT("LEVEL ", 0, 70, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("COMPLETE", 0, 100, 120, 12, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("TWIST TO", 0, 140, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                    abi_CMD_TEXT("LEVEL UP", 0, 160, 120, 9, newAngles[l_face], TEXT_ALIGN_CENTER, 255, 255, 255);
                }
            }
        }
        #endif
    } else {
        #if defined G2D
        abi_CMD_G2D_ADD_RECTANGLE(0, 0, 240, 240, 0xC8010101);
        #endif
    }
    //is_draw = false;
}
DrawCar(l_face) {
    #ifdef G2D
    if (!game.is_set_back) return;
    #endif

    if (game.status != GAME_PLAY) return;

    new l_figure = PIC_CAR + ((game.countdown == COUNTDOWN_PLAY) ? game.local_ticks % CAR_ANIMATION_MAX : 0);

    if ((abi_cubeN == cr.cube) && (l_face == cr.face)) {
        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(l_figure, false, cr.x, cr.y, 0xFF, 0, cr.angle, MIRROR_BLANK);
        #else
        abi_CMD_BITMAP(l_figure, cr.x, cr.y, cr.angle, MIRROR_BLANK);
        #endif
    }
    if ((abi_cubeN == cr.dep_cube) && (l_face == cr.dep_face)) {
        #ifdef G2D
        abi_CMD_G2D_ADD_SPRITE(l_figure, false, cr.dep_x, cr.dep_y, 0xFF, 0, cr.dep_angle, MIRROR_BLANK);
        #else
        abi_CMD_BITMAP(l_figure, cr.dep_x, cr.dep_y, cr.dep_angle, MIRROR_BLANK);
        #endif
    }
}
DrawCountDown(l_face) {
    new bool:is_draw = true;

    new neighborCubeN = cr.cube;
    new neighborFaceN = cr.face;
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

                if (l_place == PLACE_ITEM) {
                    GetItemsPositions(landscapes[face][l_place], l_road);
                } else {
                    GetLandPosiotions(landscapes[face][l_place], l_road, place_x, place_y)
                }
            }
        }
    }
}
GetItemsPositions(l_position[LANDSCAPE_TYPE], l_figure[ROADS]) {
    if (l_figure.road_type == TURN) {
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
        case TURN:  {
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
SendCar() {
    if (!((cr.cube == abi_cubeN) || (cr.is_departing))) return;

    new data[4];
    data = SerializeCar();

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
        ((roadway[to_cube].item[0] & 0x7) << 9) |
        ((roadway[to_cube].item[1] & 0x7) << 12) |
        ((roadway[to_cube].item[2] & 0x7) << 15) |
        ((game.countdown & 0x7) << 18));

    data[2] = ((game.time_bonus & 0x1FF) |
        ((game.score & 0x1F) << 9) |
        ((game.health & 0x7) << 14) |
        ((((game.is_set_title) ? 1 : 0) & 0x1) << 17));

    data[3] = (((game.title_cube[0] & 0x7)) |
        ((game.title_cube[1] & 0x7) << 3) |
        ((game.title_cube[2] & 0x7) << 6) |
        ((game.title_cube[3] & 0x7) << 9) |
        ((game.title_face[0] & 0x3) << 12) |
        ((game.title_face[1] & 0x3) << 14) |
        ((game.title_face[2] & 0x3) << 16) |
        ((game.title_face[3] & 0x3) << 18)
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

    //if (!((abi_cubeN == cr.cube) && ((game.status == GAME_OVER) || (game.status == GAME_COMPLETE))))
    game.status = ((data[1] >> 27) & 0x3);

    game.is_set_title = (((data[3] >> 17) & 0x1 == 1) ? true : false);

    //game.is_generated = ((((game.status == GAME_OVER || game.status == GAME_COMPLETE)) && (game.level_trying == ((data[1] >> 16) & 0xFF))) ? false : true);

    game.title_cube[0] = data[4] & 0x7;
    game.title_cube[1] = (data[4] >> 3) & 0x7;
    game.title_cube[2] = (data[4] >> 6) & 0x7;
    game.title_cube[3] = (data[4] >> 9) & 0x7;

    game.title_face[0] = (data[4] >> 12) & 0x3;
    game.title_face[1] = (data[4] >> 14) & 0x3;
    game.title_face[2] = (data[4] >> 16) & 0x3;
    game.title_face[3] = (data[4] >> 18) & 0x3;

    if (game.level_trying == ((data[1] >> 16) & 0xFF)) return;

    game.level = (data[1] >> 8) & 0xFF;
    game.level_trying = (data[1] >> 16) & 0xFF;

    //game.status = ((data[1] >> 27) & 0x3);

    game.is_generated = true;
    game.is_set_back = false;

    landscapes[0][PLACE_ITEM].object = (data[2] >> 9) & 0x7;
    landscapes[1][PLACE_ITEM].object = (data[2] >> 12) & 0x7;
    landscapes[2][PLACE_ITEM].object = (data[2] >> 15) & 0x7;

    GenerateLandscape();
    GetPlacesPosition();
}
SerializeCar() {
    new data[4];
    data[0] = ((CMD_SEND_CAR) |
        ((cr.cube & 0x7) << 8) |
        ((cr.face & 0x3) << 11) |
        (((cr.angle / 90) & 0x3) << 13) |
        ((ABS(cr.speed_x) & 0x7) << 15) |
        (((cr.speed_x < 0) ? 1 : 0) << 18) |
        ((ABS(cr.speed_y) & 0x7) << 19) |
        (((cr.speed_y < 0) ? 1 : 0) << 22) |
        ((cr.count_transition & 0xFF) << 23)
    );
    data[1] = (((ABS(cr.x) & 0xFF)) |
        (((cr.x < 0) ? 1 : 0) << 8) |
        ((ABS(cr.y) & 0xFF) << 9) |
        (((cr.y < 0) ? 1 : 0) << 17) |
        ((cr.target_angle / 90 & 0x3) << 18) |
        ((game.level_trying & 0xFF) << 20)
    );
    return data;
}
DeSerializeCar(const data[]) {


    if (((data[2] >> 20) & 0xFF) != game.level_trying) return;
    if ((((data[1] >> 23) & 0xFF) < cr.count_transition) && (((data[1] >> 23) & 0xFF) != 0)) return;

    cr.cube = (data[1] >> 8) & 0x7;
    cr.face = (data[1] >> 11) & 0x3;
    cr.angle = ((data[1] >> 13) & 0x3) * 90;
    cr.speed_x = ((data[1] >> 15) & 0x7) * ((((data[1] >> 18) & 0x1) == 1) ? -1 : 1);
    cr.speed_y = ((data[1] >> 19) & 0x7) * ((((data[1] >> 22) & 0x1) == 1) ? -1 : 1);
    cr.count_transition = (data[1] >> 23) & 0xFF;
    cr.is_departing = false;

    cr.x = (data[2] & 0xFF) * ((((data[2] >> 8) & 0x1) == 1) ? -1 : 1);
    cr.y = ((data[2] >> 9) & 0xFF) * ((((data[2] >> 17) & 0x1) == 1) ? -1 : 1);
    cr.angle = CalculateAngle();

    cr.target_angle = ((data[2] >> 18) & 0x3) * 90;

    if (cr.cube == abi_cubeN) {
        cr.count_transition = (cr.count_transition + 1) % 0xFF;
        cr.slippage = 0;
    }
}
SerializeToMaster() {
    new data[4];
    data[0] = ((CMD_SEND_TO_MASTER & 0xFF) |
        ((abi_cubeN & 0x7) << 8) |
        ((landscapes[0][PLACE_ITEM].object & 0x7) << 11) |
        ((landscapes[1][PLACE_ITEM].object & 0x7) << 14) |
        ((landscapes[2][PLACE_ITEM].object & 0x7) << 17) |
        ((cr.slippage & 0x1F) << 20)
    );
    data[1] = ((game.level_trying & 0xFF) |
        ((cr.count_transition & 0xFF) << 8)
    );
    return data;
}
DeSerializeToMaster(const data[]) {
    if (abi_cubeN != 0) return;

    if ((((data[2] >> 8) & 0xFF) != cr.count_transition) || ((data[2] & 0xFF) != game.level_trying)) return;

    new l_cube = (data[1] >> 8) & 0x7;

    roadway[l_cube].item[0] = (data[1] >> 11) & 0x7;
    roadway[l_cube].item[1] = (data[1] >> 14) & 0x7;
    roadway[l_cube].item[2] = (data[1] >> 17) & 0x7;

    //game.status = (data[1] >> 20) & 0x3;
    if (l_cube == cr.cube)
        cr.slippage = (data[1] >> 20) & 0x1F;

}
CalculateGameStatus() {
    if (abi_cubeN != 0) return;
    if (game.countdown != COUNTDOWN_PLAY) return;
    if (game.status == GAME_OVER) return;
    if (guardian_is_active) return;

    game.health = INIT_HEALTH - (game.level + 1);

    delay++;
    if ((delay % 40) == 0) {
        game.score++;
    }
    for (cube = 0; cube < CUBES_MAX; cube++) {
        for (face = 0; face < FACES_MAX; face++) {
            if (roadway[cube].item[face] == ITEM) {
                //game.health++;
            } else if (roadway[cube].item[face] < ENUM_ITEMS_MAX) {
                //game.score--;
            }
        }
    }
    if (cr.slippage == SLIPPAGE_TICKS) {
        game.status = GAME_OVER;
        //cr.count_transition++;
    }
}
ResetGuardian() {
    if (guardian_is_active) {
        new delay = 0;
        delay++;
        if ((delay % 600) == 0) {
            guardian_is_active = false;
            abi_CMD_PLAYSND(SOUND_GUARDIAN_DROP, SOUND_VOLUME);
        }
    }
}