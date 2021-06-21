#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

ONTICK() {
    new screenI;
    new red = 5, green = 10, blue = 15;
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //filling screen another colors
        abi_CMD_FILL(red * screenI + abi_cubeN * 10, green * screenI + abi_cubeN * 10, blue * screenI + abi_cubeN * 10);
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
