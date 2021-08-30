forward run(const pkt[], size, const src[]); // public Pawn function seen from C
#include "cubios_abi.pwn"
#include "results.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

#define RUBIK_CMD_ASSIGN_NUM_REQ P2P_CMD_BASE_SCRIPT_1+1
#define RUBIK_CMD_ASSIGN_NUM_CFM P2P_CMD_BASE_SCRIPT_1+2

#define RUBIK_FACE_TOP 0
#define RUBIK_FACE_LEFT 1
#define RUBIK_FACE_RIGHT 2

#define RUBIK_LINE_BOTTOM 0
#define RUBIK_LINE_RIGHT 1
#define RUBIK_LINE_LEFT 2

#define RUBIK_COLOR_WHITE  0xFFFFFF
#define RUBIK_COLOR_GREEN  0x00FF00
#define RUBIK_COLOR_RED    0xFF0000
#define RUBIK_COLOR_ORANGE 0xFFA500
#define RUBIK_COLOR_YELLOW 0xFFFF00
#define RUBIK_COLOR_BLUE   0x0000FF
#define RUBIK_COLOR_GREY   0x808080

/* Cube ID to be obtained from the platform */
new platformCubeId = 0;

/* In-game Cube ID */
new rubikCubeId;

/* Map cubelet face ID to in-game face ID */
new faceMap [3] = [ 0 /* "top" face */, 1 /* "left" face */, 2 /* "right" face */];

/* Map cubelet line ID to in-game line ID */
new lineMap [3] = [0 /* "bottom" line */, 1 /* "right" line */, 2 /* "left" line */];

/* Cubelet face map is as follows:     | "top" face         | "left" face       | "right" face       | */
new const c_faceColorArray [9] [3] = [ [  RUBIK_COLOR_WHITE , RUBIK_COLOR_GREEN , RUBIK_COLOR_RED    ], 
                                       [  RUBIK_COLOR_WHITE , RUBIK_COLOR_ORANGE, RUBIK_COLOR_GREEN  ],
                                       [  RUBIK_COLOR_YELLOW, RUBIK_COLOR_GREEN , RUBIK_COLOR_ORANGE ],
                                       [  RUBIK_COLOR_YELLOW, RUBIK_COLOR_RED   , RUBIK_COLOR_GREEN  ],
                                       [  RUBIK_COLOR_WHITE , RUBIK_COLOR_RED   , RUBIK_COLOR_BLUE   ],
                                       [  RUBIK_COLOR_WHITE , RUBIK_COLOR_BLUE  , RUBIK_COLOR_ORANGE ],
                                       [  RUBIK_COLOR_YELLOW, RUBIK_COLOR_ORANGE, RUBIK_COLOR_BLUE   ],
                                       [  RUBIK_COLOR_YELLOW, RUBIK_COLOR_BLUE  , RUBIK_COLOR_RED    ],
                                       [  RUBIK_COLOR_GREY  , RUBIK_COLOR_GREY  , RUBIK_COLOR_GREY]  ];

/* 
 * Assign number confirmation map.
 * The least three bits are where confirmations should be received from:
 * The least significant bit is for line with id=0 (given by platform), the next one is for line with id=1 and the third one is for line with id=2.
 * On receiving confirmation appropriate bit should be reset.
 */
new assignCfmMap;
new assignReqSendAttempts;

platform_TwoWayLineToFaceOpp(const face_or_line)
{
  return (4 - face_or_line) % 3;
}

platform_TwoWayLineToFaceLeft(const face_or_line)
{
  return (3 - face_or_line) % 3;
}

rubik_initCfmMap()
{
  switch(rubikCubeId)
  {
    case 0:
    {
      assignCfmMap = (1 << lineMap[RUBIK_LINE_LEFT]) | (1 << lineMap[RUBIK_LINE_RIGHT]); /* Left and right line */
    }
    case 1, 5:
    {
      assignCfmMap = 1 << lineMap[RUBIK_LINE_BOTTOM]; /* Bottom line */
    }
    case 2:
    {
      assignCfmMap = 1 << lineMap[RUBIK_LINE_LEFT]; /* Left line */
    }
    case 4, 6:
    {
      assignCfmMap = 1 << lineMap[RUBIK_LINE_RIGHT]; /* Right line */
    }
    default:
    {
      assignCfmMap = 0;
    }
  }

  if(assignCfmMap != 0)
  {
    assignReqSendAttempts = 5;
  }
}

