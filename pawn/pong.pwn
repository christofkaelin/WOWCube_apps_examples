forward run(const pkt[], size, const src[]); // public Pawn function seen from C
#include "cubios_abi.pwn"
//#include "results.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

#include "pong_var.pwn"
#include "pong_collisions.pwn"
#include "pong_func.pwn"

new test = 0;
ON_PHYSICS_TICK() {
    for (g_face = 0; g_face < FACES_MAX; g_face++) {
        CheckCollidePerk();
        MoveBall();
    }
}

RENDER() {
    if ((ball_object == 0xFFFFFFFF) /*&& (!is_gameover)*/) return;

    for (g_face = 0; g_face < FACES_MAX; g_face++) {
        DrawBegin();

        DrawBackGround();

        //DrawHUD();

        DrawBall();

        DrawPerks();

        DrawResults();

        DrawEnd();

        CheckDepaturing(); // needed here for correct wall rendering
    }
}

ONTICK() {
    InitLevel();

    //if(pause) return;

    if ((ball_object == 0xFFFFFFFF) && (!is_gameover)) return;

    CheckAngles();

    if (0 == abi_cubeN) {
        abi_checkShake();
        SendWalls();

        is_gameover = ((count_all_perks == 0) ? true : false);

        if (!is_gameover)
            local_ticks = ((local_ticks < 0xFFFFFFF) ? local_ticks + 1 : 0);
    }
    if ((is_dep) || ((abi_cubeN == get_cube(ball_object)) && (get_face(ball_object) < FACES_MAX)))
        SendBall();


    SendStatus();
    SetGameOver();
}

ON_INIT() {
    SetWallObjects();
    ball_object = 0xFFFFFFFF;
    ball_object_dep = 0xFFFFFFFF;
    ball_movings = 0xFFFFFFFF;
    ball_movings_dep = 0xFFFFFFFF;
    count_movings = 0;
    count_rotation = 0;
    local_ticks = 0;
}

ON_CMD_NET_RX(const pkt[]) {
    switch (abi_ByteN(pkt, 4)) {
        case CMD_STATUS:  {
            if ((level == abi_ByteN(pkt, 6)) && ((count_rotation <= abi_ByteN(pkt, 7)) || ((abi_ByteN(pkt, 7) == 0) && (count_rotation != 0)))) {
                if (abi_cubeN != 0) {
                    count_rotation = abi_ByteN(pkt, 7);
                    is_gameover = ((((abi_ByteN(pkt, 5) >> 6) & 0x1) == 1) ? true : false);
                    local_ticks = pkt[2];
                    count_moves = pkt[3];
                } else {
                    if ((((abi_ByteN(pkt, 5) >> 3) & 0x7) == 0) && (((count_all_perks >> (abi_ByteN(pkt, 5) & 0x7)) & 0x1) != 0)) {
                        count_all_perks &= ~(1 << (abi_ByteN(pkt, 5) & 0x7));
                    }
                }
            }
        }
        case CMD_SEND_WALLS:  {
            if (abi_ByteN(pkt, 5) != level) {
                level = abi_ByteN(pkt, 5);
                GeneratePerks();
                for (g_face = 0; g_face < FACES_MAX; g_face++)
                    walls[g_face] = pkt[g_face + 2];
            }
        }
        case CMD_SEND_BALL:  {
            if ((level == abi_ByteN(pkt, 6)) && (count_movings < abi_ByteN(pkt, 7))) {
                if ((get_cube(ball_object) != get_cube(pkt[2])) || ((ball_object == 0xFFFFFFFF) && (pkt[2] != ball_object))) {
                    ball_object = pkt[2];
                    ball_movings = pkt[3];
                    ball_object_dep = ball_object;
                    ball_movings_dep = ball_movings;
                    test = 1;
                }
                is_dep = ((abi_cubeN != abi_ByteN(pkt, 5)) ? false : is_dep);
                count_movings = abi_ByteN(pkt, 7);
                if (abi_cubeN == get_cube(ball_object))
                    count_movings = (((!is_gameover) && (count_movings < 0xFF)) ? count_movings + 1 : 0);
            }
        }
    }
}

ON_CHECK_ROTATE() {
    if (abi_cubeN == 0) {
        count_rotation = ((count_rotation < 0xFF) ? count_rotation + 1 : 0);
        count_rotation = ((is_gameover) ? 0 : count_rotation);
        pause = false;
        count_all_perks = 0xFF;
        is_gameover = false;
        #ifdef DEBUG
        is_gameover = ((count_rotation == 5) ? true : false); //is_gameover);
        #endif
        count_moves++;
    }

}
ON_LOAD_GAME_DATA(const pkt[]) {

}
#ifdef CUBIOS_EMULATOR
main() {
    new opt { 100 }
    argindex(0, opt);
    abi_cubeN = strval(opt);
    printf("Cube %d logic. Listening on port: %d\n", abi_cubeN, (PAWN_PORT_BASE + abi_cubeN));
    listenport(PAWN_PORT_BASE + abi_cubeN);
}
#endif