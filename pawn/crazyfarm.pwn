#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define TEXT_SIZE       8

ONTICK() {
    // Set anchors
    new anchorTopCube = abi_bottomCubeN(0, 0);
    new anchorTopFace = abi_bottomFaceN(0, 0);
    new anchorRightCube = abi_bottomCubeN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0));
    new anchorRightFace = abi_bottomFaceN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0));
    new anchorLeftCube = abi_rightCubeN(0, 0);
    new anchorLeftFace = abi_rightFaceN(0, 0);
    new anchorOppositeCube = abi_bottomCubeN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace));
    new anchorOppositeFace = abi_bottomFaceN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace));

    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        // Main menu
        if ((abi_cubeN == anchorTopCube) && (screenI == anchorTopFace)) {
            abi_CMD_FILL(0, 0, 0);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                abi_CMD_FILL(255, 255, 255);
            }
        } else if (abi_cubeN == abi_leftCubeN(anchorTopCube, anchorTopFace) && screenI == abi_leftFaceN(anchorTopCube, anchorTopFace)) {
            abi_CMD_FILL(0, 0, 0);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                abi_CMD_FILL(255, 255, 255);
            }
        } else if (abi_cubeN == abi_topCubeN(anchorTopCube, anchorTopFace) && screenI == abi_topFaceN(anchorTopCube, anchorTopFace)) {
            abi_CMD_FILL(0, 0, 0);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                abi_CMD_FILL(255, 255, 255);
            }
        } else if (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorTopCube, anchorTopFace), abi_leftFaceN(anchorTopCube, anchorTopFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorTopCube, anchorTopFace), abi_leftFaceN(anchorTopCube, anchorTopFace))) {
            abi_CMD_FILL(0, 0, 0);
            if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
                abi_CMD_FILL(255, 255, 255);
            }
        }

        // Draw main side
        else if (
            ((abi_cubeN == 0) && (screenI == 0)) ||
            (abi_cubeN == abi_leftCubeN(0, 0) && screenI == abi_leftFaceN(0, 0)) ||
            (abi_cubeN == abi_topCubeN(0, 0) && screenI == abi_topFaceN(0, 0)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0)) && screenI == abi_leftFaceN(abi_leftCubeN(0, 0), abi_leftFaceN(0, 0)))
        ) {
            abi_CMD_FILL(255, 0, 0);
        }
        // Draw right side
        else if (
            ((abi_cubeN == anchorRightCube) && (screenI == anchorRightFace)) ||
            (abi_cubeN == abi_leftCubeN(anchorRightCube, anchorRightFace) && screenI == abi_leftFaceN(anchorRightCube, anchorRightFace)) ||
            (abi_cubeN == abi_topCubeN(anchorRightCube, anchorRightFace) && screenI == abi_topFaceN(anchorRightCube, anchorRightFace)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorRightCube, anchorRightFace), abi_leftFaceN(anchorRightCube, anchorRightFace)))
        ) {
            abi_CMD_FILL(0, 255, 0);
        }
        // Draw left side
        else if (
            ((abi_cubeN == anchorLeftCube) && (screenI == anchorLeftFace)) ||
            (abi_cubeN == abi_leftCubeN(anchorLeftCube, anchorLeftFace) && screenI == abi_leftFaceN(anchorLeftCube, anchorLeftFace)) ||
            (abi_cubeN == abi_topCubeN(anchorLeftCube, anchorLeftFace) && screenI == abi_topFaceN(anchorLeftCube, anchorLeftFace)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorLeftCube, anchorLeftFace), abi_leftFaceN(anchorLeftCube, anchorLeftFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorLeftCube, anchorLeftFace), abi_leftFaceN(anchorLeftCube, anchorLeftFace)))
        ) {
            abi_CMD_FILL(0, 0, 255);
        }
        // Draw opposite side
        else if (
            ((abi_cubeN == anchorOppositeCube) && (screenI == anchorOppositeFace)) ||
            (abi_cubeN == abi_leftCubeN(anchorOppositeCube, anchorOppositeFace) && screenI == abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)) ||
            (abi_cubeN == abi_topCubeN(anchorOppositeCube, anchorOppositeFace) && screenI == abi_topFaceN(anchorOppositeCube, anchorOppositeFace)) ||
            (abi_cubeN == abi_leftCubeN(abi_leftCubeN(anchorOppositeCube, anchorOppositeFace), abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)) && screenI == abi_leftFaceN(abi_leftCubeN(anchorOppositeCube, anchorOppositeFace), abi_leftFaceN(anchorOppositeCube, anchorOppositeFace)))
        ) {
            abi_CMD_FILL(255, 255, 0);
        } else {
            abi_CMD_FILL(0, 0, 0);
        }
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
