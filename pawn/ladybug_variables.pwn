#define G2D
#ifdef G2D
new bool:useG2D = true;
#else
new bool:useG2D = false;
#endif

#define SOUND

#define DISPLAY_WIDTH       240
#define DISPLAY_HEIGHT      240
#define SHADOW_DIST         30

#define POINT               .x, .y, .angle
#define DEPARTING           .dep_cube, .dep_face, .dep_x, .dep_y, .dep_angle, .dep_speed_x, .dep_speed_y, bool: .is_departing
#define LADYBUG_POSITIONS   .cube, .face, POINT, DEPARTING, .speed_x, .speed_y, .count_transition, .multiplier, .target_angle, .slippage
#define ROADS               .road_type, .angle
#define LANDSCAPE_TYPE      .object, POINT, .mirror   


#define CMD_PAWN 150

#define CMD_SEND_GAME_INFO      CMD_PAWN
#define CMD_SEND_LADYBUG        CMD_PAWN + 1
#define CMD_SEND_TO_MASTER      CMD_PAWN + 2

#define HUD_SHAKE           26
#define HUD_SCORE           27
#define HUD_LEVEL           28
#define HUD_BONUS           29

#define LADYBUG_ANIMATION_MAX    8

#define HUD_HEALTH_FULL     16
#define HUD_HEALTH          17
#define PIC_SHADOWS_BIG     18
#define PIC_POISON          21
#define PIC_PLATE           25
#define PIC_LADYBUG         26
#define PIC_CROSROAD        34
#define PIC_STRAIGHT_ROAD   PIC_CROSROAD + 1
#define PIC_END_OF_ROAD     PIC_CROSROAD + 2
#define PIC_TURNING         58

#define ENUM_FRUITS_MAX     4

#define INIT_HEALTH         4

#define TURN_NULL           0
#define TURN_LEFT           -90
#define TURN_RIGHT          90

#define MOVE_TO_TOP         0
#define MOVE_TO_RIGHT       1
#define MOVE_TO_BOTTOM      2
#define MOVE_TO_LEFT        3
#define MOVE_NONE           4

#define SPEED               7

#define LADYBUG_SIZE        100

#define MINIROAD_SIZE       60

#define STRAIGHT_ROAD       0
#define CROSROAD            1
#define END_OF_ROAD         2
#define ROADS_MAX           END_OF_ROAD + 1

#define ANGLE_0             0
#define ANGLE_90            1
#define ANGLE_180           2
#define ANGLE_270           3
#define ANGLES_MAX          4

#define PLACES_X            3
#define PLACES_Y            3
#define PLACES_MAX          PLACES_X * PLACES_Y
#define PLACE_FRUIT         4

#define PIC_COUNTDOWN       0
#define COUNTDOWN_PLAY      4
#define COUNTDOWN_GO        0
#define TICKS_TO_COUNTDOWN  7

#define LANDSCAPE_OBJECT_TYPE_MAX   3
#define LANDSCAPES_MAX      9

#define FRUIT_ANIMATION_MAX 12

#define SOUND_STARTING      0
#define SOUND_GAMEOVER      1
#define SOUND_POISON        2
#define SOUND_BERRY_EAT     3

#define SOUND_VOLUME        95

#define SLIPPAGE_TICKS      30

#define MIGRATION_NONE      0
#define MIGRATION_TOP       1
#define MIGRATION_RIGHT     2
#define MIGRATION_BOTTOM    3
#define MIGRATION_LEFT      4

#define AVAIBLE_ROADS_MAX   6

#define MULTIPLIER_PKT      2

#define GAME_PLAY       0
#define GAME_OVER       1
#define GAME_COMPLETE   2

#define BITS_FOR_SERIALIZE      5
#define PIC_CROSROADS   34
#define PIC_LANDSCAPE   37

#define POISON          0

new cube, face;

new place_x, place_y;

#define MAX_LEVEL   6
#define MAX_LANDS   2

#define ANGLE_ROTATE          10
new newAngles[FACES_MAX] = [180, 180, 180];
new current_angle[FACES_MAX] = [180, 180, 180];

new fruits_animation[FRUIT_ANIMATION_MAX] = [8, 6, 5, 4, 3, 2, 0, 2, 3, 4, 5, 6];

new friuts_shadows[FRUIT_ANIMATION_MAX] = [2, 2, 1, 1, 1, 0, 0, 0, 1, 1, 1, 2];

new game[.local_ticks,
    .level,
    .health,
    .time_bonus,
    .score,
    .countdown,
    .status,
    .level_trying,
    bool: .is_set_back[FACES_MAX],
    bool: .is_generated,
    .titres_cube[FACES_ON_PLANE],
    .titres_face[FACES_ON_PLANE],
    bool:.is_set_titres
];

new landscapes[FACES_MAX][PLACES_MAX][LANDSCAPE_TYPE];
new ladybug[LADYBUG_POSITIONS];

new roadway[CUBES_MAX][.road_cube, .road_face[FACES_MAX], .fruit[FACES_MAX]];

//presets for leveling and models of roads
new background[][.color, .red, .green, .blue, .crosroad, .straight_road, .end_of_road, .turning, .fruit_pic, .landscape_pic] = [
    [0xFF83C547, 19, 48, 8, PIC_CROSROADS + 12, PIC_CROSROADS + 1 + 12, PIC_CROSROADS + 2 + 12, PIC_TURNING, PIC_POISON, PIC_LANDSCAPE + 12], //0xFFFF9933
   // [0xFFFF9933, 31, 38, 6, PIC_CROSROADS, PIC_CROSROADS + 1, PIC_CROSROADS + 2, PIC_TURNING, PIC_POISON, PIC_LANDSCAPE] //0xFF9EC547
];

new models_of_roads[CUBES_MAX][FACES_MAX][ROADS] = [
    [
        [END_OF_ROAD, ANGLE_270],
        [CROSROAD, ANGLE_90],
        [CROSROAD, ANGLE_270]
    ],
    [
        [CROSROAD, ANGLE_0],
        [STRAIGHT_ROAD, ANGLE_180],
        [STRAIGHT_ROAD, ANGLE_270]
    ],
    [
        [CROSROAD, ANGLE_180],
        [STRAIGHT_ROAD, ANGLE_270],
        [STRAIGHT_ROAD, ANGLE_180]
    ],
    [
        [CROSROAD, ANGLE_180],
        [CROSROAD, ANGLE_90],
        [CROSROAD, ANGLE_270]
    ],
    [
        [CROSROAD, ANGLE_180],
        [CROSROAD, ANGLE_180],
        [CROSROAD, ANGLE_180]
    ],
    [
        [CROSROAD, ANGLE_270],
        [CROSROAD, ANGLE_90],
        [CROSROAD, ANGLE_0]
    ],
    [
        [CROSROAD, ANGLE_90],
        [STRAIGHT_ROAD, ANGLE_180],
        [CROSROAD, ANGLE_180]
    ],
    [
        [CROSROAD, ANGLE_270],
        [STRAIGHT_ROAD, ANGLE_90],
        [CROSROAD, ANGLE_0]
    ]
]