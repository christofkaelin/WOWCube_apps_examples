#ifndef CUBIOS_EMULATOR
#define LAYERS
#endif

//#define DEBUG

#define VERSION_TEST        1

#define SOUND
#define SOUND_COLLIDE       0
#define SOUND_VOLUME        95

#define CMD_PAWN            150
#define CMD_STATUS          CMD_PAWN
#define CMD_SEND_WALLS      CMD_PAWN + 1
#define CMD_SEND_BALL       CMD_PAWN + 2

//bitmaps
#define BACKGROUND          0
#define BALL_PIC            1
#define PIC_WALL_FULL       2
#define PIC_WALL_HALF       3
#define NUMBER0             4
#define PIC_MINUS           32
#define PIC_PERK            17

#define PIC_SHAKE           33

#define PERKS_MAX           11
#define PERK_RADIUS         33

#define BALL_RADIUS         20
#define SHADOW_DIST         20

#define BALL_SPEED_MAX      25
#define BALL_ACC_MAX        3
#define SLOWING             2

#define WALL_NO             0
#define WALL_HALF_CENTER    1
#define WALL_HALF_EDGE      2
#define WALL_FULL           3

#define PONG_LOGO           28
#define PONG_MOVES          29
#define PONG_SCORE          30
#define PONG_TIME           31
#define PONG_COLON          32

new ball_object; //ball on thiscube
new ball_object_dep; //departing ball
//32 bits:cube - 3 bits (max 7); face - 2 bits (max 2); pos_x - 9 bits (511 max); pos_y - 9 bits (511 max);  angle - 9 bits (511 max4)
#define get_cube(%0) ((%0 >> 29) & 0x7)
#define get_face(%0) ((%0 >> 27) & 0x3)
#define get_posx(%0) 256 - ((%0 >> 18) & 0x1FF)
#define get_posy(%0) 256 - ((%0 >> 9) & 0x1FF)
#define get_angle(%0) (%0 & 0x1FF)
// calculate positions are code pos_*  256 = pos_*. this way we can avoid encoding the position sign
#define set_cube(%0,%1) ((%0 & ~(0x7 << 29)) | ((%1 & 0x7) << 29))
#define set_face(%0,%1) ((%0 & ~(0x3 << 27)) | ((%1 & 0x3) << 27))
#define set_posx(%0,%1) ((%0 & ~(0x1FF << 18)) | (((256 - %1) & 0x1FF) << 18))
#define set_posy(%0,%1) ((%0 & ~(0x1FF << 9)) | (((256 - %1)  & 0x1FF) << 9))
#define set_angle(%0,%1) ((%0 & ~0x1FF) | (%1 & 0x1FF) )

new walls[FACES_MAX] = [0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF];

new ball_movings; //moving attributes ball on this cube
new ball_movings_dep; //moving attributes departing ball
new bool:is_dep = false;
//32 bits:speed_x - 7 bits (max 63 pixels on tick) + 1 bit sign; speed_y - 7 bits (max 63 pixels on tick) + 1 bit sign; angular velocity - 9 bits (max 511) + 1 bit sign
#define get_speedx(%0) (((%0 >> 25) & 0x1) ? -1 * ((%0 >> 18) & 0x7F) :((%0 >> 18) & 0x7F))
#define get_speedy(%0) (((%0 >> 17) & 0x1) ? -1 * ((%0 >> 10) & 0x7F) :((%0 >> 10) & 0x7F))
#define get_angular(%0) (((%0 >> 9) & 0x1) ? -1 * (%0 & 0x1FF) :(%0 & 0x1FF))

#define set_speedx(%0,%1) ((%0 & ~(0xFF << 18)) | ((((((GetSign(%1) < 0) ?1 :0) << 7) | (ABS(%1) & 0x7F)) & 0xFF) << 18))
#define set_speedy(%0,%1) ((%0 & ~(0xFF << 10)) | ((((((GetSign(%1) < 0) ?1 :0) << 7) | (ABS(%1) & 0x7F)) & 0xFF) << 10))
#define set_angular(%0,%1) ((%0 & ~(0x3FF << 0)) | ((((((GetSign(%1) < 0) ?1 :0) << 9) | (ABS(%1) & 0x1FF)) & 0x3FF) << 0))

new g_pos_x, g_pos_y, g_angle, g_speed_x, g_speed_y, g_angular;

new g_face;
new bool:is_set_background[FACES_MAX];
new level = 0;

#define PONG_WALL_HEIGHT    26
#define PONG_WALL_WIDTH     236
#define PONG_SCREEN_HEIGHT  240
#define PONG_SCREEN_WIDTH   240

#define get_segment(%0,%1) ((((%0 >> (%1 * 8 + 7) & 0x1) == 1) ? -2 :2) * ((%0 >> (%1 * 8)) & 0x7F))

new wall_full_top[4];
new wall_full_right[4];
new wall_full_bottom[4];
new wall_full_left[4];

new wall_half_center_top[4];
new wall_half_edge_top[4];
new wall_half_center_left[4];
new wall_half_edge_left[4];

new walls_no_neighbour_top[1];
new walls_no_neighbour_left[1];

//neighbours walls
new wall_full_top_neighbour[1];
new wall_full_left_neighbour[1];

new wall_half_center_top_neighbour[4];
new wall_half_edge_top_neighbour[4];
new wall_egde_full_top_top_neigh[2];

new wall_half_center_left_neighbour[4];
new wall_half_edge_left_neighbour[4];
new wall_egde_full_left_left_neigh[2];

new wall_diameter[2];

#define INITAL_SCORE        10000

new local_ticks;
new count_rotation;
new count_movings;
new count_moves;

// 1 perks 4 bits - 0xF; angle 9 bits - 0x1FF; posx 8 bits - 0xFF; posy 8 bits - 0xFF; angle rotation 3 bits - 0x&
#define set_perk(%0,%1,%2,%3,%4) ((%0 & 0xF) | ((%1 & 0xFF) << 4) | ((%2 & 0xFF) << 12) | ((%3 & 0x1FF) << 20) | ((%4 & 0x7) << 29))
#define set_perk_value(%0,%1) ((%0 & ~(0xF << 0)) | ((%1 & 0xF) << 0))
#define set_perk_angle(%0,%1) ((%0 & ~(0x1FF << 20)) | ((%1 & 0x1FF) << 20))
#define get_perk_value(%0) (%0 & 0xF)
#define get_perk_posx(%0) ((%0 >> 4) & 0xFF)
#define get_perk_posy(%0) ((%0 >> 12) & 0xFF)
#define get_perk_angle(%0) ((%0 >> 20) & 0x1FF)
#define get_perk_rotation(%0) ((%0 >> 29) & 0x7)
new perks[FACES_MAX];
new count_all_perks;

new bool:is_gameover = false;

new newAngles[FACES_MAX] = [180, 180, 180];

new bool:testing = false;
new bool:pause = false;
new colx, coly;
new px, py;
new sx, sy;
new nsx, nsy;
new npx, npy;
new ccols;
new ncolx1, ncoly1, ncolx2, ncoly2;