rubik_mapLinesAndFaces(const receivedFromLine)
{
  /* Map lines and faces */
  switch(rubikCubeId)
  {
    case 0:
    {
      /* Face map for Id=0 is the default one. Set interface map according to it. */
      for(new currentFace = 0; currentFace < FACES_MAX; currentFace++)
      {
        lineMap[currentFace] = platform_TwoWayLineToFaceOpp(faceMap[currentFace]);
      }
    }
    
    case 1, 3:
    {
      /* Map "right" line and "left" face. */
      lineMap[RUBIK_LINE_RIGHT] = receivedFromLine;
      faceMap[RUBIK_FACE_LEFT] = platform_TwoWayLineToFaceOpp(lineMap[RUBIK_LINE_RIGHT]);

      /* Map "top" face and "bottom" line */
      faceMap[RUBIK_FACE_TOP] = platform_TwoWayLineToFaceLeft(lineMap[RUBIK_LINE_RIGHT]);
      lineMap[RUBIK_LINE_BOTTOM] = platform_TwoWayLineToFaceOpp(faceMap[RUBIK_FACE_TOP]);

      /* Map "right" face and "left" line */
      faceMap[RUBIK_FACE_RIGHT] = platform_TwoWayLineToFaceLeft(lineMap[RUBIK_LINE_BOTTOM]);
      lineMap[RUBIK_LINE_LEFT] = platform_TwoWayLineToFaceOpp(faceMap[RUBIK_FACE_RIGHT]);
    }

    case 2, 6:
    {
      /* Map "bottom" line and "top" face */
      lineMap[RUBIK_LINE_BOTTOM] = receivedFromLine;
      faceMap[RUBIK_FACE_TOP] = platform_TwoWayLineToFaceOpp(lineMap[RUBIK_LINE_BOTTOM]);

      /* Map "right" face and "left" line */
      faceMap[RUBIK_FACE_RIGHT] = platform_TwoWayLineToFaceLeft(lineMap[RUBIK_LINE_BOTTOM]);
      lineMap[RUBIK_LINE_LEFT] = platform_TwoWayLineToFaceOpp(faceMap[RUBIK_FACE_RIGHT]);

      /* Map "left" face and "right" line */
      faceMap[RUBIK_FACE_LEFT] = platform_TwoWayLineToFaceLeft(lineMap[RUBIK_LINE_LEFT]);
      lineMap[RUBIK_LINE_RIGHT] = platform_TwoWayLineToFaceOpp(faceMap[RUBIK_FACE_LEFT]);
    }

    case 4, 5, 7:
    {
      /* Map "left" line and "right" face */
      lineMap[RUBIK_LINE_LEFT] = receivedFromLine;
      faceMap[RUBIK_FACE_RIGHT] = platform_TwoWayLineToFaceOpp(lineMap[RUBIK_LINE_LEFT]);

      /* Map "left" face and "right" line */
      faceMap[RUBIK_FACE_LEFT] = platform_TwoWayLineToFaceLeft(lineMap[RUBIK_LINE_LEFT]);
      lineMap[RUBIK_LINE_RIGHT] = platform_TwoWayLineToFaceOpp(faceMap[RUBIK_FACE_LEFT]);

      /* Map "top" face and "bottom" line */
      faceMap[RUBIK_FACE_TOP] = platform_TwoWayLineToFaceLeft(lineMap[RUBIK_LINE_RIGHT]);
      lineMap[RUBIK_LINE_BOTTOM] = platform_TwoWayLineToFaceOpp(faceMap[RUBIK_FACE_TOP]);
    }
  }
}

