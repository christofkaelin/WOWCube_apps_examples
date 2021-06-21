#define TICKS_TO_CLEAR 3
#define P2P_CMD_SEND_TRBL        P2P_CMD_BASE_TRBL+2  // should be sent as broadcast to all modules to get all trbl
#define TRBL_RECORD_INITIAL 0xFFFFFFFF


#define TRBL_ROTATION_LEFT            1       // the neighbor on the left had currently top cube
#define TRBL_ROTATION_RIGHT           2
#define TRBL_ROTATION_UNINDENTIFIED   0    // unidentified or double rotation

#define TRBL_TICK_TO_CHECK_ROTATE 3

#define TRBL_COUNT_ROTATIONS_MAX      0xFF

new ticks_for_trbl_clear[8] = [0, 0, 0, 0, 0, 0, 0, 0];

new trbl_count_rotations = 0;

new TRBL_rotation_face = FACES_MAX; //the screen around which turned from above
new TRBL_rotation_side = TRBL_ROTATION_UNINDENTIFIED;
new TRBL_rotation_left_cube[FACES_MAX] = [ CUBES_MAX, CUBES_MAX, CUBES_MAX];
new TRBL_rotation_right_cube[FACES_MAX] = [ CUBES_MAX, CUBES_MAX, CUBES_MAX];
new TRBL_rotation_top_cube[FACES_MAX] = [ CUBES_MAX, CUBES_MAX, CUBES_MAX];

//left, if at the top there was a cube that was on the left of the left neighbor
//right, if at the top of the cube that was at the top of the right-top neighbor
//other - unindentified

trbl_clearing()
{
  new cubeN;
  new faceN;
  new thisCubeN;
  new thisFaceN;
  for(thisCubeN=0;thisCubeN<CUBES_MAX;thisCubeN++)
  {
    if (thisCubeN==abi_cubeN)
    {
      ticks_for_trbl_clear[thisCubeN]=0;
      continue;
    }
    if (ticks_for_trbl_clear[thisCubeN]>TICKS_TO_CLEAR)
    {
      abi_TRBL[thisCubeN][0] = TRBL_RECORD_INITIAL;
      abi_TRBL[thisCubeN][1] = TRBL_RECORD_INITIAL;
      abi_TRBL[thisCubeN][2] = TRBL_RECORD_INITIAL;
      ticks_for_trbl_clear[thisCubeN]=0;
    }
    for(thisFaceN=0;thisFaceN<FACES_MAX;thisFaceN++)
    {
      if (!(abi_leftCubeN(thisCubeN,thisFaceN)<CUBES_MAX))
      {
        for(cubeN=0;cubeN<CUBES_MAX;cubeN++)
          for(faceN=0;faceN<FACES_MAX;faceN++)
          {
            //clear top record
            if ((abi_topCubeN(cubeN,faceN)==thisCubeN) && (abi_topFaceN(cubeN,faceN)==thisFaceN))
            {
              abi_TRBL[cubeN][faceN] = abi_TRBL[cubeN][faceN] | 0xFFFF << 16;
              break;
            }
          }
      }
      if (!(abi_topCubeN(thisCubeN,thisFaceN)<CUBES_MAX))
      {
        for(cubeN=0;cubeN<CUBES_MAX;cubeN++)
          for(faceN=0;faceN<FACES_MAX;faceN++)
          {
            //clear top record
            if ((abi_leftCubeN(cubeN,faceN)==thisCubeN) && (abi_leftFaceN(cubeN,faceN)==thisFaceN))
            {
              abi_TRBL[cubeN][faceN] = abi_TRBL[cubeN][faceN] | 0xFFFF <<  0;
              break;
            }
          }
      }
    }
  }
}
trbl_on_tick()
{
  for(new cubeN=0;cubeN<CUBES_MAX;cubeN++)
    ticks_for_trbl_clear[cubeN]++;
  trbl_send(abi_cubeN);
  trbl_clearing();
}
trbl_send(const ThisCubeN)
{
  new data[4];
  new thisFaceN;
  new thiscommand = P2P_CMD_SEND_TRBL;
  data[0]= (((thiscommand & 0xFF)           <<  0) |
            ((ThisCubeN    & 0xFF)          <<  8) |
            ((trbl_count_rotations & 0xFF)  << 16));
  for(thisFaceN=0;thisFaceN<FACES_MAX;thisFaceN++)
    data[thisFaceN+1]=abi_TRBL[ThisCubeN][thisFaceN];

  abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
  abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
  abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}
