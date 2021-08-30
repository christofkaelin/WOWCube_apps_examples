#define TOTAL 0
//30
#define NEIGHBOR_MAX_ON_FACES 4

#define TYPE_LOGO 0
#define TYPE_MOVES 1
#define TYPE_SCORES 2
#define TYPE_TIME 3

#define RESULT_LAST_ID 15

#define NUMBER0 4
//34
#define SCORE_INITIAL 10000
#define SCORE_BY_MOVE 10

#define LEVEL_COMPLETED 0xFF

#define REQUEST_RESULTS P2P_CMD_BASE_RESULTS + 1
#define RESPOSE_TO_REQUEST P2P_CMD_BASE_RESULTS + 2
#define SET_LEVEL P2P_CMD_BASE_RESULTS + 3
#define SHOW_RESULTS P2P_CMD_BASE_RESULTS + 4

new time=0;
new score=0;
new moves=0;
new is_completed;
new total_result;

new count_results=NEIGHBOR_MAX_ON_FACES;
new faceN_results=FACES_MAX;

new result_cubeN;
new result_faceN;


Draw_Results(const _type)
{
  new base;
  new count;
  
  if (_type == TYPE_LOGO)
  {
    abi_CMD_BITMAP(TOTAL+_type, 120, 120, 180, MIRROR_BLANK);
  }
  else if (_type == TYPE_MOVES)
  {
    base=10;
    for (count=0; count<10;count++)
    {
      if (moves/base == 0)
        break;
      else
        base*=10;
    }
    base=moves;
    for(new i=0;i<=count;i++)
    {
      abi_CMD_BITMAP(NUMBER0+base%10,  120, 120  + (22+2)/2*count - (22+2)*i, 90, MIRROR_BLANK);
      base/=10;
    }
    abi_CMD_BITMAP(TOTAL+_type, 70, 120, 90, MIRROR_BLANK);
  }
  else if (_type == TYPE_SCORES)
  {
    score=SCORE_INITIAL - time/10 - moves * SCORE_BY_MOVE;
    base=10;
    for (count=0; count<10;count++)
    {
      if (score/base == 0)
        break;
      else
        base*=10;
    }
    base=score;
    for(new i=0;i<=count;i++)
    {
      abi_CMD_BITMAP(NUMBER0+base%10, 120 + (22+2)/2*count - (22+2)*i, 120, 0, MIRROR_BLANK);
      base/=10;
    }
    abi_CMD_BITMAP(TOTAL+_type, 120, 170, 0, MIRROR_BLANK);
  }
  else if (_type == TYPE_TIME)
  {
    new timer=time/10;
    //set time to hh:mm:ss format
    timer = timer/3600 * 10000 + (timer - timer / 3600 * 3600) / 60 * 100 + timer%60;

    base=10;
    for (count=0; count<10;count++)
    {
      if (timer/base == 0)
        break;
      else
        base*=10;
    }
    base=timer;
    count += count/2; 
    for(new i=0;i<=count;i++)
    {
      if (((i+1)-(i+1)/3*3 == 0) && (i!=0))
      {
        abi_CMD_BITMAP(NUMBER0+10, 120, 120 - (22+2)/2*count + (22+2)*i, 270, MIRROR_BLANK);
      }
      else
      {
        abi_CMD_BITMAP(NUMBER0+base%10, 120, 120 - (22+2)/2*count + (22+2)*i, 270, MIRROR_BLANK);
        base/=10;
      }
    }
    abi_CMD_BITMAP(TOTAL+_type, 170, 120, 270, MIRROR_BLANK);
  }
  
}

abi_show_results(const thiscommand, const toCubeN, const toFaceN, const level)
{
  new data[4];
  new neighborCubeN = toCubeN;
  new neighborFaceN = toFaceN;
  new neighborleftCubeN = toCubeN;
  new neighborleftFaceN = toFaceN;
  new counter;
  for (counter=0;counter<FACES_ON_PLANE; counter++)
  {
    data[0]= (((thiscommand   & 0xFF) <<  0) |
              ((neighborCubeN & 0xFF) <<  8) |
              ((neighborFaceN & 0xFF) << 16) |
              ((level         & 0xFF) << 24));
    data[1]=time;
    data[2]=moves;
    data[3]=counter;
    if (neighborCubeN==abi_cubeN)
    {
      count_results=counter;
      faceN_results=neighborFaceN;
    }
    else
    {
      abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data);
      abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data);
      abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data);
    }
    neighborleftCubeN = abi_leftCubeN(neighborCubeN, neighborFaceN);
    neighborleftFaceN = abi_leftFaceN(neighborCubeN, neighborFaceN);
    neighborCubeN = neighborleftCubeN;
    neighborFaceN = neighborleftFaceN;
  }
}
abi_send_level(const thiscommand, const level)
{
  new data[4];

  data[0]= ((thiscommand & 0xFF) <<  0);
  data[1]=level;
  data[2]=0;
  data[3]=0;
  abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data);
  abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data);
  abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data);
}

