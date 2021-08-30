#define SIZE_RECT 4
#define SLOWING 2
#define POINT .x, .y

#define get_segment(%0,%1) ((((%0 >> (%1 * 8 + 7) & 0x1) == 1) ? -2 :2) * ((%0 >> (%1 * 8)) & 0x7F))

#define sign_bit(%0) (((%0) < 0) ? 1 :0)
#define abs(%0) (((%0) < 0) ? -(%0) :(%0))
#define set_coord(%0)   ((sign_bit(%0) << 7) | ((abs(%0) / 2) & 0x7F))
#define set_segment(%0,%1,%2,%3) ((set_coord(%0) << 0) | (set_coord(%1) << 8) | (set_coord(%2) << 16) | (set_coord(%3) << 24))

forward NormalizeVector(const x1, const y1, & x2, & y2, const dist, const bool:extension = false);
forward bool:CheckCollisionCicleAndSegment(const pos_x0, const pos_y0, const r, const spx, const spy, const x1, const y1, const x2, const y2, & l_collision_x, & l_collision_y)

// acceleration_x, acceleration_y - acceleration vector of the cicle;
// collision_x[0], collision_y[0] - coordinates of the first collision
// collision_x[1], collision_y[1] - seconds coordinates of the multi collision
// collision_dist,  collisions_count - distance and counter of collisions
new acceleration_x, acceleration_y;
new collision_x[2], collision_y[2];
new collision_dist, collisions_count;

new new_pos_x, new_pos_y;
new collision_segment;

new collision_hx, collision_hy;

