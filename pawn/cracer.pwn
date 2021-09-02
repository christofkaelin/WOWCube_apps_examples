forward run(const pkt[], size, const src[]); // public Pawn function seen from C
#include "cubios_abi.pwn"
#include "results.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

new pause = false;
new cr_debug[.x, .y, .angle, .target_angle];
new test = 0;

#include "cracer_variables.pwn" 
#include "cracer_functions.pwn" 


ON_PHYSICS_TICK() {

    if (pause) return;

    for (face = 0; face < FACES_MAX; face++) {
        RotateAngle(newAngles[face], current_angle[face]);
        CalcMoveCar(face);

    }
    CalcCountDown();
    CalcGameLogic();
    SetTitlePositions();
    SendToMaster();
    CalculateGameStatus();
}

RENDER() {

    RememberBackGroundG2D();

    for (face = 0; face < FACES_MAX; face++) {

        #ifdef G2D
        abi_CMD_G2D_BEGIN_DISPLAY(face, true);
        abi_CMD_G2D_ADD_RECTANGLE(0, 0, DISPLAY_WIDTH, DISPLAY_HEIGHT, 0xFF000000);
        DrawBackgroundG2D(face);
        #else
        abi_CMD_FILL(0, 0, 0);
        DrawBackgroundBitmap(face);
        #endif

        DrawItems(face);

        DrawCar(face);
        DrawLandScape(face);

        DrawHud(face);

        DrawCountDown(face);

        DrawTitle(face);
        /*
                //abi_CMD_TEXT_ITOA(game.level, 0, 40, 20, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                //abi_CMD_TEXT_ITOA(game.level_trying, 0, 40, 40, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                //abi_CMD_TEXT_ITOA(game.is_generated, 0, 80, 20, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.is_departing, 0, 20, 20, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.count_transition, 0, 20, 40, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(CUBES_MAX * FACES_MAX - 1 - (game.level + 1), 0, 20, 60, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.slippage, 0, 20, 80, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(game.countdown, 0, 20, 100, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(game.status, 0, 20, 120, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(test, 0, 20, 140, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        */

        //abi_CMD_TEXT_ITOA(roadway[abi_cubeN].road_cube, 0, 180, 200, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        //abi_CMD_TEXT_ITOA(roadway[abi_cubeN].road_face[face], 0, 200, 200, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        /*
                abi_CMD_TEXT_ITOA(cr.cube, 0, 180, 200, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.face, 0, 200, 200, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);

                abi_CMD_TEXT_ITOA(abi_cubeN, 0, 20, 200, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(face, 0, 40, 200, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);

                abi_CMD_TEXT_ITOA(cr.x, 0, 200, 20, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.y, 0, 200, 40, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.speed_x, 0, 200, 60, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.speed_y, 0, 200, 80, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr.angle, 0, 200, 100, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        */
        /*
                abi_CMD_TEXT_ITOA(cr_debug.x, 0, 120, 20, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr_debug.y, 0, 120, 40, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr_debug.target_angle, 0, 120, 60, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
                abi_CMD_TEXT_ITOA(cr_debug.angle, 0, 120, 80, 10, 0, TEXT_ALIGN_CENTER, 255, 255, 255, .useG2D = useG2D);
        */


        #ifdef G2D
        abi_CMD_G2D_END();
        #else
        abi_CMD_REDRAW(face);
        #endif
    }

}

ONTICK() {
    CheckAngles();

    GenerateLevel();

    CheckMigration();

    SendGameInfo();
    SendCar();

    //check the shake to exit the menu
    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}

ON_LOAD_GAME_DATA() {}

ON_INIT() {
    game.level = -1;
    game.level_trying = -1;
    InitVariables();
}

ON_CMD_NET_RX(const pkt[]) {
    switch (abi_ByteN(pkt, 4)) {
        case CMD_SEND_GAME_INFO:  {
            DeSerializeGameInfo(pkt);
        }
        case CMD_SEND_CAR:  {
            DeSerializeCar(pkt);
        }
        case CMD_SEND_TO_MASTER:  {
            DeSerializeToMaster(pkt);
        }
    }
}
ON_CHECK_ROTATE() {

    if ( /*(abi_cubeN == 0) && */ ((game.status == GAME_OVER || game.status == GAME_COMPLETE))) {
        if (game.status == GAME_OVER) {
            game.level--;
        }
        InitVariables();
    }
    pause = false;
}

#ifdef CUBIOS_EMULATOR
cr_main() {
    new opt { 100 }
    argindex(0, opt);
    abi_cubeN = strval(opt);
    printf("Cube %d logic. Listening on port: %d\n", abi_cubeN, (PAWN_PORT_BASE + abi_cubeN));
    listenport(PAWN_PORT_BASE + abi_cubeN);
}
#endif