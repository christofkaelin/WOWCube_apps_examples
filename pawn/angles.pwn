new newAngles[FACES_MAX] = [ 0, 0, 0];

CheckAngles() {
    new far_cubeN = 0;
    new tmp_cubeN = 0;
    new tmp_faceN = 0;
    new neighborCubeN;
    new neighborFaceN;
    FindNewAngles(far_cubeN);

    neighborCubeN = 0;
    neighborFaceN = 0;
    //search far far cuben relative on the 0 cube 0 face = left cube + face, left cube + face, bottom cube + face, left cube + face
    //left cube + face
    tmp_cubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    if(!(tmp_cubeN < CUBES_MAX))
        return;
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;
    tmp_cubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    if(!(tmp_cubeN < CUBES_MAX))
        return;
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;
    tmp_cubeN = abi_bottomCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_bottomFaceN(neighborCubeN, neighborFaceN);
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;
    tmp_cubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    tmp_faceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    if(!(tmp_cubeN < CUBES_MAX))
        return;
    neighborCubeN = tmp_cubeN;
    neighborFaceN = tmp_faceN;

    far_cubeN = neighborCubeN;

    FindNewAngles(far_cubeN);
}
FindNewAngles(farCube) {
    new angle;
    new neighborCubeN;
    new neighborFaceN;
    new tmp_cubeN = 0;
    new tmp_faceN = 0;
    for (new faceN = 0; faceN < FACES_MAX; faceN++) {
        neighborCubeN = farCube;
        neighborFaceN = faceN;
        if(farCube == abi_cubeN) {
            newAngles[faceN] = 180;
        }
        angle = 180;
        for (new count = 0; count < FACES_MAX; count++) {
            tmp_cubeN = abi_topCubeN(neighborCubeN, neighborFaceN);
            tmp_faceN = abi_topFaceN(neighborCubeN, neighborFaceN);
            angle += 90;
            if(angle == 360) {
                angle = 0;
            }
            if(!(tmp_cubeN < CUBES_MAX)) {
                break;
            }
            if(tmp_cubeN == abi_cubeN) {
                newAngles[tmp_faceN] = angle;
            }
            neighborCubeN = tmp_cubeN;
            neighborFaceN = tmp_faceN;
        }
    }
}