rubik_assignNumberToNeihbours()
{
  new pktToSend[4] = [0, 0, 0, 0];

  if((assignCfmMap & 0x7 ) == 0)
  {
    return;
  }

  if(assignReqSendAttempts == 0)
  {
    return;
  }
  assignReqSendAttempts--;

  /* Assign number to neighbor cube if required */
  switch(rubikCubeId)
  {
    case 0:
    {
      /* Assign number 2 to the "left" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_LEFT])) != 0)
      {
        pktToSend[0] = (1 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_LEFT], 0, pktToSend);
      }

      /* Assign number 5 to the "right" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_RIGHT])) != 0)
      {
        pktToSend[0] = (4 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_RIGHT], 0, pktToSend);
      }
    }
    
    case 1:
    {
      /* Assign number 3 to the "bottom" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_BOTTOM])) != 0)
      {
        pktToSend[0] = (2 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_BOTTOM], 0, pktToSend);
      }
    }

    case 2:
    {
      /* Assign number 4 to the "left" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_LEFT])) != 0)
      {
        pktToSend[0] = (3 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_LEFT], 0, pktToSend);
      }
    }

    case 4:
    {
      /* Assign number 6 to the "right" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_RIGHT])) != 0)
      {
        pktToSend[0] = (5 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_RIGHT], 0, pktToSend);
      }
    }

    case 5:
    {
      /* Assign number 7 to the "bottom" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_BOTTOM])) != 0)
      {
        pktToSend[0] = (6 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_BOTTOM], 0, pktToSend);
      }
    }

    case 6:
    {
      /* Assign number 8 to the "right" cubelet if needed */
      if((assignCfmMap & (1 << lineMap[RUBIK_LINE_RIGHT])) != 0)
      {
        pktToSend[0] = (7 << 8) | RUBIK_CMD_ASSIGN_NUM_REQ;
        abi_CMD_NET_TX(lineMap[RUBIK_LINE_RIGHT], 0, pktToSend);
      }
    }
  }
}

rubik_paintFaces()
{
  new currentFace = 0;
  new lineToCheck = 0;

  /* Set face colors */
  for(currentFace = 0; currentFace < FACES_MAX; currentFace++)
  {
    lineToCheck = platform_TwoWayLineToFaceOpp(faceMap[currentFace]);
    abi_CMD_FILL_2(c_faceColorArray[rubikCubeId][currentFace]);
    abi_CMD_REDRAW(faceMap[currentFace]);
  }
}

ON_PHYSICS_TICK() {

}

RENDER() {
  
}

ONTICK()
{
  if(platformCubeId == 0)
  {
    abi_checkShake();
  }
  
  rubik_paintFaces();
  if(rubikCubeId < 8)
  {
    rubik_assignNumberToNeihbours();
  }
}

ON_LOAD_GAME_DATA()
{
}

ON_INIT()
{
  platformCubeId = abi_cubeN;
  assignReqSendAttempts = 0;
  if( platformCubeId == 0 )
  {
    rubikCubeId = 0;
    rubik_mapLinesAndFaces(0);
  }
  else
  {
    rubikCubeId = 8;
  }
  rubik_initCfmMap();
}

ON_CMD_NET_RX(const pkt[])
{
  new receivedFromLine = abi_ByteN(pkt, 1);
  new pktToSend[4] = [0, 0, 0, 0];

  switch(abi_ByteN(pkt,4))
  {
    case RUBIK_CMD_ASSIGN_NUM_REQ:
    {
      if(rubikCubeId == 8)
      {
        rubikCubeId = abi_ByteN(pkt,5);
        rubik_mapLinesAndFaces(receivedFromLine);
        rubik_initCfmMap();
      }

      pktToSend[0] = RUBIK_CMD_ASSIGN_NUM_CFM;
      abi_CMD_NET_TX(receivedFromLine, 0, pktToSend);
    }

    case RUBIK_CMD_ASSIGN_NUM_CFM:
    {
      if(assignCfmMap != 0)
      {
        assignCfmMap &= ~(1 << receivedFromLine);
        assignCfmMap |= (1 << (3 + receivedFromLine));
      }
    }
  }
}

ON_CHECK_ROTATE()
{

}

#ifdef CUBIOS_EMULATOR
main() {
  new opt{100}
  argindex(0, opt);
  abi_cubeN = strval(opt);
  printf("Cube %d logic. Listening on port: %d\n", abi_cubeN, (PAWN_PORT_BASE+abi_cubeN));
  listenport(PAWN_PORT_BASE+abi_cubeN);
}
#endif