SetRectangleSegments(x1, y1, x2, y2) {
    new tmp[SIZE_RECT];
    tmp[0] = set_segment(x1, y1, x1, y2);
    tmp[1] = set_segment(x2, y1, x2, y2);
    tmp[2] = set_segment(x1, y1, x2, y1);
    tmp[3] = set_segment(x1, y2, x2, y2);
    return tmp;
}
ClearCollisionVariables(const l_face) {
    acceleration_x = 0;
    acceleration_y = 0;
    collision_x = [0, 0];
    collision_y = [0, 0];
    collision_x[1] = 0;
    collision_y[1] = 0;
    collision_hx = 0;
    collision_hy = 0;
    collision_dist = 0xFFFFFF;
    collisions_count = 0;
    acceleration_x = abi_MTD_GetFaceAccelX(l_face);
    acceleration_y = abi_MTD_GetFaceAccelY(l_face);
    //collision_segment = 0;
}
// Let's check a collision between the circle and the shape defined by the segments.
// cicle_x, cicle_y - center of the cicle;
// speed_x, speed_y - velocity vector of the cicle;
// coords, size - array of segment coordinates and there size. 
// radius - radius of the cicle;
// acc_max - maximum of vector acceleration;
// l_face - the screen where the object is located. This is necessary for get vector acceleration.
CheckCollisionCicleAndFigure(const cicle_x, const cicle_y, const speed_x, const speed_y, const coords[], const radius, size = sizeof(coords)) {

    new l_collision_x;
    new l_collision_y;
    new colx, coly;
    new l_distance = 0xFFFF;
    new bool:is_collision = false;

    for (new counter = 0; counter < size; counter++) {
        if (CheckCollisionCicleAndSegment(cicle_x, cicle_y, radius, speed_x, speed_y,
                get_segment(coords[counter], 0), get_segment(coords[counter], 1),
                get_segment(coords[counter], 2), get_segment(coords[counter], 3),
                l_collision_x, l_collision_y)) {
            if ((l_collision_x - cicle_x) * (l_collision_x - cicle_x) +
                (l_collision_y - cicle_y) * (l_collision_y - cicle_y) <= l_distance) {
                colx = l_collision_x;
                coly = l_collision_y;
                is_collision = true;
                collision_segment = coords[counter];
                l_distance = (l_collision_x - cicle_x) * (l_collision_x - cicle_x) + (l_collision_y - cicle_y) * (l_collision_y - cicle_y);
            }
        }
    }

    if (is_collision) {
        if (((l_collision_x - cicle_x) * (l_collision_x - cicle_x) + (l_collision_y - cicle_y) * (l_collision_y - cicle_y)) < collision_dist) {
            collisions_count = 1;
            //acceleration_x = abi_MTD_GetFaceAccelX(l_face);
            //acceleration_y = abi_MTD_GetFaceAccelY(l_face);
            collision_x[0] = l_collision_x;
            collision_y[0] = l_collision_y;
            collision_dist = (l_collision_x - cicle_x) * (l_collision_x - cicle_x) + (l_collision_y - cicle_y) * (l_collision_y - cicle_y);
            //ProjectionOnPalneVectorAcc(cicle_x, cicle_y);
        } else if (((l_collision_x - cicle_x) * (l_collision_x - cicle_x) + (l_collision_y - cicle_y) * (l_collision_y - cicle_y)) == collision_dist) {
            //multicollision
            collisions_count = 2;
            collision_x[1] = l_collision_x;
            collision_y[1] = l_collision_y;
            //ProjectionOnPalneVectorAcc(cicle_x, cicle_y);
        }
        if (collisions_count == 1)
            CalculateNewPositions(cicle_x, cicle_y, radius,
                get_segment(collision_segment, 0), get_segment(collision_segment, 1),
                get_segment(collision_segment, 2), get_segment(collision_segment, 3),
                new_pos_x, new_pos_y);
    }

}
ProjectionOnPalneVectorAcc(const x1, const y1, const x2, const y2, & acc_x, & acc_y) {
    new sin = y2 - y1;
    new cos = x2 - x1;

    if (sin * sin + cos * cos == 0) return;

    new l_acc_x = (acc_x * cos + acc_y * sin);
    new l_acc_y = (-acc_x * sin + acc_y * cos);

    dax = l_acc_x;
    day = l_acc_y;

    if (l_acc_x < 0) return;

    acc_x = (-l_acc_y * sin) / (sin * sin + cos * cos);
    acc_y = (l_acc_y * cos) / (sin * sin + cos * cos);
}
ChangeVelocity(const x1, const y1, const x2, const y2, & vel_x, & vel_y) {
    /*
        new sin = y2 - y1;
        new cos = x2 - x1;

        if (sin * sin + cos * cos == 0) return;

        new l_vel_x = -(vel_x * cos + vel_y * sin) / SLOWING;
        new l_vel_y = (-vel_x * sin + vel_y * cos);

        vel_x = (l_vel_x * cos - l_vel_y * sin) / (sin * sin + cos * cos);
        vel_y = (l_vel_x * sin + l_vel_y * cos) / (sin * sin + cos * cos);
    */
    vel_x -= GetSign(vel_x);
    vel_y -= GetSign(vel_y);

    new l_vel_x = ((vel_x * (y2 - y1) + vel_y * (x2 - x1)) * (y2 - y1) -
            (-vel_x * (x2 - x1) + vel_y * (y2 - y1)) / (-SLOWING) * (x2 - x1)) /
        ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));

    new l_vel_y = ((vel_x * (y2 - y1) + vel_y * (x2 - x1)) * (x2 - x1) +
            (-vel_x * (x2 - x1) + vel_y * (y2 - y1)) / (-SLOWING) * (y2 - y1)) /
        ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));

    vel_x = l_vel_x;
    vel_y = l_vel_y;

    //vel_x = -vel_x / SLOWING;
    //vel_y = -vel_y / SLOWING;
}
bool:CheckCollisionCicleAndSegment(const pos_x0, const pos_y0, const r, const spx, const spy, const x1, const y1, const x2, const y2, & l_collision_x, & l_collision_y) {

    new dist = -1, x4 = pos_x0, y4 = pos_y0;
    new x0 = pos_x0, y0 = pos_y0;

    if ( /*((spx == 0) && (spy == 0)) ||*/ ((x1 == x2) && (y1 == y2))) return (false);

    new x[4], y[4];
    x[0] = ((spx >= 0) ? x0 : x0 + spx);
    y[0] = ((spy >= 0) ? y0 : y0 + spy);
    x[1] = ((spx < 0) ? x0 : x0 + spx);
    y[1] = ((spy < 0) ? y0 : y0 + spy);

    x[2] = ((x2 - x1 >= 0) ? x1 : x2);
    y[2] = ((y2 - y1 >= 0) ? y1 : y2);
    x[3] = ((x2 - x1 < 0) ? x2 : x1);
    y[3] = ((y2 - y1 < 0) ? y2 : y1);

    if ((x[0] - x[1]) * (y[2] - y[3]) != (y[0] - y[1]) * (x[2] - x[3])) {
        x4 = ((x[0] * y[1] - y[0] * x[1]) * (x[2] - x[3]) - (x[2] * y[3] - y[2] * x[3]) * (x[0] - x[1])) / ((x[0] - x[1]) * (y[2] - y[3]) - (y[0] - y[1]) * (x[2] - x[3]));
        y4 = ((x[0] * y[1] - y[0] * x[1]) * (y[2] - y[3]) - (x[2] * y[3] - y[2] * x[3]) * (y[0] - y[1])) / ((x[0] - x[1]) * (y[2] - y[3]) - (y[0] - y[1]) * (x[2] - x[3]));
        dist = (x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0);
        if ((dist <= spx * spx + spy * spy) && (x[0] <= x4) && (x[0] >= x4) && (y[1] <= y4) && (y[1] >= y4) && (x[2] <= x4) && (x[2] >= x4) && (y[3] <= y4) && (y[3] >= y4)) {
            l_collision_x = x4;
            l_collision_y = y4;
            return (true);
        }
    }

    x0 += spx;
    y0 += spy;

    //second, check the intersection of the new cicle position
    new AB = ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    new AC = ((x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1));
    new BC = ((x0 - x2) * (x0 - x2) + (y0 - y2) * (y0 - y2));
    dist = -1, x4 = x0, y4 = y0;
    if ((BC + AB - AC) < 0) {
        x4 = x2;
        y4 = y2;
        dist = BC;
    } else if ((AC + AB - BC) < 0) {
        x4 = x1;
        y4 = y1;
        dist = AC;
    } else if ((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) > 0) {
        x4 = (x1 * x1 * x0 - 2 * x1 * x2 * x0 + x2 * x2 * x0 + x2 * (y1 - y2) * (y1 - y0) - x1 * (y1 - y2) * (y2 - y0)) / ((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
        y4 = (x2 * x2 * y1 + x1 * x1 * y2 + x2 * x0 * (y2 - y1) - x1 * (x0 * (y2 - y1) + x2 * (y1 + y2)) + (y1 - y2) * (y1 - y2) * y0) / ((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
        dist = (x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0);
    }
    if ((dist <= r * r) && (dist > 0)) {
        l_collision_x = x4;
        l_collision_y = y4;
        dist = (x4 - x0) * (x4 - x0) + (y4 - y0) * (y4 - y0);
        return (true);
    }

    return (false);
}
CalculateNewPositions(const x0, const y0, const radius, const x1, const y1, const x2, const y2, & l_new_pos_x, & l_new_pos_y) {

    //Height from the center of the cicle
    l_new_pos_x = x1 + (x2 - x1) * ((x2 - x1) * (x0 - x1) + (y2 - y1) * (y0 - y1)) / ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    l_new_pos_y = y1 + (y2 - y1) * ((x2 - x1) * (x0 - x1) + (y2 - y1) * (y0 - y1)) / ((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));

    collision_hx = l_new_pos_x;
    collision_hy = l_new_pos_y;


    if (((collision_x[0] - l_new_pos_x) * (collision_x[0] - l_new_pos_x) + (collision_y[0] - l_new_pos_y) * (collision_y[0] - l_new_pos_y) != 0) &&
        (!((collision_x[0] == x1) && (collision_y[0] == y1))) && (!((collision_x[0] == x2) && (collision_y[0] == y2)))) {
        new dist_collH = int_sqrt((collision_x[0] - l_new_pos_x) * (collision_x[0] - l_new_pos_x) + (collision_y[0] - l_new_pos_y) * (collision_y[0] - l_new_pos_y));
        new dist_H = int_sqrt((l_new_pos_x - x0) * (l_new_pos_x - x0) + (l_new_pos_y - y0) * (l_new_pos_y - y0));

        //Normalize distance
        new collision_norm_dist = 10 * radius * dist_collH / dist_H;
        Round(collision_norm_dist, 10);

        if (collision_norm_dist != 0) {
            NormalizeVector(collision_x[0], collision_y[0], l_new_pos_x, l_new_pos_y, collision_norm_dist, true);

            dhx = new_pos_x;
            dhy = new_pos_y;

            NormalizeVectorSheer(l_new_pos_x, l_new_pos_y, collision_x[0], collision_y[0],
                GetSign(-(x0 - l_new_pos_x) * (collision_y[0] - l_new_pos_y) + (y0 - l_new_pos_y) * (collision_x[0] - l_new_pos_x)) * radius, true);

        } else {
            l_new_pos_x = x0;
            l_new_pos_y = y0;
        }
    } else {
        l_new_pos_x = x0;
        l_new_pos_y = y0;
        NormalizeVector(collision_x[0], collision_y[0], l_new_pos_x, l_new_pos_y, radius, true);
    }
}
CalculateNewPosAndVel( & cicle_x, & cicle_y, const radius, & velocity_x, & velocity_y, const velocity_max, const acc_max) {

    //collision segmet and velocity is parallel
    if ((velocity_x * (get_segment(collision_segment, 1) - get_segment(collision_segment, 3)) == velocity_y * (get_segment(collision_segment, 0) - get_segment(collision_segment, 2))) && (collisions_count == 1)) {
        collisions_count = 0;
        ProjectionOnPalneVectorAcc(new_pos_x, new_pos_y, (collision_x[0] + collision_x[1]) / 2, (collision_y[0] + collision_y[1]) / 2, acceleration_x, acceleration_y);
    }
    switch (collisions_count) {
        case 0 :  {
            cicle_x += velocity_x;
            cicle_y += velocity_y;

            NormalizeVector(0, 0, acceleration_x, acceleration_y, acc_max);
            velocity_x += acceleration_x;
            velocity_y += acceleration_y;
            NormalizeVector(0, 0, velocity_x, velocity_y, velocity_max);
        }
        case 1 :  {
            if (!((cicle_x == new_pos_x) && (cicle_y == new_pos_y))) {
                cicle_x = new_pos_x;
                cicle_y = new_pos_y;
                ChangeVelocity(cicle_x, cicle_y, collision_hx, collision_hy, velocity_x, velocity_y);
                /*

                NormalizeVector(0, 0, acceleration_x, acceleration_y, acc_max);
                ProjectionOnPalneVectorAcc(cicle_x, cicle_y, collision_hx, collision_hy, acceleration_x, acceleration_y);

                ChangeVelocity(cicle_x, cicle_y, collision_hx, collision_hy, velocity_x, velocity_y);

                velocity_x += acceleration_x;
                velocity_y += acceleration_y;
                NormalizeVector(0, 0, velocity_x, velocity_y, velocity_max);
                */
            } else {
                velocity_x /= SLOWING;
                velocity_y /= SLOWING;
                /*
                NormalizeVector(0, 0, acceleration_x, acceleration_y, acc_max);
                ProjectionOnPalneVectorAcc(cicle_x, cicle_y, collision_hx, collision_hy, acceleration_x, acceleration_y);
                vel_x /= SLOWING;
                vel_y /= SLOWING;

                velocity_x += acceleration_x;
                velocity_y += acceleration_y;
                NormalizeVector(0, 0, velocity_x, velocity_y, velocity_max);
                */
            }
            NormalizeVector(0, 0, acceleration_x, acceleration_y, acc_max);
            ProjectionOnPalneVectorAcc(cicle_x, cicle_y, collision_hx, collision_hy, acceleration_x, acceleration_y);
            //velocity_x /= SLOWING;
            //velocity_y /= SLOWING;

            velocity_x += acceleration_x;
            velocity_y += acceleration_y;
            NormalizeVector(0, 0, velocity_x, velocity_y, velocity_max);
        }
        default:  {
            if (velocity_x != 0 && velocity_y != 0) {
                velocity_x = -velocity_x / SLOWING;
                velocity_y = -velocity_y / SLOWING;
            } else {
                NormalizeVector(0, 0, acceleration_x, acceleration_y, acc_max);
                ProjectionOnPalneVectorAcc(cicle_x, cicle_y, (collision_x[0] + collision_x[1]) / 2, (collision_y[0] + collision_y[1]) / 2, acceleration_x, acceleration_y);
                velocity_x += acceleration_x;
                velocity_y += acceleration_y;
            }

            new pos_x = cicle_x, pos_y = cicle_y;

            cicle_x = collision_x[0] + (((collision_x[1] - collision_x[0]) * (collision_x[0] - collision_x[1]) + (collision_y[1] - collision_y[0]) * (collision_y[0] - collision_y[1])) /
                    2 * (collision_x[0] - collision_x[1]) - GetSign((-(pos_x - collision_x[0]) * (collision_y[0] - collision_y[1]) + (pos_y - collision_y[0]) *
                        (collision_x[0] - collision_x[1]))) * int_sqrt(radius * radius * ((collision_x[1] - collision_x[0]) * (collision_x[1] - collision_x[0]) +
                        (collision_y[1] - collision_y[0]) * (collision_y[1] - collision_y[0])) - ((collision_x[1] - collision_x[0]) * (collision_x[0] - collision_x[1]) +
                        (collision_y[1] - collision_y[0]) * (collision_y[0] - collision_y[1])) * ((collision_x[1] - collision_x[0]) * (collision_x[0] - collision_x[1]) +
                        (collision_y[1] - collision_y[0]) * (collision_y[0] - collision_y[1])) / 4) * (collision_y[0] - collision_y[1])) /
                ((collision_x[1] - collision_x[0]) * (collision_x[1] - collision_x[0]) + (collision_y[1] - collision_y[0]) * (collision_y[1] - collision_y[0]));
            cicle_y = collision_y[0] + (((collision_x[1] - collision_x[0]) * (collision_x[0] - collision_x[1]) + (collision_y[1] - collision_y[0]) * (collision_y[0] - collision_y[1])) /
                    2 * (collision_y[0] - collision_y[1]) + (GetSign((-(pos_x - collision_x[0]) * (collision_y[0] - collision_y[1]) + (pos_y - collision_y[0]) *
                        (collision_x[0] - collision_x[1]))) * int_sqrt(radius * radius * ((collision_x[1] - collision_x[0]) * (collision_x[1] - collision_x[0]) +
                        (collision_y[1] - collision_y[0]) * (collision_y[1] - collision_y[0])) - ((collision_x[1] - collision_x[0]) * (collision_x[0] - collision_x[1]) +
                        (collision_y[1] - collision_y[0]) * (collision_y[0] - collision_y[1])) * ((collision_x[1] - collision_x[0]) * (collision_x[0] - collision_x[1]) +
                        (collision_y[1] - collision_y[0]) * (collision_y[0] - collision_y[1])) / 4)) * (collision_x[0] - collision_x[1])) /
                ((collision_x[1] - collision_x[0]) * (collision_x[1] - collision_x[0]) + (collision_y[1] - collision_y[0]) * (collision_y[1] - collision_y[0]));

        }
    }
}
stock NormalizeVector(const x1, const y1, & x2, & y2, const dist, const bool:extension = false) {
    new sin = y2 - y1;
    new cos = x2 - x1;
    new current_dist = sin * sin + cos * cos;

    if ((current_dist == 0) || ((!extension) && (current_dist < dist * dist))) return;
    if (int_sqrt(current_dist) == 0) return;
    if (dist == 0) return;

    x2 = x1 + dist * cos / int_sqrt(current_dist);
    y2 = y1 + dist * sin / int_sqrt(current_dist);
}
stock NormalizeVectorSheer( & x1, & y1, const x2, const y2, const dist, const bool:extension = false) {
    new sin = y2 - y1;
    new cos = x2 - x1;
    new current_dist = sin * sin + cos * cos;

    if ((current_dist == 0) || ((!extension) && (current_dist < dist * dist))) return;
    if (int_sqrt(current_dist) == 0) return;

    x1 -= dist * sin / int_sqrt(current_dist);
    y1 += dist * cos / int_sqrt(current_dist);
}