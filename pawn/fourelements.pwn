#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"
#include <time>

#define FIRE          0
#define WATER       512
#define EARTH      1024
#define WIND       1536

new picture, element_min = FIRE;
new element = 0;

#define CMD_SEND_ELEMENT P2P_CMD_BASE_SCRIPT_1 + 1

send_element() {
    new data[4];

    data[0] = ((CMD_SEND_ELEMENT & 0xFF));
    data[1] = ((element & 0xFF));

    // send message through UART
    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data);
}

ONTICK() {
    switch (element) {
        case 0:
            element_min = FIRE;
        case 1:
            element_min = WATER;
        case 2:
            element_min = EARTH;
        case 3:
            element_min = WIND;
    }

    //recalculate angle based on trbl
    CheckAngles();

    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        new anchorTopCube = abi_bottomCubeN(0, 0);
        new anchorTopFace = abi_bottomFaceN(0, 0);
        new anchorRightCube = abi_bottomCubeN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0));
        new anchorRightFace = abi_bottomFaceN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0));
        new anchorLeftCube = abi_rightCubeN(0, 0);
        new anchorLeftFace = abi_rightFaceN(0, 0);
        new anchorOppositeCube = abi_bottomCubeN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace));
        new anchorOppositeFace = abi_bottomFaceN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace));
        // Main menu
        if ((abi_cubeN == anchorTopCube) && (screenI == anchorTopFace)) {
            abi_CMD_FILL(0, 0, 0);
            abi_CMD_BITMAP(2048, 120, 120, newAngles[screenI], MIRROR_BLANK);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                element = 0;
                send_element();
            }
        } else if (abi_cubeN == abi_leftCubeN(anchorTopCube, anchorTopFace) && screenI == abi_leftFaceN(anchorTopCube, anchorTopFace)) {
            abi_CMD_FILL(0, 0, 0);
            abi_CMD_BITMAP(2049, 120, 120, newAngles[screenI], MIRROR_BLANK);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                element = 1;
                send_element();
            }
        } else if (abi_cubeN == abi_topCubeN(anchorTopCube, anchorTopFace) && screenI == abi_topFaceN(anchorTopCube, anchorTopFace)) {
            abi_CMD_FILL(0, 0, 0);
            abi_CMD_BITMAP(2050, 120, 120, newAngles[screenI], MIRROR_BLANK);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                element = 2;
                send_element();
            }
        } else if (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorTopCube, anchorTopFace), abi_leftFaceN(anchorTopCube, anchorTopFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorTopCube, anchorTopFace), abi_leftFaceN(anchorTopCube, anchorTopFace))) {
            abi_CMD_FILL(0, 0, 0);
            abi_CMD_BITMAP(2051, 120, 120, newAngles[screenI], MIRROR_BLANK);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                element = 3;
                send_element();
            }
        }
        // Draw main side
        else if (
            ((abi_cubeN == 0) && (screenI == 0)) ||
            (abi_cubeN == abi_leftCubeN(0, 0) && screenI == abi_leftFaceN(0, 0)) ||
            (abi_cubeN == abi_topCubeN(0, 0) && screenI == abi_topFaceN(0, 0)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0)) && screenI == abi_leftFaceN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0)))
        ) {
            abi_CMD_BITMAP(picture + newAngles[screenI] / 90, 120, 120, newAngles[screenI], MIRROR_BLANK);
        }
        // Draw right side
        else if (
            ((abi_cubeN == anchorRightCube) && (screenI == anchorRightFace)) ||
            (abi_cubeN == abi_leftCubeN(anchorRightCube, anchorRightFace) && screenI == abi_leftFaceN(anchorRightCube, anchorRightFace)) ||
            (abi_cubeN == abi_topCubeN(anchorRightCube, anchorRightFace) && screenI == abi_topFaceN(anchorRightCube, anchorRightFace)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace)))
        ) {
            abi_CMD_BITMAP(picture + (newAngles[screenI] / 90) - 2, 120, 120, newAngles[screenI] + 180, MIRROR_BLANK);
        }
        // Draw left side
        else if (
            ((abi_cubeN == anchorLeftCube) && (screenI == anchorLeftFace)) ||
            (abi_cubeN == abi_leftCubeN(anchorLeftCube, anchorLeftFace) && screenI == abi_leftFaceN(anchorLeftCube, anchorLeftFace)) ||
            (abi_cubeN == abi_topCubeN(anchorLeftCube, anchorLeftFace) && screenI == abi_topFaceN(anchorLeftCube, anchorLeftFace)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorLeftCube, anchorLeftFace), abi_leftFaceN(anchorLeftCube, anchorLeftFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorLeftCube, anchorLeftFace), abi_leftFaceN(anchorLeftCube, anchorLeftFace)))
        ) {
            abi_CMD_BITMAP(picture + (newAngles[screenI] / 90) - 1, 120, 120, newAngles[screenI] - 90, MIRROR_BLANK);
        }
        // Draw opposite side
        else if (
            ((abi_cubeN == anchorOppositeCube) && (screenI == anchorOppositeFace)) ||
            (abi_cubeN == abi_leftCubeN(anchorOppositeCube, anchorOppositeFace) && screenI == abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)) ||
            (abi_cubeN == abi_topCubeN(anchorOppositeCube, anchorOppositeFace) && screenI == abi_topFaceN(anchorOppositeCube, anchorOppositeFace)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorOppositeCube, anchorOppositeFace), abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorOppositeCube, anchorOppositeFace), abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)))
        ) {
            abi_CMD_BITMAP(picture + (newAngles[screenI] / 90) + 1, 120, 120, newAngles[screenI] + 90, MIRROR_BLANK);
        } else {
            abi_CMD_FILL(0, 0, 0);
        }
        abi_CMD_REDRAW(screenI);
    }

    if ((picture >= (element_min + 504)) || (picture < element_min)) {
        picture = element_min;
    }

    picture = picture + 4;
    delay(40);

    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {
    switch (abi_ByteN(pkt, 4)) {
        case CMD_SEND_ELEMENT:  {
            if (abi_ByteN(pkt, 5) == 0) {
                element = abi_ByteN(pkt, 8);
            }
        }
    }
}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}
