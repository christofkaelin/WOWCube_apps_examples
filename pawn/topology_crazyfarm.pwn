#include "cubios_abi.pwn"

const MAX_CUBE_SIDES = 6;

new topology_TopmostModule = CUBES_MAX;
new topology_TopmostScreen = FACES_MAX;

new topology_TopmostModules { FACES_ON_PLANE } = { CUBES_MAX, ... };
new topology_TopmostScreens { FACES_ON_PLANE } = { FACES_MAX, ... };

new topology_ScreensAngles[FACES_MAX] = [180, ...];

new topology_ScreensSides { CUBES_MAX * FACES_MAX } = { CUBES_MAX, CUBES_MAX, ... };
new topology_ScreensAnglesAll[CUBES_MAX * FACES_MAX] = [0, ...];

Topology_FindFacesAngles(farModule, farScreen, startAngle = 180, isGravitationOn = 0, topmostModule = 0) {
    new angle;
    new neighborModuleN = farModule;
    new neighborScreenN = farScreen;
    new tmp_moduleN = 0;
    new tmp_screenN = 0;
    for (new screenI = 0; screenI < FACES_MAX; ++screenI) {
        if (startAngle >= 180) {
            if (!isGravitationOn) {
                angle = (startAngle + ((screenI == 1) * 270) + (screenI == 2) * 90) % 360;
            } else {
                angle = startAngle - (screenI == 2) * 90;
            }
        } else {
            if (!isGravitationOn) {
                angle = startAngle + (screenI == 2) * 270;
            } else {
                angle = startAngle + (screenI == 1) * 270;
            }
        }

        if (farModule == abi_cubeN) {
            topology_ScreensAngles[farScreen] = angle % 360;
        }
        topology_ScreensSides { farModule * FACES_MAX + farScreen } = screenI + ((farModule != topmostModule) * FACES_MAX);
        topology_ScreensAnglesAll[farModule * FACES_MAX + farScreen] = angle % 360;

        for (new count = 0; count < FACES_MAX; ++count) {
            tmp_moduleN = abi_topCubeN(neighborModuleN, neighborScreenN);
            tmp_screenN = abi_topFaceN(neighborModuleN, neighborScreenN);

            angle = (angle += 90) % 360;
            if (tmp_moduleN >= CUBES_MAX) {
                return 0;
            }
            if (tmp_moduleN == abi_cubeN) {
                topology_ScreensAngles[tmp_screenN] = angle;
            }
            topology_ScreensSides { tmp_moduleN * FACES_MAX + tmp_screenN } = screenI + ((farModule != topmostModule) * FACES_MAX);
            topology_ScreensAnglesAll[tmp_moduleN * FACES_MAX + tmp_screenN] = angle;

            neighborModuleN = tmp_moduleN;
            neighborScreenN = tmp_screenN;
        }

        neighborModuleN = farModule;
        neighborScreenN = farScreen = abi_rightFaceN(neighborModuleN, farScreen);
    }

    return 1;
}

Topology_CheckAngles(far_cubeN = 0, far_faceN = 0, isGravitationOn = 0, topmostModule = 0) {

    if (!Topology_FindFacesAngles(far_cubeN, far_faceN, 180, isGravitationOn, topmostModule)) {
        return 0;
    }

    new tmp_moduleN = 0;
    new tmp_screenN = 0;
    new neighborModuleN = far_cubeN;
    new neighborScreenN = far_faceN;

    // Search diagonal modules relative on the 0 module 0 screen = left module + screen, left module + screen, bottom module + screen, left module + screen
    for (new moduleI = 0; moduleI < FACES_ON_PLANE; ++moduleI) {
        if (moduleI != 2) {
            tmp_moduleN = abi_leftCubeN(neighborModuleN, neighborScreenN);
            tmp_screenN = abi_leftFaceN(neighborModuleN, neighborScreenN);
            if (tmp_moduleN >= CUBES_MAX) {
                return 0;
            }
            neighborModuleN = tmp_moduleN;
            neighborScreenN = tmp_screenN;
        } else {
            tmp_screenN = abi_bottomFaceN(neighborModuleN, neighborScreenN);
            neighborScreenN = tmp_screenN;
        }
    }

    return Topology_FindFacesAngles(neighborModuleN, neighborScreenN, 0, isGravitationOn, topmostModule);
}