abi_respose_to_request_results(const thiscommand, const fromCube, const completed)
{
  new data[4];

  data[0]= (((thiscommand & 0xFF) <<  0) |
            ((fromCube    & 0xFF) <<  8) |
            ((completed   & 0xFF) << 16));

  abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=0
  abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=1
  abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data); // broadcast to UART=2
}

abi_set_result_from_RX(const cubeN, const value, &total)
{
  total &= ~(1 << cubeN);
  total |=  ((value & 0x1) << cubeN);
}
abi_clearing_total(&total)
{
  if (total==LEVEL_COMPLETED)
    return;
  new cubeN;
  for(cubeN=0; cubeN<CUBES_MAX; cubeN++)
    if (!(abi_topCubeN(cubeN,0)<CUBES_MAX))
      total = 0;
  /*
  if (abi_leftCubeN(thisCubeN,thisFaceN)<CUBES_MAX) || 
  {
    for(cubeN=0;cubeN<CUBES_MAX;cubeN++)
      for(faceN=0;faceN<FACES_MAX;faceN++)
      {
        //clear top record
        if (abi_topCubeN(cubeN,faceN)==thisCubeN)
          abi_set_result_from_RX(cubeN,0,total);
      }
  }
  if (!(abi_topCubeN(thisCubeN,thisFaceN)<CUBES_MAX))
  {
    total &= ~(1 << thisCubeN);
    total |=  ((0 & 0x1) << thisCubeN);
  }*/
}
getCubeFaceToResults(const thisCubeN, const thisFaceN, &cubeN, &faceN)
{
  new accelX = abi_MTD_GetFaceAccelX(thisFaceN);
  new accelY = abi_MTD_GetFaceAccelY(thisFaceN);
  new accelZ = abi_MTD_GetFaceAccelZ(thisFaceN);
  new neighborCubeN=CUBES_MAX;
  new neighborFaceN=FACES_MAX;
  new cubeN_tmp = thisCubeN;
  new faceN_tmp = thisFaceN;

  if (( ABS(accelZ) > ABS(accelX) ) && ( ABS(accelZ) > ABS(accelY) ))
  {
    if (accelZ < 0)
    {
      if ( ABS(accelY) > ABS(accelX) )
      {
        if (accelY < 0)
        {
          //cubeN = cubeN_tmp;
          //faceN = faceN_tmp;
        }
        else
        {
          neighborCubeN = abi_topCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_topFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = abi_topCubeN(neighborCubeN, neighborFaceN);
          faceN_tmp = abi_topFaceN(neighborCubeN, neighborFaceN);
          if (!((cubeN_tmp < CUBES_MAX) && (faceN_tmp < FACES_MAX)))
            return;
        }
      }
      else
      {
        if (accelX < 0)
        {
          neighborCubeN = abi_topCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_topFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = neighborCubeN;
          faceN_tmp = neighborFaceN;
        }
        else
        {
          neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = neighborCubeN;
          faceN_tmp = neighborFaceN;
        }
      }
    }
    else
    {
      //far far cubeN and faceNa
      neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
      neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
      if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
        return;
      cubeN_tmp = neighborCubeN;
      faceN_tmp = neighborFaceN;

      neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
      neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
      if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
        return;
      neighborFaceN = abi_bottomFaceN(neighborCubeN, neighborFaceN);

      cubeN_tmp = neighborCubeN;
      faceN_tmp = neighborFaceN;

      neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
      neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
      if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
        return;

      neighborFaceN = abi_bottomFaceN(neighborCubeN, neighborFaceN);

      cubeN_tmp = neighborCubeN;
      faceN_tmp = neighborFaceN;
      
      if (ABS(accelY) > ABS(accelX))
      {
        if (accelY > 0)
        {
          neighborCubeN = abi_topCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_topFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = neighborCubeN;
          faceN_tmp = neighborFaceN;
        }
        else
        {
          neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = neighborCubeN;
          faceN_tmp = neighborFaceN;
        }
      }
      else
      {
        if (accelX > 0)
        {
          //cubeN = cubeN_tmp;
          //faceN = faceN_tmp;
        }
        else
        {
          neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = neighborCubeN;
          faceN_tmp = neighborFaceN;
          neighborCubeN = abi_leftCubeN(cubeN_tmp, faceN_tmp);
          neighborFaceN = abi_leftFaceN(cubeN_tmp, faceN_tmp);
          if (!((neighborCubeN < CUBES_MAX) && (neighborFaceN < FACES_MAX)))
            return;
          cubeN_tmp = neighborCubeN;
          faceN_tmp = neighborFaceN;
        }
      }
    }
    cubeN = cubeN_tmp;
    faceN = faceN_tmp;
  }
}