trbl_init()
{
  for(new cubeN=0;cubeN<CUBES_MAX;cubeN++)
    for(new faceN=0;faceN<FACES_MAX;faceN++)
      abi_TRBL[cubeN][faceN] = TRBL_RECORD_INITIAL;
}

get_rotation_side()
{
  new neighbor_top   = CUBES_MAX;
  for( new faceN=0; faceN<FACES_MAX; faceN++ )
  {
    neighbor_top = get_top_cube(faceN);
    if ((TRBL_rotation_top_cube[faceN] != neighbor_top) && (neighbor_top < CUBES_MAX))
    {
      
      if (neighbor_top == TRBL_rotation_left_cube[faceN])
      {
        TRBL_rotation_face = faceN; 
        TRBL_rotation_side = TRBL_ROTATION_LEFT;
      }
      else if (neighbor_top == TRBL_rotation_right_cube[faceN]) 
      {
        TRBL_rotation_face = faceN; 
        TRBL_rotation_side = TRBL_ROTATION_RIGHT; 
      }
      else
      {
        TRBL_rotation_face = FACES_MAX; 
        TRBL_rotation_side = TRBL_ROTATION_UNINDENTIFIED; 
      }
    }
    TRBL_rotation_left_cube[faceN]  = CUBES_MAX;
    TRBL_rotation_right_cube[faceN] = CUBES_MAX;
    TRBL_rotation_top_cube[faceN]   = CUBES_MAX;
  }
}
get_top_cube(const c_faceN)
{
  new neighbor_cube = abi_topCubeN(abi_cubeN, c_faceN);
  if (neighbor_cube < CUBES_MAX)
    return ( neighbor_cube);
  return( CUBES_MAX );
}
get_left_cube(const c_faceN)
{
  new neighbor_cube = abi_leftCubeN(abi_cubeN, c_faceN);
  new neighbor_face = abi_leftFaceN(abi_cubeN, c_faceN);
  if (neighbor_cube < CUBES_MAX)
  {
    neighbor_cube = abi_leftCubeN(neighbor_cube, neighbor_face);
    if (neighbor_cube < CUBES_MAX)
      return( neighbor_cube);
  }
  return( CUBES_MAX);
}
get_right_cube(const c_faceN)
{
  new neighbor_cube = abi_cubeN;//abi_leftCubeN(abi_cubeN, c_faceN);
  new neighbor_face = abi_rightFaceN(abi_cubeN, c_faceN);

  neighbor_cube = abi_topCubeN( abi_cubeN, neighbor_face);
  neighbor_face = abi_topFaceN( abi_cubeN, neighbor_face);

  if (neighbor_cube < CUBES_MAX)
  {
    neighbor_cube = abi_topCubeN(neighbor_cube, neighbor_face);
    if (neighbor_cube < CUBES_MAX)
      return( neighbor_cube);
  }
  return( CUBES_MAX);
}
update_trbl_record_for_rotation()
{
  new neighbor_top = CUBES_MAX;
  new neighbor_left = CUBES_MAX;
  new neighbor_right = CUBES_MAX;    
  for( new faceN=0; faceN<FACES_MAX; faceN++)
  {
    
    neighbor_top = get_top_cube(faceN);
    neighbor_left = get_left_cube(faceN);
    neighbor_right = get_right_cube(faceN);
    
    if ((neighbor_top < CUBES_MAX) && (neighbor_top != TRBL_rotation_top_cube[faceN]) && (TRBL_rotation_top_cube[faceN] >= CUBES_MAX))
      TRBL_rotation_top_cube[faceN] = neighbor_top;
    if ((neighbor_left < CUBES_MAX) && (neighbor_left != TRBL_rotation_left_cube[faceN]) && (TRBL_rotation_left_cube[faceN] >= CUBES_MAX))
      TRBL_rotation_left_cube[faceN] = neighbor_left;
    if ((neighbor_right < CUBES_MAX) && (neighbor_right != TRBL_rotation_right_cube[faceN]) && (TRBL_rotation_right_cube[faceN] >= CUBES_MAX))
      TRBL_rotation_right_cube[faceN] = neighbor_right;
  }
}

trbl_clear_after_rotation()
{
  for(new cubeN=0;cubeN<CUBES_MAX;cubeN++)
    for(new faceN=0;faceN<FACES_MAX;faceN++)
      if (abi_cubeN != cubeN)
        abi_TRBL[cubeN][faceN] = TRBL_RECORD_INITIAL;
}