//drawing functions
Draw_Bitmap(pic, pos_x, pos_y, angle = 0, mirror = MIRROR_BLANK, g2d = false, alpha = 0xFF, color = 0) {
    #ifdef LAYERS
    abi_CMD_G2D_ADD_SPRITE(pic, g2d, pos_x, pos_y, alpha, color, angle, mirror);
    #else
    abi_CMD_BITMAP(pic, pos_x, pos_y, angle, mirror);
    #endif
}
DrawBegin() {
    #ifdef LAYERS
    abi_CMD_G2D_BEGIN_DISPLAY(g_face, true);
    #endif
}
DrawEnd() {
    #ifdef LAYERS
    abi_CMD_G2D_END();
    #else
    abi_CMD_REDRAW(g_face);
    #endif
}
DrawHUD() {
    DrawNumber(VERSION_TEST, NUMBER0, 220, 120, 20, 0, newAngles[g_face]);
}
DrawBackGround() {
    RememberBackGroundLayers();

    #ifdef LAYERS
    if (is_set_background[g_face])
        abi_CMD_G2D_ADD_SPRITE(g_face, true, 120, 120, 0xFF, 0, 0, MIRROR_BLANK);
    #endif
}
DrawBall() {
    if (isMyObject(ball_object)) {
        GetPositions(ball_object);
        GetSpeeds(ball_movings);
    } else if (isMyObject(ball_object)) {
        GetPositions(ball_object_dep);
        GetSpeeds(ball_movings_dep);
    } else {
        return;
    }
    Draw_Bitmap(BALL_PIC, g_pos_x, g_pos_y, g_angle, MIRROR_BLANK);
}
DrawNumber(const c_number, const c_num0_pic, const c_x, const c_y, const c_shift_x, const c_shift_y, const c_angle, const digits = 0) {
    new base = 10;
    new x = c_x;
    new y = c_y;
    new number = ABS(c_number);
    //new tmp = c_number;
    while (base <= number) {
        base *= 10;
        x -= c_shift_x / 2;
        y -= c_shift_y / 2;
    }
    //base /= 10;
    base = (((digits != 0) && (base < pow(10, digits))) ? pow(10, digits) : base);
    #ifdef PIC_MINUS
    if (c_number < 0)
        Draw_Bitmap(PIC_MINUS, x - c_shift_x, y - c_shift_y, c_angle);
    #endif
    while (base >= 10) {
        base /= 10;
        Draw_Bitmap(c_num0_pic + number / base % 10, x, y, c_angle);
        x += c_shift_x;
        y += c_shift_y;
    }
}
DrawPerks() {
    if (get_perk_value(perks[g_face]) == 0xF) return;

    Draw_Bitmap(PIC_PERK + get_perk_value(perks[g_face]), get_perk_posx(perks[g_face]), get_perk_posy(perks[g_face]), get_perk_angle(perks[g_face]), MIRROR_BLANK);

    perks[g_face] = set_perk_angle(perks[g_face], (get_perk_angle(perks[g_face]) + get_perk_rotation(perks[g_face])) % 360);
}
DrawResults() {
    if (!is_gameover) return;

    switch (newAngles[g_face]) {
        case 0 :  {
            Draw_Bitmap(PONG_MOVES, 120, 60, newAngles[g_face]);
            DrawNumber(count_moves, NUMBER0, 120, 120, 22, 0, newAngles[g_face]);
        }
        case 90 :  {
            Draw_Bitmap(PONG_SCORE, 180, 120, newAngles[g_face]);
            DrawNumber(INITAL_SCORE - count_moves * 100 - local_ticks / 10, NUMBER0, 120, 120, 0, 22, newAngles[g_face]);
        }
        case 180 :  {
            Draw_Bitmap(PONG_LOGO, 120, 120, newAngles[g_face]);
        }
        case 270 :  {
            DrawNumber(local_ticks / 60 / 10, NUMBER0, 120, (((local_ticks / 60 / 10) < 100) ? 160 : 160), 0, -22, newAngles[g_face], 2);
            DrawNumber(local_ticks / 10 % 60, NUMBER0, 120, 100, 0, -22, newAngles[g_face], 2);
            Draw_Bitmap(PONG_COLON, 120, 120, newAngles[g_face]);
            Draw_Bitmap(PONG_TIME, 60, 120, newAngles[g_face]);
        }
    }
}
//draw background in buffer layers
RememberBackGroundLayers() {
    new wall_type = (walls[g_face] >> (abi_cubeN * 4)) & 0xF;
    #ifdef LAYERS
    if (is_set_background[g_face]) return;

    
    if (wall_type == 0xF) return;

    abi_CMD_G2D_END();
    abi_CMD_G2D_BEGIN_BITMAP(g_face, 240, 240, true);
    // Draw_Bitmap(BACKGROUND, 120, 120);
    #endif

    Draw_Bitmap(BACKGROUND, 120, 120);
    //top ribn
    switch (wall_type & 0x3) {
        case WALL_HALF_CENTER:  {
            Draw_Bitmap(PIC_WALL_HALF, 60, 13, 90);
        }
        case WALL_HALF_EDGE:  {
            Draw_Bitmap(PIC_WALL_HALF, 180, 13, 90, MIRROR_Y);
        }
        case WALL_FULL:  {
            Draw_Bitmap(PIC_WALL_FULL, 120, 13, 90);
        }
    }
    //left ribn
    switch ((wall_type >> 2) & 0x3) {
        case WALL_HALF_CENTER:  {
            Draw_Bitmap(PIC_WALL_HALF, 13, 60, 0, MIRROR_Y);
        }
        case WALL_HALF_EDGE:  {
            Draw_Bitmap(PIC_WALL_HALF, 13, 180, 0);
        }
        case WALL_FULL:  {
            Draw_Bitmap(PIC_WALL_FULL, 13, 120, 0);
        }
    }

    Draw_Bitmap(PIC_WALL_FULL, 240 - 13, 120, 180);
    Draw_Bitmap(PIC_WALL_FULL, 120, 240 - 13, 270);


    #ifdef LAYERS
    is_set_background[g_face] = true;

    abi_CMD_G2D_END();
    abi_CMD_G2D_BEGIN_DISPLAY(g_face, true);
    #endif
}
GetPositions(object) {
    g_pos_x = get_posx(object);
    g_pos_y = get_posy(object);
    g_angle = get_angle(object);
}
GetSpeeds(object) {
    g_speed_x = get_speedx(object);
    g_speed_y = get_speedy(object);
    g_angular = get_angular(object);
}
isMyObject(object) {
    return ((abi_cubeN == get_cube(object)) && (g_face == get_face(object)));
}
CheckDepaturing() {
    if (isMyObject(ball_object)) {
        GetPositions(ball_object);
        GetSpeeds(ball_movings);
    } else {
        return;
    }
    new neighbour_cube;
    new neighbour_face;
    new tmp;

    if ((g_pos_x < -SHADOW_DIST) && (g_speed_x < 0)) {
        neighbour_cube = abi_leftCubeN(abi_cubeN, g_face);
        neighbour_face = abi_leftFaceN(abi_cubeN, g_face);
        SetDeparting();
        tmp = g_pos_x;
        g_pos_x = g_pos_y;
        g_pos_y = tmp - (SHADOW_DIST + tmp);
        tmp = g_speed_x;
        g_speed_x = g_speed_y;
        g_speed_y = ABS(tmp);

        ball_object = set_cube(ball_object, neighbour_cube);
        ball_object = set_face(ball_object, neighbour_face);
        ball_object = set_posx(ball_object, g_pos_x);
        ball_object = set_posy(ball_object, g_pos_y);

        ball_movings = set_speedx(ball_movings, g_speed_x);
        ball_movings = set_speedy(ball_movings, g_speed_y);
    } else if ((g_pos_y < -SHADOW_DIST) && (g_speed_y < 0)) {
        neighbour_cube = abi_topCubeN(abi_cubeN, g_face);
        neighbour_face = abi_topFaceN(abi_cubeN, g_face);
        SetDeparting();
        tmp = g_pos_y;
        g_pos_y = g_pos_x;
        g_pos_x = tmp - (SHADOW_DIST + tmp);
        tmp = g_speed_y;
        g_speed_y = g_speed_x;
        g_speed_x = ABS(tmp);

        ball_object = set_cube(ball_object, neighbour_cube);
        ball_object = set_face(ball_object, neighbour_face);
        ball_object = set_posx(ball_object, g_pos_x);
        ball_object = set_posy(ball_object, g_pos_y);

        ball_movings = set_speedx(ball_movings, g_speed_x);
        ball_movings = set_speedy(ball_movings, g_speed_y);
    }
}
SetDeparting() {
    ball_object_dep = ball_object;
    ball_movings_dep = ball_movings;
    is_dep = true;
    count_movings = (((!is_gameover) && (count_movings < 0xFF)) ? count_movings + 1 : 0);
    pause = true;
}
NormalizeVector( & vx, & vy, const vector) {
    //normalize the speed vector
    new dist = int_sqrt(vx * vx + vy * vy);
    if (vector * dist == 0) return;

    if (dist - vector > 0) {
        vx = vx * vector / dist;
        vy = vy * vector / dist;
    }

}
//moving ball and calculate collision
MoveBall() {
    if (isMyObject(ball_object)) {
        GetPositions(ball_object);
        GetSpeeds(ball_movings);
    } else {
        return;
    }

    new collision_x, collision_y, collision2_x, collision2_y;
    new count_collisions = 0;
    new speed_x = g_speed_x, speed_y = g_speed_y;

    new acceleration_x = abi_MTD_GetFaceAccelX(g_face);
    new acceleration_y = abi_MTD_GetFaceAccelY(g_face);
    new distance = 0xFFFF; //BALL_RADIUS * BALL_RADIUS;

    new bool:is_first = false;
    new bool:check_diameter = false;

    ccols = 0;

    new wall_type = (walls[g_face] >> (abi_cubeN * 4)) & 0xF;

    //check top side//top ribn
    switch (wall_type & 0x3) {
        case WALL_HALF_CENTER:  {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_half_center_top, sizeof(wall_half_center_top),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        }
        case WALL_HALF_EDGE:  {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_half_edge_top, sizeof(wall_half_edge_top),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        }
        case WALL_FULL:  {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_full_top, sizeof(wall_full_top),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        }
    }

    //check right side
    CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
        g_speed_x, g_speed_y, acceleration_x, acceleration_y,
        wall_full_right, sizeof(wall_full_right),
        collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);

    //check bottom side
    CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
        g_speed_x, g_speed_y, acceleration_x, acceleration_y,
        wall_full_bottom, sizeof(wall_full_bottom),
        collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);

    //check left side
    switch ((wall_type >> 2) & 0x3) {
        case WALL_HALF_CENTER:  {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_half_center_left, sizeof(wall_half_center_left),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        }
        case WALL_HALF_EDGE:  {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_half_edge_left, sizeof(wall_half_edge_left),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        }
        case WALL_FULL:  {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_full_left, sizeof(wall_full_left),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        }
    }

    new neighbour_cube = abi_topCubeN(abi_cubeN, g_face);
    new neighbour_face = abi_topFaceN(abi_cubeN, g_face);
    new diameter_cube = CUBES_MAX;
    new diameter_face = FACES_MAX;

    if ((neighbour_cube < CUBES_MAX) && (neighbour_face < FACES_MAX)) {
        wall_type = (walls[neighbour_face] >> (neighbour_cube * 4 + 2)) & 0x3;
        //check top side//top ribn
        switch (wall_type & 0x3) {
            case WALL_HALF_CENTER:  {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_half_center_top_neighbour, sizeof(wall_half_center_top_neighbour),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
            case WALL_HALF_EDGE:  {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_half_edge_top_neighbour, sizeof(wall_half_edge_top_neighbour),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
            case WALL_FULL:  {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_full_top_neighbour, sizeof(wall_full_top_neighbour),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
        }
        wall_type = (walls[neighbour_face] >> (neighbour_cube * 4)) & 0x3;
        if (wall_type == WALL_HALF_CENTER || wall_type == WALL_FULL)
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_egde_full_top_top_neigh, sizeof(wall_egde_full_top_top_neigh),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);

        diameter_cube = abi_topCubeN(neighbour_cube, neighbour_face);
        diameter_face = abi_topFaceN(neighbour_cube, neighbour_face);
    } else {
        CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
            g_speed_x, g_speed_y, acceleration_x, acceleration_y,
            walls_no_neighbour_top, sizeof(walls_no_neighbour_top),
            collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
    }



    //check diameter face through top top face
    if ((diameter_cube < CUBES_MAX) && (diameter_face < FACES_MAX)) {

        check_diameter = true; // we check diameter face from top face. we dont check diameter from left
        wall_type = (walls[diameter_face] >> (diameter_cube * 4 + 2)) & 0x3;
        if (wall_type == WALL_HALF_CENTER || wall_type == WALL_FULL) {
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_diameter, sizeof(wall_diameter),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
        } else {
            wall_type = (walls[diameter_face] >> (diameter_cube * 4)) & 0x3;
            if (wall_type == WALL_HALF_CENTER || wall_type == WALL_FULL) {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_diameter, sizeof(wall_diameter),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
        }
    }

    neighbour_cube = abi_leftCubeN(abi_cubeN, g_face);
    neighbour_face = abi_leftFaceN(abi_cubeN, g_face);

    if ((neighbour_cube < CUBES_MAX) && (neighbour_face < FACES_MAX)) {
        wall_type = (walls[neighbour_face] >> (neighbour_cube * 4)) & 0x3;
        //check top side//top ribn
        switch (wall_type & 0x3) {
            case WALL_HALF_CENTER:  {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_half_center_left_neighbour, sizeof(wall_half_center_left_neighbour),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
            case WALL_HALF_EDGE:  {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_half_edge_left_neighbour, sizeof(wall_half_edge_left_neighbour),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
            case WALL_FULL:  {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_full_left_neighbour, sizeof(wall_full_left_neighbour),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            }
        }
        wall_type = (walls[neighbour_face] >> (neighbour_cube * 4 + 2)) & 0x3;
        if (wall_type == WALL_HALF_CENTER || wall_type == WALL_FULL)
            CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                wall_egde_full_left_left_neigh, sizeof(wall_egde_full_left_left_neigh),
                collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
    } else {
        CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
            g_speed_x, g_speed_y, acceleration_x, acceleration_y,
            walls_no_neighbour_left, sizeof(walls_no_neighbour_left),
            collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
    }

    if ((!check_diameter) && (neighbour_cube < CUBES_MAX) && (neighbour_face < FACES_MAX)) {
        diameter_cube = abi_leftCubeN(neighbour_cube, neighbour_face);
        diameter_face = abi_leftFaceN(neighbour_cube, neighbour_face);

        //check diameter face through left left face
        if ((diameter_cube < CUBES_MAX) && (diameter_face < FACES_MAX)) {

            check_diameter = true; // we check diameter face from top face. we dont check diameter from left
            wall_type = (walls[diameter_face] >> (diameter_cube * 4 + 2)) & 0x3;
            if (wall_type == WALL_HALF_CENTER || wall_type == WALL_FULL) {
                CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                    g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                    wall_diameter, sizeof(wall_diameter),
                    collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
            } else {
                wall_type = (walls[diameter_face] >> (diameter_cube * 4)) & 0x3;
                if (wall_type == WALL_HALF_CENTER || wall_type == WALL_FULL) {
                    CheckCollisionCicleAndFigure(g_pos_x, g_pos_y, BALL_RADIUS,
                        g_speed_x, g_speed_y, acceleration_x, acceleration_y,
                        wall_diameter, sizeof(wall_diameter),
                        collision_x, collision_y, collision2_x, collision2_y, distance, count_collisions, is_first);
                }
            }
        }
    }

    //debug
    colx = collision_x;
    coly = collision_y;
    px = g_pos_x;
    py = g_pos_y;
    sx = g_speed_x;
    sy = g_speed_y;
    testing = is_first;

    //normalize accelarator vector
    distance = int_sqrt(acceleration_x * acceleration_x + acceleration_y * acceleration_y);
    NormalizeVector(acceleration_x, acceleration_y, ((distance > BALL_ACC_MAX) ? BALL_ACC_MAX : distance));

    if (count_collisions == 0) {
        g_pos_x += g_speed_x;
        g_pos_y += g_speed_y;

        speed_x += acceleration_x;
        speed_y += acceleration_y;
        distance = int_sqrt(speed_x * speed_x + speed_y * speed_y);
        //NormalizeVector(speed_x, speed_y, BALL_SPEED_MAX);
        NormalizeVector(speed_x, speed_y, ((distance > BALL_SPEED_MAX) ? BALL_SPEED_MAX : distance));
    } else if (count_collisions == 1) {
        CalcVelNPos(g_pos_x + ((is_first) ? 0 : g_speed_x), g_pos_y + ((is_first) ? 0 : g_speed_y), collision_x, collision_y, speed_x, speed_y);

        g_pos_x = collision_x;
        g_pos_y = collision_y;

        speed_x += acceleration_x;
        speed_y += acceleration_y;
        distance = int_sqrt(speed_x * speed_x + speed_y * speed_y);
        NormalizeVector(speed_x, speed_y, BALL_SPEED_MAX);
        #ifdef SOUND
        abi_CMD_PLAYSND(SOUND_COLLIDE, SOUND_VOLUME);
        #endif
    } else {
        speed_x = -g_speed_x / SLOWING;
        speed_y = -g_speed_y / SLOWING;
        //new pos_x = g_pos_x;
        //new pos_y = g_pos_y;
        //g_pos_x = collision_x + (((collision2_x - collision_x) * (collision_x - collision2_x) + (collision2_y - collision_y) * (collision_y - collision2_y)) / 2 * (collision_x - collision2_x) - GetSign((-(pos_x - collision_x) * (collision_y - collision2_y) + (pos_y - collision_y) * (collision_x - collision2_x))) * int_sqrt(BALL_RADIUS * BALL_RADIUS * ((collision2_x - collision_x) * (collision2_x - collision_x) + (collision2_y - collision_y) * (collision2_y - collision_y)) - ((collision2_x - collision_x) * (collision_x - collision2_x) + (collision2_y - collision_y) * (collision_y - collision2_y)) * ((collision2_x - collision_x) * (collision_x - collision2_x) + (collision2_y - collision_y) * (collision_y - collision2_y)) / 4) * (collision_y - collision2_y)) / ((collision2_x - collision_x) * (collision2_x - collision_x) + (collision2_y - collision_y) * (collision2_y - collision_y));
        //g_pos_y = collision_y + (((collision2_x - collision_x) * (collision_x - collision2_x) + (collision2_y - collision_y) * (collision_y - collision2_y)) / 2 * (collision_y - collision2_y) + (GetSign((-(pos_x - collision_x) * (collision_y - collision2_y) + (pos_y - collision_y) * (collision_x - collision2_x))) * int_sqrt(BALL_RADIUS * BALL_RADIUS * ((collision2_x - collision_x) * (collision2_x - collision_x) + (collision2_y - collision_y) * (collision2_y - collision_y)) - ((collision2_x - collision_x) * (collision_x - collision2_x) + (collision2_y - collision_y) * (collision_y - collision2_y)) * ((collision2_x - collision_x) * (collision_x - collision2_x) + (collision2_y - collision_y) * (collision_y - collision2_y)) / 4)) * (collision_x - collision2_x)) / ((collision2_x - collision_x) * (collision2_x - collision_x) + (collision2_y - collision_y) * (collision2_y - collision_y));
        #ifdef SOUND
        abi_CMD_PLAYSND(SOUND_COLLIDE, SOUND_VOLUME);
        #endif
    }

    //pause = (((count_collisions > 0) && ((g_pos_x < 0) || (g_pos_y < 0))) ? true :false);
    //pause = (((count_collisions > 0) && ((g_pos_x > 240 - BALL_RADIUS - 26) || (g_pos_y > 240 - BALL_RADIUS - 26))) ? true :pause);

    //pause = ((count_collisions > 0) ? true :false);
    //pause = ((is_first) ? true :false);

    //debug
    nsx = speed_x;
    nsy = speed_y;
    npx = g_pos_x;
    npy = g_pos_y;
    ccols = count_collisions;

    //if(isMyObject(ball_object)) {
    ball_object_dep = ball_object;
    ball_movings_dep = ball_movings;
    ball_object = set_posx(ball_object, g_pos_x);
    ball_object = set_posy(ball_object, g_pos_y);
    ball_movings = set_speedx(ball_movings, speed_x);
    ball_movings = set_speedy(ball_movings, speed_y);
    //}
}
CheckCollidePerk() {
    if (!isMyObject(ball_object)) return;
    if (get_perk_value(perks[g_face]) == 0xF) return;

    new pos_x, pos_y, check_only_first = false;

    if (CheckCollisionCicleAndSegment(get_perk_posx(perks[g_face]), get_perk_posy(perks[g_face]), BALL_RADIUS + PERK_RADIUS,
            0, 0, get_posx(ball_object_dep), get_posy(ball_object_dep), get_posx(ball_object), get_posy(ball_object), pos_x, pos_y, check_only_first)) {
        perks[g_face] = set_perk_value(perks[g_face], 0xF);
    }
}
GenerateWalls() {
    new wall_type;
    walls = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];
    for (new l_cube = 0; l_cube < CUBES_MAX; l_cube++) {
        for (g_face = 0; g_face < FACES_MAX; g_face++) {
            walls[g_face] &= ~(0xF << (l_cube * 4));
            wall_type = Random(WALL_NO, WALL_FULL);
            walls[g_face] |= wall_type << (l_cube * 4); //top side
            wall_type = ((wall_type == WALL_FULL) ? Random(WALL_NO, WALL_FULL - 1) : Random(WALL_NO, WALL_FULL));
            walls[g_face] |= wall_type << (l_cube * 4 + 2); //left side
        }
    }
}
GeneratePerks() {
    for (g_face = 0; g_face < FACES_MAX; g_face++)
        perks[g_face] = set_perk(Random(0, PERKS_MAX), Random(65, 175), Random(65, 175), Random(0, 360), Random(1, 7));
}
//sendding functions
SendWalls() {
    if (0 != abi_cubeN) return;
    if (get_cube(ball_object) >= CUBES_MAX) return;
    new data[4];

    data[0] = ((CMD_SEND_WALLS & 0xFF) | ((level & 0xFF) << 8));
    for (g_face = 0; g_face < FACES_MAX; g_face++) {
        data[g_face + 1] = walls[g_face];
    }

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}
SendBall() {
    new data[4];

    data[0] = ((CMD_SEND_BALL & 0xFF) | (get_cube(ball_object) << 8) | ((level & 0xFF) << 16) | ((count_movings & 0xFF) << 24));
    data[1] = ball_object;
    data[2] = ball_movings;

    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}
SendStatus() {
    new data[4];
    if ((abi_cubeN == 0) && (get_perk_value(perks[0]) == 0xF) && (get_perk_value(perks[1]) == 0xF) && (get_perk_value(perks[2]) == 0xF)) {
        count_all_perks &= ~1;
    }

    data[0] = ((CMD_STATUS & 0xFF) |
        ((abi_cubeN & 0x7) << 8) |
        (((get_perk_value(perks[0]) == 0xF) ? 0 : 1) << 11) |
        (((get_perk_value(perks[1]) == 0xF) ? 0 : 1) << 12) |
        (((get_perk_value(perks[2]) == 0xF) ? 0 : 1) << 13) |
        (((is_gameover) ? 1 : 0) << 14) |

        ((level & 0xFF) << 16) |
        ((count_rotation & 0xFF) << 24)
    );
    data[1] = local_ticks;
    data[2] = count_moves;
    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2

}
//initial functions
SetSegment(const x1, const y1, const x2, y2) {
    #define SignBit(%0) ((%0 < 0) ? 1 :0)
    return (
        ((SignBit(x1) << 7 | ((ABS(x1) / 2) & 0x7F)) << 0) |
        ((SignBit(y1) << 7 | ((ABS(y1) / 2) & 0x7F)) << 8) |
        ((SignBit(x2) << 7 | ((ABS(x2) / 2) & 0x7F)) << 16) |
        ((SignBit(y2) << 7 | ((ABS(y2) / 2) & 0x7F)) << 24)
    );
}
SetWallObjects() {
    // full wall on top checked
    wall_full_top[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, 240, -SHADOW_DIST);
    wall_full_top[1] = SetSegment(-SHADOW_DIST, PONG_WALL_HEIGHT, 240, PONG_WALL_HEIGHT);
    wall_full_top[2] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, PONG_WALL_HEIGHT);
    wall_full_top[3] = SetSegment(240, -SHADOW_DIST, 240, PONG_WALL_HEIGHT);

    //full wall on right 
    wall_full_right[0] = SetSegment(240, -SHADOW_DIST, 240, 240);
    wall_full_right[1] = SetSegment(240 - PONG_WALL_HEIGHT, -SHADOW_DIST, 240 - PONG_WALL_HEIGHT, 240);
    wall_full_right[2] = SetSegment(240 - PONG_WALL_HEIGHT, -SHADOW_DIST, 240, -SHADOW_DIST);
    wall_full_right[3] = SetSegment(240 - PONG_WALL_HEIGHT, 240, 240, 240);

    //full wall on bottom
    wall_full_bottom[0] = SetSegment(-SHADOW_DIST, 240, 240, 240);
    wall_full_bottom[1] = SetSegment(-SHADOW_DIST, 240 - PONG_WALL_HEIGHT, 240, 240 - PONG_WALL_HEIGHT);
    wall_full_bottom[2] = SetSegment(-SHADOW_DIST, 240 - PONG_WALL_HEIGHT, -SHADOW_DIST, 240);
    wall_full_bottom[3] = SetSegment(240, 240 - PONG_WALL_HEIGHT, 240, 240);

    //full wall on left
    wall_full_left[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, 240);
    wall_full_left[1] = SetSegment(PONG_WALL_HEIGHT, -SHADOW_DIST, PONG_WALL_HEIGHT, 240);
    wall_full_left[2] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, PONG_WALL_HEIGHT, -SHADOW_DIST);
    wall_full_left[3] = SetSegment(-SHADOW_DIST, 240, PONG_WALL_HEIGHT, 240);

    //half wall from center on top
    wall_half_center_top[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, 120, -SHADOW_DIST);
    wall_half_center_top[1] = SetSegment(-SHADOW_DIST, PONG_WALL_HEIGHT, 120, PONG_WALL_HEIGHT);
    wall_half_center_top[2] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, PONG_WALL_HEIGHT);
    wall_half_center_top[3] = SetSegment(120, -SHADOW_DIST, 120, PONG_WALL_HEIGHT);

    //half wall from edge on top
    wall_half_edge_top[0] = SetSegment(120, -SHADOW_DIST, 240, -SHADOW_DIST);
    wall_half_edge_top[1] = SetSegment(120, PONG_WALL_HEIGHT, 240, PONG_WALL_HEIGHT);
    wall_half_edge_top[2] = SetSegment(120, -SHADOW_DIST, 120, PONG_WALL_HEIGHT);
    wall_half_edge_top[3] = SetSegment(240, -SHADOW_DIST, 240, PONG_WALL_HEIGHT);

    //half wall from center on left
    wall_half_center_left[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, 120);
    wall_half_center_left[1] = SetSegment(PONG_WALL_HEIGHT, -SHADOW_DIST, PONG_WALL_HEIGHT, 120);
    wall_half_center_left[2] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, PONG_WALL_HEIGHT, -SHADOW_DIST);
    wall_half_center_left[3] = SetSegment(-SHADOW_DIST, 120, PONG_WALL_HEIGHT, 120);

    //half wall from edge on left
    wall_half_edge_left[0] = SetSegment(-SHADOW_DIST, 120, -SHADOW_DIST, 240);
    wall_half_edge_left[1] = SetSegment(PONG_WALL_HEIGHT, 120, PONG_WALL_HEIGHT, 240);
    wall_half_edge_left[2] = SetSegment(-SHADOW_DIST, 120, PONG_WALL_HEIGHT, 120);
    wall_half_edge_left[3] = SetSegment(-SHADOW_DIST, 240, PONG_WALL_HEIGHT, 240);

    //walls when no neighbours at side
    walls_no_neighbour_top[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, 240, -SHADOW_DIST); //top
    walls_no_neighbour_left[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, 240); //left

    //heighbours walls
    // full wall on top
    wall_full_top_neighbour[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, 240, -SHADOW_DIST);

    //full wall on left
    wall_full_left_neighbour[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, 240);

    //half wall from center on top
    wall_half_center_top_neighbour[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, 120, -SHADOW_DIST);
    wall_half_center_top_neighbour[1] = SetSegment(-SHADOW_DIST, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT);
    wall_half_center_top_neighbour[2] = SetSegment(120, -SHADOW_DIST, 120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT);
    wall_half_center_top_neighbour[3] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, -2 * SHADOW_DIST - PONG_WALL_HEIGHT);

    //half wall from edge on top
    wall_half_edge_top_neighbour[0] = SetSegment(120, -SHADOW_DIST, 240, -SHADOW_DIST);
    wall_half_edge_top_neighbour[1] = SetSegment(120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 240, -2 * SHADOW_DIST - PONG_WALL_HEIGHT);
    wall_half_edge_top_neighbour[2] = SetSegment(120, -SHADOW_DIST, 120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT);
    wall_half_edge_top_neighbour[3] = SetSegment(240, -SHADOW_DIST, 240, -2 * SHADOW_DIST - PONG_WALL_HEIGHT);

    //half wall from center on left
    wall_half_center_left_neighbour[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, 120);
    wall_half_center_left_neighbour[1] = SetSegment(-2 * SHADOW_DIST - PONG_WALL_HEIGHT, -SHADOW_DIST, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 120);
    wall_half_center_left_neighbour[2] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, -SHADOW_DIST);
    wall_half_center_left_neighbour[3] = SetSegment(-SHADOW_DIST, 120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 120);

    //half wall from edge on left
    wall_half_edge_left_neighbour[0] = SetSegment(-SHADOW_DIST, 120, -SHADOW_DIST, 240);
    wall_half_edge_left_neighbour[1] = SetSegment(-2 * SHADOW_DIST - PONG_WALL_HEIGHT, 120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 240);
    wall_half_edge_left_neighbour[2] = SetSegment(-SHADOW_DIST, 120, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 120);
    wall_half_edge_left_neighbour[3] = SetSegment(-SHADOW_DIST, 240, -2 * SHADOW_DIST - PONG_WALL_HEIGHT, 240);

    //wall_egde_full_top_top_neighbour
    wall_egde_full_top_top_neigh[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, PONG_WALL_HEIGHT, -SHADOW_DIST);
    wall_egde_full_top_top_neigh[1] = SetSegment(PONG_WALL_HEIGHT, -SHADOW_DIST, PONG_WALL_HEIGHT, -2 * SHADOW_DIST - 120);

    //wall_egde_full_top_top_neighbour
    wall_egde_full_left_left_neigh[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, PONG_WALL_HEIGHT);
    wall_egde_full_left_left_neigh[1] = SetSegment(-SHADOW_DIST, PONG_WALL_HEIGHT, -2 * SHADOW_DIST - 120, PONG_WALL_HEIGHT);

    //diameter walls
    wall_diameter[0] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -240, -SHADOW_DIST);
    wall_diameter[1] = SetSegment(-SHADOW_DIST, -SHADOW_DIST, -SHADOW_DIST, -240);
}
bool:GetUpperCubeNFace(const thisCubeN, const thisFaceN, & cubeN, & faceN) {
    new accelX = abi_MTD_GetFaceAccelX(thisFaceN);
    new accelY = abi_MTD_GetFaceAccelY(thisFaceN);
    new accelZ = abi_MTD_GetFaceAccelZ(thisFaceN);
    new neighborCubeN = CUBES_MAX;
    new neighborFaceN = FACES_MAX;
    new cubeN_tmp = thisCubeN;
    new faceN_tmp = thisFaceN;

    if ((ABS(accelZ) > ABS(accelX)) && (ABS(accelZ) > ABS(accelY))) {
        if (accelZ < 0) {
            if (ABS(accelY) > ABS(accelX)) {
                if (accelY >= 0) {
                    neighborCubeN = abi_topCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_topFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = abi_topCubeN(neighborCubeN, neighborFaceN);
                    faceN_tmp = abi_topFaceN(neighborCubeN, neighborFaceN);
                    if (!((cubeN_tmp < CUBES_MAX) && (faceN_tmp < FACES_MAX)))
                        return false;
                }
            } else {
                if (accelX < 0) {
                    neighborCubeN = abi_topCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_topFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = neighborCubeN;
                    faceN_tmp = neighborFaceN;
                } else {
                    neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = neighborCubeN;
                    faceN_tmp = neighborFaceN;
                }
            }
        } else {
            //far far cubeN and faceNa
            neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
            neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
            if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                return false;
            cubeN_tmp = neighborCubeN;
            faceN_tmp = neighborFaceN;

            neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
            neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
            if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                return false;
            neighborFaceN = abi_bottomFaceN(neighborCubeN, neighborFaceN);

            cubeN_tmp = neighborCubeN;
            faceN_tmp = neighborFaceN;

            neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
            neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
            if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                return false;

            neighborFaceN = abi_bottomFaceN(neighborCubeN, neighborFaceN);

            cubeN_tmp = neighborCubeN;
            faceN_tmp = neighborFaceN;

            if (ABS(accelY) > ABS(accelX)) {
                if (accelY > 0) {
                    neighborCubeN = abi_topCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_topFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = neighborCubeN;
                    faceN_tmp = neighborFaceN;
                } else {
                    neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = neighborCubeN;
                    faceN_tmp = neighborFaceN;
                }
            } else {
                if (accelX <= 0) {
                    neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = neighborCubeN;
                    faceN_tmp = neighborFaceN;
                    neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
                        return false;
                    cubeN_tmp = neighborCubeN;
                    faceN_tmp = neighborFaceN;
                }
            }
        }
        cubeN = cubeN_tmp;
        faceN = faceN_tmp;
        return true;
    }
    return false;
}
InitLevel() {

    if ((0 == abi_cubeN) && (ball_object == 0xFFFFFFFF) && (!is_gameover)) {
        new upper_cube = CUBES_MAX;
        new upper_face = FACES_MAX;

        if (!GetUpperCubeNFace(abi_cubeN, 0, upper_cube, upper_face) &&
            !GetUpperCubeNFace(abi_cubeN, 1, upper_cube, upper_face) &&
            !GetUpperCubeNFace(abi_cubeN, 2, upper_cube, upper_face))
            return;



        level++;
        GeneratePerks();
        GenerateWalls();

        ball_object = set_cube(ball_object, upper_cube);
        ball_object = set_face(ball_object, upper_face);
        ball_object = set_posx(ball_object, 120);
        ball_object = set_posy(ball_object, 120);
        ball_object = set_angle(ball_object, 0);

        ball_movings = set_speedx(ball_movings, 0);
        ball_movings = set_speedy(ball_movings, 0);
        ball_movings = set_angular(ball_movings, 0);

        is_dep = true;
        count_all_perks = 0xFF;
        count_moves = 0;
        local_ticks = 0;

        count_movings = (((!is_gameover) && (count_movings < 0xFF)) ? count_movings + 1 : 0);
    }
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
SetGameOver() {
    if (is_gameover) {
        ball_object = 0xFFFFFFFF;
        ball_object_dep = 0xFFFFFFFF;
        ball_movings = 0xFFFFFFFF;
        ball_movings_dep = 0xFFFFFFFF;
        //count_movings = 0;
        //count_rotation = 0;
        //local_ticks = 0;
    }
}