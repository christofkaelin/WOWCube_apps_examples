#include "cubios_abi.pwn"
#include "results.pwn"

const MAX_CUBE_SIDES = 6;

new topology_TopmostModule = CUBES_MAX;
new topology_TopmostFace = FACES_MAX;

new topology_TopmostModules{FACES_ON_PLANE} = {CUBES_MAX, ...};
new topology_TopmostFaces{FACES_ON_PLANE} = {FACES_MAX, ...};

new topology_FacesAngles[FACES_MAX] = [180, ...];

new topology_FacesSides{FACES_MAX} = {MAX_CUBE_SIDES, ...};

Topology_FindFacesAngles(farCube, farFace, startAngle = 180) {
    new angle;
    new neighborCubeN = farCube;
    new neighborFaceN = farFace;
    new tmp_cubeN = 0;
    new tmp_faceN = 0;
    new condition = 0;
    for (new faceN = 0; faceN < FACES_MAX; ++faceN) {
        angle = startAngle - (90 * faceN);

        if (farCube == abi_cubeN) {
            topology_FacesAngles[farFace] = angle % 360;
            topology_FacesSides{faceN} = faceN + ((farCube != 0) * FACES_MAX);
        }

        for (new count = 0; count < FACES_MAX; ++count) {
            tmp_cubeN = abi_topCubeN(neighborCubeN, neighborFaceN);
            tmp_faceN = abi_topFaceN(neighborCubeN, neighborFaceN);
            angle = (angle += 90) % 360;
            if (tmp_cubeN >= CUBES_MAX) {
                return 0;
            }
            if (tmp_cubeN == abi_cubeN) {
                topology_FacesAngles[tmp_faceN] = angle;
                topology_FacesSides{tmp_faceN} = faceN + ((farCube != 0) * FACES_MAX);
            }
            neighborCubeN = tmp_cubeN;
            neighborFaceN = tmp_faceN;
        }

        neighborCubeN = farCube;
        neighborFaceN = farFace = abi_rightFaceN(neighborCubeN, farFace);
    }
    return 1;
}

Topology_CheckAngles(far_cubeN = 0, far_faceN = 0, isGravitationOn = 0) {
    if (far_cubeN >= CUBES_MAX) {
        return 0;
    }

    new tmp_cubeN = 0;
    new tmp_faceN = 0;
    new neighborCubeN;
    new neighborFaceN;

    if (!Topology_FindFacesAngles(far_cubeN, far_faceN, 90 * isGravitationOn + 180)) {
        return 0;
    }
    
    neighborCubeN = far_cubeN;
    neighborFaceN = far_faceN;
    // Search diagonal cubes relative on the 0 cube 0 face = left cube + face, left cube + face, bottom cube + face, left cube + face
    for (new cube = 0; cube < FACES_ON_PLANE; ++cube) {
        if (cube != 2) {
            tmp_cubeN = abi_leftCubeN(neighborCubeN,neighborFaceN);
            tmp_faceN = abi_leftFaceN(neighborCubeN,neighborFaceN);
            if (tmp_cubeN >= CUBES_MAX) {
                return 0;
            }
            neighborCubeN = tmp_cubeN;
            neighborFaceN = tmp_faceN;
        } else {
            tmp_faceN = abi_bottomFaceN(neighborCubeN,neighborFaceN);
            neighborFaceN = tmp_faceN;
        }
    }

    return Topology_FindFacesAngles(neighborCubeN, neighborFaceN, 180 * isGravitationOn + 180);
}

Topology_FindTopMostModule() {
    topology_TopmostModules = {CUBES_MAX, CUBES_MAX, CUBES_MAX, CUBES_MAX};
    topology_TopmostFaces = {FACES_MAX, FACES_MAX, FACES_MAX, FACES_MAX};
    topology_TopmostModule = CUBES_MAX;
    topology_TopmostFace = FACES_MAX;
    
    getCubeFaceToResults(abi_cubeN, 0, topology_TopmostModule, topology_TopmostFace);
    getCubeFaceToResults(abi_cubeN, 1, topology_TopmostModule, topology_TopmostFace);
    getCubeFaceToResults(abi_cubeN, 2, topology_TopmostModule, topology_TopmostFace);

    if ((topology_TopmostModule < CUBES_MAX) && (topology_TopmostFace < FACES_MAX)) {
        new neighborCube = topology_TopmostModules{0} = topology_TopmostModule;
        new neighborFace = topology_TopmostFaces{0} = topology_TopmostFace;
        for (new faceI = 0; faceI < FACES_MAX; ++faceI) {
            new topCube = abi_topCubeN(neighborCube, neighborFace);
            new topFace = abi_topFaceN(neighborCube, neighborFace);
            if (topCube > CUBES_MAX) {
                break;
            }
            if (topCube < topology_TopmostModule) {
                topology_TopmostModule = topCube;
                topology_TopmostFace = topFace;
            }
            topology_TopmostModules{faceI + 1} = neighborCube = topCube;
            topology_TopmostFaces{faceI + 1} = neighborFace = topFace;
        }
    }

    return Topology_CheckAngles(topology_TopmostModule, topology_TopmostFace, 1);
}