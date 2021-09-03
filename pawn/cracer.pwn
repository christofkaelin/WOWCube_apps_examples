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

    //check for shake to exit the menu
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

    if (((game.status == GAME_OVER || game.status == GAME_COMPLETE))) {
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