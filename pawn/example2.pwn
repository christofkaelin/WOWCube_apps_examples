#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define TEXT_SIZE       8

ONTICK() {
    /*
    new screenI;
    new red = 30, green = 30, blue = 30;
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //filling screen another colors
        abi_CMD_FILL(red, green, blue);
        //push buffer at screen
        abi_CMD_REDRAW(screenI);
    }*/

    new screenI;
    new red = 31, green = 63, blue = 31;
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        abi_CMD_FILL(red, green, blue);
        //abi_CMD_TEXT_ITOA(100, 0, 230, 180, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);

        //draw text
        abi_CMD_TEXT("HELLO WORLD", 0, DISPLAY_WIDTH / 2, 60, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
        {
            new string[4];  // 4 cells is 16 bytes (16 packed characters including null terminator)
            strformat(string, sizeof(string), true, "MODULE %d", abi_cubeN);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 120, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
        }
        {
            new string[4];
            strformat(string, sizeof(string), true, "SCREEN %d", screenI);
            abi_CMD_TEXT(string, 0, DISPLAY_WIDTH / 2, 180, TEXT_SIZE, 0, TEXT_ALIGN_CENTER, 255, 255, 255);
        }

        //abi_CMD_FILL(255, 255, 255);

        //push buffer at screen
        abi_CMD_REDRAW(screenI);
    }
    if (0 == abi_cubeN) {
        abi_checkShake();
    }

}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}
