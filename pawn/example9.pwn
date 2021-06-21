#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"
const SSP = 240
const FONT = -1;
const CENTER = TEXT_ALIGN_CENTER
const TOP_CENTER = TEXT_ALIGN_TOP_CENTER
const BOTTOM_CENTER = TEXT_ALIGN_BOTTOM_CENTER
const CENTER_LEFT = TEXT_ALIGN_LEFT_CORNER
const TOP_LEFT = TEXT_ALIGN_LEFT_TOP_CORNER
const BOTTOM_LEFT = TEXT_ALIGN_LEFT_BOTTOM_CORNER
const CENTER_RIGHT = TEXT_ALIGN_RIGHT_CORNER
const TOP_RIGHT = TEXT_ALIGN_RIGHT_TOP_CORNER
const BOTTOM_RIGHT = TEXT_ALIGN_RIGHT_BOTTOM_CORNER
new tap_x = 0; // последнее кол-во тапов
new tap_y = 0;
new tap_z = 0;
ONTICK() {
    for (new sid = 0; sid < 3; sid++) {
        new off_x = SSP / 2
        new off_y = SSP / 2
        new rot = 0
        new scale = 100
        abi_CMD_FILL(0, 0, 0)
        abi_CMD_LINE(0, 0, off_x, off_y, 255, 255, 255)
        abi_CMD_TEXT_ITOA(sid, FONT, 0, 0, scale, rot, TOP_LEFT, 255, 255, 255)
        if (abi_MTD_TapsCount != 0) {
            if (abi_MTD_TapFace == 0) { tap_x = abi_MTD_TapsCount; }
            if (abi_MTD_TapFace == 1) { tap_y = abi_MTD_TapsCount; }
            if (abi_MTD_TapFace == 2) { tap_z = abi_MTD_TapsCount; }
            printf("tapface+ %d \n", abi_MTD_TapFace)
            // if (abi_MTD_TapOpposite)
        }
        if (tap_x != 0 && sid == 0) {
            abi_CMD_TEXT_ITOA(0, FONT, 0, 0, scale, rot, TOP_LEFT, 255, 255, 255)
            abi_CMD_TEXT_ITOA(tap_x, FONT, off_x, off_y, scale, rot, TOP_LEFT, 255, 255, 255)
        }
        if (tap_y != 0 && sid == 1) {
            abi_CMD_TEXT_ITOA(1, FONT, 0, 0, scale, rot, TOP_LEFT, 255, 255, 255)
            abi_CMD_TEXT_ITOA(tap_y, FONT, off_x, off_y, scale, rot, TOP_LEFT, 255, 255, 255)
        }
        if (tap_z != 0 && sid == 2) {
            abi_CMD_TEXT_ITOA(1, FONT, 0, 0, scale, rot, TOP_LEFT, 255, 255, 255)
            abi_CMD_TEXT_ITOA(tap_z, FONT, off_x, off_y, scale, rot, TOP_LEFT, 255, 255, 255)
        }
        abi_CMD_REDRAW(sid)
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
