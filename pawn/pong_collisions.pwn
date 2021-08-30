bool:CheckCollisionCicleAndSegment(const pos_x0, const pos_y0, const r, const spx, const spy, const x1, const y1, const x2, const y2, & collision_x, & collision_y, & check_only_first) {

    new dist, x4, y4;
    new x0 = pos_x0, y0 = pos_y0;

    if((ABS(spx) + ABS(spy) != 0) && !((y0 + spy - y0 == 0) && (y2 - y1 == 0)) && !((y0 + spy - y0 != 0) && ((x2 - x1) * (y0 - (y0 + spy)) + (y2 - y1) * (x0 + spx - x0) == 0))) {
        if(y0 + spy - y0 != 0) {
            x4 = x2 + (x1 - x2) * ((x2 - x0) + (y2 - y0) * (x0 + spx - x0) / (y0 - (y0 + spy))) / ((x2 - x1) + (y2 - y1) * (x0 + spx - x0) / (y0 - (y0 + spy)));
            y4 = y2 + (y1 - y2) * ((x2 - x0) + (y2 - y0) * (x0 + spx - x0) / (y0 - (y0 + spy))) / ((x2 - x1) + (y2 - y1) * (x0 + spx - x0) / (y0 - (y0 + spy)));
        } else {
            x4 = x2 + (x1 - x2) * (y2 - y0) / (y2 - y1);
            y4 = y2 + (y1 - y2) * (y2 - y0) / (y2 - y1);
        }
        dist = (x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0);
        if((dist > 0) && (dist <= spx * spx + spy * spy) &&
            ((x1 - x4) * (x1 - x4) + (y1 - y4) * (y1 - y4) <= (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)) &&
            ((x2 - x4) * (x2 - x4) + (y2 - y4) * (y2 - y4) <= (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))) {

            if(dist <= spx * spx + spy * spy) {
                check_only_first = true;

                collision_x = x4;
                collision_y = y4;

                return (true);
            }
        }
    }

    if(check_only_first == true) return (false);

    x0 += spx;
    y0 += spy;

    //second, check the intersection of the new cicle pposition
    new AB = ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    new AC = ((x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1));
    new BC = ((x0 - x2) * (x0 - x2) + (y0 - y2) * (y0 - y2));
    dist = -1, x4 = x0, y4 = y0;
    if((BC + AB - AC) < 0) {
        x4 = x2;
        y4 = y2;
        dist = BC;
    } else if((AC + AB - BC) < 0) {
        x4 = x1;
        y4 = y1;
        dist = AC;
    } else if((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) > 0) {
        x4 = (x1 * x1 * x0 - 2 * x1 * x2 * x0 + x2 * x2 * x0 + x2 * (y1 - y2) * (y1 - y0) - x1 * (y1 - y2) * (y2 - y0)) / ((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
        y4 = (x2 * x2 * y1 + x1 * x1 * y2 + x2 * x0 * (y2 - y1) - x1 * (x0 * (y2 - y1) + x2 * (y1 + y2)) + (y1 - y2) * (y1 - y2) * y0) / ((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
        dist = (x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0);
    }
    if((dist <= r * r) && (dist > 0)) {
        collision_x = x4;
        collision_y = y4;
        dist = (x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0);
        return (true);
    }

    return (false);
}
CheckCollisionCicleAndFigure(const x0, const y0, const r, const spx, const spy, & acceleration_x, & acceleration_y,
    const coords[], const size, & collision_x, & collision_y, & collision2_x, & collision2_y, & collision_dist, & collisions_count, & bool:check_only_first) {

    new pos_x;
    new pos_y;
    new colx, coly;
    new distance = 0xFFFF;
    new bool:is_first = check_only_first;
    new bool:is_collision = false;

    for (new i = 0; i < size; i++) {
        if(CheckCollisionCicleAndSegment(x0, y0, r, spx, spy, get_segment(coords[i], 0), get_segment(coords[i], 1), get_segment(coords[i], 2), get_segment(coords[i], 3), pos_x, pos_y, check_only_first)) {

            //collision_dist = ((is_first != check_only_first) ? 0xFFFF :collision_dist);
            //collisions_count = ((is_first != check_only_first) ? 0 :collisions_count);

            if((pos_x - x0 - ((check_only_first) ? 0 :spx)) * (pos_x - x0 - ((check_only_first) ? 0 :spx)) + (pos_y - y0 - ((check_only_first) ? 0 :spy)) * (pos_y - y0 - ((check_only_first) ? 0 :spy)) <= distance) {
                colx = pos_x;
                coly = pos_y;
                is_collision = true;
                distance = (pos_x - x0 - ((check_only_first) ? 0 :spx)) * (pos_x - x0 - ((check_only_first) ? 0 :spx)) +
                    (pos_y - y0 - ((check_only_first) ? 0 :spy)) * (pos_y - y0 - ((check_only_first) ? 0 :spy));
                ncolx1 = get_segment(coords[i], 0);
                ncoly1 = get_segment(coords[i], 1);
                ncolx2 = get_segment(coords[i], 2);
                ncoly2 = get_segment(coords[i], 3);
            }
        }
    }

    if(is_collision) {
        ChangeVectorAcc(x0, y0, colx, coly, collision_x, collision_y, collision2_x, collision2_y, collisions_count, collision_dist, acceleration_x, acceleration_y);
    }
}
ProjectionOnPalneVectorAcc(const x0, const y0, const x4, const y4, & acceleration_x, & acceleration_y) {
    if((x0 - x4) * (x0 - x4) + (y0 - y4) * (y0 - y4) == 0) return;
    new acc_y = (-acceleration_x * (y0 - y4) + acceleration_y * (x0 - x4)); // / ((x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0));
    new acc_x = (acceleration_x * (x0 - x4) + acceleration_y * (y0 - y4)); // / ((x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0));
    if(acc_x < 0)
        acc_x = 0;

    acceleration_x = (acc_x * (x0 - x4) - acc_y * (y0 - y4)) / ((x0 - x4) * (x0 - x4) + (y0 - y4) * (y0 - y4));
    acceleration_y = (acc_x * (y0 - y4) + acc_y * (x0 - x4)) / ((x0 - x4) * (x0 - x4) + (y0 - y4) * (y0 - y4));
}
CalcVelNPos(const x0, const y0, & collision_x, & collision_y, & sx, & sy) {
    new x4 = collision_x;
    new y4 = collision_y;
    new dist = int_sqrt((x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0));

    ccols = 0;

    if(dist != 0) {
        collision_x += (x0 - x4) * BALL_RADIUS / dist;
        collision_y += (y0 - y4) * BALL_RADIUS / dist;
    }

    new speed = int_sqrt(sx * sx + sy * sy);

    if((collision_x - x4) * (collision_x - x4) + (collision_y - y4) * (collision_y - y4) == 0) return; // sin = (collision_y-y4) cos = (collision_x-x4)

    sx = ((g_speed_x * (collision_y - y4) + g_speed_y * (collision_x - x4)) * (collision_y - y4) -
            (-g_speed_x * (collision_x - x4) + g_speed_y * (collision_y - y4)) / (-SLOWING) * (collision_x - x4)) /
        ((collision_x - x4) * (collision_x - x4) + (collision_y - y4) * (collision_y - y4));

    sy = ((g_speed_x * (collision_y - y4) + g_speed_y * (collision_x - x4)) * (collision_x - x4) +
            (-g_speed_x * (collision_x - x4) + g_speed_y * (collision_y - y4)) / (-SLOWING) * (collision_y - y4)) /
        ((collision_x - x4) * (collision_x - x4) + (collision_y - y4) * (collision_y - y4));

    NormalizeVector(sx, sy, BALL_SPEED_MAX);
}
ChangeVectorAcc(const x0, const y0, const coll_x, const coll_y, & collision_x, & collision_y, & collision2_x, & collision2_y, & count_collisions, & distance, & acceleration_x, & acceleration_y) {
    if(((coll_x - x0) * (coll_x - x0) + (coll_y - y0) * (coll_y - y0)) < distance) {
        count_collisions = 1;
        acceleration_x = abi_MTD_GetFaceAccelX(g_face);
        acceleration_y = abi_MTD_GetFaceAccelY(g_face);
        collision_x = coll_x;
        collision_y = coll_y;
        //distance = ((collision_x - x0) * (collision_x - x0) + (collision_y - y0) * (collision_y - y0));
        ProjectionOnPalneVectorAcc(x0, y0, collision_x, collision_y, acceleration_x, acceleration_y);
    } else if(((coll_x - x0) * (coll_x - x0) + (coll_y - y0) * (coll_y - y0)) == distance) {
        count_collisions++;
        if(count_collisions == 1) {
            collision2_x = coll_x;
            collision2_y = coll_y;
        }
        ProjectionOnPalneVectorAcc(x0, y0, collision_x, collision_y, acceleration_x, acceleration_y);
    }
}