Topology_FindTopMostModule(isGravitationOn = 0) {
    topology_TopmostModules = { CUBES_MAX, CUBES_MAX, CUBES_MAX, CUBES_MAX };
    topology_TopmostScreens = { FACES_MAX, FACES_MAX, FACES_MAX, FACES_MAX };
    topology_TopmostModule = CUBES_MAX;
    topology_TopmostScreen = FACES_MAX;

    GetTopmostModuleAndScreen(abi_cubeN, 0, topology_TopmostModule, topology_TopmostScreen);
    GetTopmostModuleAndScreen(abi_cubeN, 1, topology_TopmostModule, topology_TopmostScreen);
    GetTopmostModuleAndScreen(abi_cubeN, 2, topology_TopmostModule, topology_TopmostScreen);

    if ((topology_TopmostModule < CUBES_MAX) && (topology_TopmostScreen < FACES_MAX)) {
        new neighborCube = topology_TopmostModules { 0 } = topology_TopmostModule;
        new neighborFace = topology_TopmostScreens { 0 } = topology_TopmostScreen;
        for (new screenI = 0; screenI < FACES_MAX; ++screenI) {
            new topModule = abi_topCubeN(neighborCube, neighborFace);
            new topScreen = abi_topFaceN(neighborCube, neighborFace);
            if (topModule >= CUBES_MAX) {
                return 0;
            }
            /*if (topModule < topology_TopmostModule) {
                topology_TopmostModule = topModule;
                topology_TopmostScreen = topScreen;
            }*/
            topology_TopmostModules { screenI + 1 } = neighborCube = topModule;
            topology_TopmostScreens { screenI + 1 } = neighborFace = topScreen;
        }
    } else {
        return 0;
    }

    return Topology_CheckAngles(topology_TopmostModule, topology_TopmostScreen, isGravitationOn, topology_TopmostModule);
}

GetTopmostModuleAndScreen(const thisCubeN, const thisFaceN, & cubeN, & screenN) {
    new accelX = abi_MTD_GetFaceAccelX(thisFaceN);
    new accelY = abi_MTD_GetFaceAccelY(thisFaceN);
    new accelZ = abi_MTD_GetFaceAccelZ(thisFaceN);
    new neighborModuleN = CUBES_MAX;
    new neighborScreenN = FACES_MAX;
    new cubeN_tmp = thisCubeN;
    new faceN_tmp = thisFaceN;

    if ((ABS(accelZ) > ABS(accelX)) && (ABS(accelZ) > ABS(accelY))) {
        if (accelZ < 0) {
            if (ABS(accelY) > ABS(accelX)) {
                if (accelY < 0) {
                    //cubeN = cubeN_tmp;
                    //screenN = faceN_tmp;
                } else {
                    neighborModuleN = abi_topCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_topFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = abi_topCubeN(neighborModuleN, neighborScreenN);
                    faceN_tmp = abi_topFaceN(neighborModuleN, neighborScreenN);
                    if (!((cubeN_tmp < CUBES_MAX) && (faceN_tmp < FACES_MAX)))
                        return;
                }
            } else {
                if (accelX < 0) {
                    neighborModuleN = abi_topCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_topFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = neighborModuleN;
                    faceN_tmp = neighborScreenN;
                } else {
                    neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = neighborModuleN;
                    faceN_tmp = neighborScreenN;
                }
            }
        } else {
            //far far cubeN and faceNa
            neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
            neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
            if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                return;
            cubeN_tmp = neighborModuleN;
            faceN_tmp = neighborScreenN;

            neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
            neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
            if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                return;
            neighborScreenN = abi_bottomFaceN(neighborModuleN, neighborScreenN);

            cubeN_tmp = neighborModuleN;
            faceN_tmp = neighborScreenN;

            neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
            neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
            if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                return;

            neighborScreenN = abi_bottomFaceN(neighborModuleN, neighborScreenN);

            cubeN_tmp = neighborModuleN;
            faceN_tmp = neighborScreenN;

            if (ABS(accelY) > ABS(accelX)) {
                if (accelY > 0) {
                    neighborModuleN = abi_topCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_topFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = neighborModuleN;
                    faceN_tmp = neighborScreenN;
                } else {
                    neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = neighborModuleN;
                    faceN_tmp = neighborScreenN;
                }
            } else {
                if (accelX > 0) {
                    //cubeN = cubeN_tmp;
                    //screenN = faceN_tmp;
                } else {
                    neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = neighborModuleN;
                    faceN_tmp = neighborScreenN;
                    neighborModuleN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
                    neighborScreenN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
                    if (!((neighborModuleN < CUBES_MAX) && (neighborScreenN < FACES_MAX)))
                        return;
                    cubeN_tmp = neighborModuleN;
                    faceN_tmp = neighborScreenN;
                }
            }
        }
        cubeN = cubeN_tmp;
        screenN = faceN_tmp;
    }
}