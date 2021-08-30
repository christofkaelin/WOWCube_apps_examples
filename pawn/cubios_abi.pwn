#if defined CUBIOS_EMULATOR
#include <core>
#include <args>
#include <string>
#include <fixed>
#include <datagram>
#else // HW
native sendpacket(const packet[], const size);
#include "console.inc"
#include "string.inc"
#include "fixed.inc"
#endif

// ABI global constants
#if defined CUBIOS_EMULATOR
#define GUI_ADDR "127.0.0.1:9999"
#define PAWN_PORT_BASE  10000
#endif

#define SENSITIVITY_MENU_CHANGE_SCRIPT  6

#define TEXT_ALIGN_CENTER 0
#define TEXT_ALIGN_TOP_CENTER 1
#define TEXT_ALIGN_BOTTOM_CENTER 2
#define TEXT_ALIGN_LEFT_CORNER 3
#define TEXT_ALIGN_LEFT_TOP_CORNER 4
#define TEXT_ALIGN_LEFT_BOTTOM_CORNER 5
#define TEXT_ALIGN_RIGHT_CORNER 6
#define TEXT_ALIGN_RIGHT_TOP_CORNER 7
#define TEXT_ALIGN_RIGHT_BOTTOM_CORNER 8

// from AMX, {N} - N is number of bits
#define CMD_GUI_BASE    		0 /* TO DISPLAY */
#define CMD_REDRAW      		CMD_GUI_BASE+1 /* CMD_REDRAW{8},faceN{8} - copy framebuffer contents to the face specified */
#define CMD_FILL        		CMD_GUI_BASE+2 /* CMD_FILL{8},R{8},G{8},B{8} - to framebuffer, RGB565 */
#define CMD_BITMAP      		CMD_GUI_BASE+3 /* CMD_BITMAP{8},resID{16},X{16},Y{16},angle{16},mirror{8} - to framebuffer */
#define CMD_LINE				CMD_GUI_BASE+4 /* CMD_LINE{8},x1{16},y1{16},x2{16},y2{16},R{8},G{8},B{8} - to framebuffer, RGB565 */
#define CMD_RECT				CMD_GUI_BASE+5 /* CMD_RECT{8},x1{16},y1{16},x2{16},y2{16},R{8},G{8},B{8} - to framebuffer, RGB565 */
#define CMD_SLEEP				CMD_GUI_BASE+6 /* power off*/
#define CMD_DRAW_OVERLAY		CMD_GUI_BASE+7 /* show/off overlay */
#define CMD_TRIGGER_BLUETOOTH	CMD_GUI_BASE+8 /* enable/disable bluetooth */
#define CMD_G2D_BEGIN_BITMAP	CMD_GUI_BASE+9 /* start to add G2D layers to blend them into bitmap buffer */
#define CMD_G2D_ADD_SPRITE		CMD_GUI_BASE+10 /* add bitmap layer */
#define CMD_G2D_ADD_RECTANGLE	CMD_GUI_BASE+11 /* add rectangle layer */
#define CMD_G2D_END				CMD_GUI_BASE+12 /* stop adding G2D layers and start blendind process */
#define CMD_G2D_BEGIN_DISPLAY	CMD_GUI_BASE+14 /* start to add G2D layers to blend them into display framebuffer */
#define CMD_TEXT            CMD_GUI_BASE+13 /* CMD_TEXT{8},fontResID{16},x{16},y{16},scale{16},angle{16},align{8},r{8},g{8},b{8},useG2D{8},text{8...} - to framebuffer, RGB565 */
#define CMD_PLAYSND  					 CMD_GUI_BASE+15 /* play sound {sound_id, volume (0..100)} */
#define CMD_TRIGGER_NIGHTLAMP  CMD_GUI_BASE+16 /* switch to night lamp mode */ 
#define CMD_G2D_DYNAMIC_TEXTURE		CMD_GUI_BASE+17 /* draw dynamic effect */
#define CMD_STATE_SAVE		        CMD_GUI_BASE+18 /* save state of current game */
#define CMD_STATE_SYNC            CMD_GUI_BASE+19 /* Sync game save from master module to other modules */
#define CMD_EXIT                (CMD_GUI_BASE + 20) /* exit to platform menu */

#define CMD_NET_BASE				50 /* TO UARTs 0-2 */
#define CMD_NET_TX					CMD_NET_BASE+1 /* CMD_NET_TX{8},line_tx{8},TTL{8},RESERVED{8},<4 CELLs of arbitrary data here>{128} */
#define CMD_SCHEDULER_BASE	60 /* TO SCRIPTS SCHEDULER */
#define CMD_CHANGE_SCRIPT		CMD_SCHEDULER_BASE+1 /* CMD_CHANGE_SCRIPT{8},scriptID{8} - change script before next tick */
// to AMX
#define CMD_PAWN_BASE   100
#define CMD_TICK        CMD_PAWN_BASE+1 /* CMD_TICK{8} */
#define CMD_GEO         CMD_PAWN_BASE+2 /* CMD_GEO{8},n_records{8},CID[0]{8},screen[0]{8},...,CID[N]{8},screen[N]{8} */
#define CMD_NET_RX      CMD_PAWN_BASE+3 /* CMD_NET_RX{8},line_rx{8},neighbor_line_tx{8},TTL{8},<4 CELLs of arbitrary data here>{128} */
#define CMD_MTD					CMD_PAWN_BASE+4 /* CMD_MTD{8},
																					 accel_X_pos{8},accel_X_neg{8},accel_Y_pos{8},accel_Y_neg{8},accel_Z_pos{8},accel_Z_neg{8},
																					 gyro_X_pos{8},gyro_X_neg{8},gyro_Y_pos{8},gyro_Y_neg{8},gyro_Z_pos{8},gyro_Z_neg{8} */
#define CMD_STATE_LOAD  CMD_PAWN_BASE+5
#define CMD_TIME        (CMD_PAWN_BASE+6) /* CMD_TIME{8}, time{32} */
#define CMD_PHYSICS_TICK (CMD_PAWN_BASE+7) /* CMD_PHYSICS_TICK{8} */


// Pawn2Pawn common commands
#define P2P_CMD_BASE_RESERVED      0  // 000-009 former menu script commands range
#define P2P_CMD_BASE_SCRIPT_1     10
#define P2P_CMD_BASE_SCRIPT_2     20
#define P2P_CMD_BASE_SCRIPT_3     30
#define P2P_CMD_BASE_PONG         40
#define P2P_CMD_BASE_TRBL        220  // 220-229 trbl library commands range
#define P2P_CMD_BASE_RESULTS     230  // 230-239 results library commands range - common for some games, such as Pipes and Butterfly
#define P2P_CMD_BASE_COMMON      240  // 240-255 are commands range common for all the scripts
#define P2P_CMD_CHANGE_SCRIPT    P2P_CMD_BASE_COMMON+1  // should be sent as broadcast to all modules to change script, format: P2P_CMD_CHANGE_SCRIPT{8},script_number{8}

#define CUBES_MAX 8
#define FACES_MAX 3
#define FACES_ON_PLANE 4

#define NET_BROADCAST_TTL_MAX 2
#define NET_LINE_RX_NA 0xFF // when TX packet "born" in Pawn

#define NET_SEND_WITH_TX_POOL 0
#define NET_SEND_WITHOUT_TX_POOL 1

#define TRBL_TOP 0
#define TRBL_RIGHT 1
#define TRBL_BOTTOM 2
#define TRBL_LEFT 3

#define MTD_ACCEL_X_POS 0
#define MTD_ACCEL_X_NEG 1
#define MTD_ACCEL_Y_POS 2
#define MTD_ACCEL_Y_NEG 3
#define MTD_ACCEL_Z_POS 4
#define MTD_ACCEL_Z_NEG 5

#define MTD_TAP_DIRECTION_NONE 0
#define MTD_TAP_DIRECTION_X 1
#define MTD_TAP_DIRECTION_Y 2
#define MTD_TAP_DIRECTION_Z 3

#define MIRROR_BLANK 0
#define MIRROR_X 1
#define MIRROR_Y 2
#define MIRROR_XY 3

#define G2D_ROTATION_0   0
#define G2D_ROTATION_90  1
#define G2D_ROTATION_180 2
#define G2D_ROTATION_270 3

#define G2D_DYNAMIC_TEXTURE_MOSAIC 1

#define GAME_SAVE_SIZE  64

// ABI global variables
new abi_cubeN = 0;
new abi_TRBL[CUBES_MAX][FACES_MAX];
new abi_TRBL_backup[FACES_MAX]; // Backup for OnRotate
new abi_MTD_Accel[6] = [0,0,0,0,0,0]; // x_pos,x_neg,y_pos,y_neg,z_pos,z_neg
new abi_MTD_Gyro[6] = [0,0,0,0,0,0]; // x_pos,x_neg,y_pos,y_neg,z_pos,z_neg
new abi_MTD_TapFace = 0;
new abi_MTD_TapOpposite = 0;
new abi_MTD_TapsCount = 0;
new abi_MTD_ShakesCount = 0;
new abi_Time = 0;

// ABI helpers
#if defined CUBIOS_EMULATOR
abi_LogRcvPkt(const pkt[], size, const src[])
{
  printf("[%s] rcv pkt[%d]: ", src, size);
  for(new abi_i=0; abi_i<size; abi_i++) printf(" %02x", abi_ByteN(pkt, abi_i));
  printf("\n");
}

abi_LogSndPkt(const pkt[], size, const cubeN)
{
  printf("[127.0.0.1:%d] snd pkt[%d]: ", PAWN_PORT_BASE+cubeN, size);
  for(new abi_i=0; abi_i<size; abi_i++) printf(" %02x", abi_ByteN(pkt, abi_i));
  printf("\n");
}
#else
forward abi_GetCubeN();
forward abi_SetCubeN(const cubeN);

public abi_GetCubeN()
{
  return abi_cubeN;
}

public abi_SetCubeN(const cubeN)
{
  abi_cubeN = cubeN;
}
#endif

abi_ByteN(const arr[], const n)
{
  return ((arr[n/4] >> (8*(n%4))) & 0xFF);
}

abi_TRBL_Deserialize(const pkt[])
{
  new nr = abi_ByteN(pkt, 1); // number of records passed in the pkt

  for(new r=0; r<nr; r++)
  {
    new rb = 2+r*6; // record base offset
    new cubeN=abi_ByteN(pkt, rb+0);
    new faceN=abi_ByteN(pkt, rb+1);
    abi_TRBL[cubeN][faceN]=(abi_ByteN(pkt, rb+2) << 24) | (abi_ByteN(pkt, rb+3) << 16) | (abi_ByteN(pkt, rb+4) << 8) | abi_ByteN(pkt, rb+5);
  }
}

// FIXME: use this helpers in all abi_CMD methods
#define abi_ToByte(%0) ((%0) & 0xff)
#define abi_ToWord(%0) ((%0) & 0xffff)

#define abi_WordFirst(%0) abi_ToByte(%0)
#define abi_WordSecond(%0) (((%0) & 0xff00) >> 8)

#define abi_PackIn32(%0,%1) ((%0) << (((%1) % 4) * 8))
#define abi_PackByteIn32(%0,%1) abi_PackIn32(abi_ToByte(%0), %1)
#define abi_PackWordIn32(%0,%1) abi_PackIn32(abi_ToWord(%0), %1)

//the change of the neighbor (not initial) at 0 cube will be considered as a turn
bool:abi_check_rotate()
{
  new faceN;
  new bool:check=false;
  for(faceN=0;faceN<FACES_MAX;faceN++)
  {
    if (abi_topCubeN(abi_cubeN, faceN)<CUBES_MAX)
    {
      //if ((abi_TRBL_backup[faceN] >= CUBES_MAX) ||  (abi_TRBL_backup[faceN] != abi_topCubeN(abi_cubeN, faceN)))
      if (abi_TRBL_backup[faceN] != abi_topCubeN(abi_cubeN, faceN))
      {
        if (abi_TRBL_backup[faceN] < CUBES_MAX)
          check=true;
        abi_TRBL_backup[faceN] = abi_topCubeN(abi_cubeN, faceN);
      }
    }
  }
  return(check);
}

abi_topCubeN(const _cubeN, const _faceN)
{
  return ((abi_TRBL[_cubeN][_faceN] >> 24) & 0xFF);
}

abi_topFaceN(const _cubeN, const _faceN)
{
  return ((abi_TRBL[_cubeN][_faceN] >> 16) & 0xFF);
}

abi_rightCubeN(const _cubeN, const _faceN)
{
  return _cubeN; // always same cube
}

abi_rightFaceN(const _cubeN, const _faceN)
{
  return ((_faceN == 0) ? 2 : ((_faceN == 1) ? 0 : 1));
}

abi_bottomCubeN(const _cubeN, const _faceN)
{
  return _cubeN; // always same cube
}

abi_bottomFaceN(const _cubeN, const _faceN)
{
  return ((_faceN == 0) ? 1 : ((_faceN == 1) ? 2 : 0));
}

abi_leftCubeN(const _cubeN, const _faceN)
{
  return ((abi_TRBL[_cubeN][_faceN] >> 8) & 0xFF);
}

abi_leftFaceN(const _cubeN, const _faceN)
{
  return (abi_TRBL[_cubeN][_faceN] & 0xFF);
}

abi_Time_Deserialize(const pkt[]) {
  abi_Time = abi_ByteN(pkt, 1) | (abi_ByteN(pkt, 2) << 8) | ((abi_ByteN(pkt, 3) << 16)) | ((abi_ByteN(pkt, 4) << 24));
}

abi_GetTime() {
  return abi_Time;
}

abi_checkShake() {
  if (abi_MTD_GetShakesCount() >= SENSITIVITY_MENU_CHANGE_SCRIPT) {
      abi_exit();
  }
}

abi_MTD_Deserialize(const pkt[])
{
  for(new i=0; i<6; i++)
  {
    abi_MTD_Accel[i] = abi_ByteN(pkt, i+1);
    abi_MTD_Gyro[i] = abi_ByteN(pkt, 6+i+1);
  }
  abi_MTD_TapFace = abi_ByteN(pkt, 13) & 0x03;
  abi_MTD_TapOpposite = abi_ByteN(pkt, 13) >> 2;
  abi_MTD_TapsCount = abi_ByteN(pkt, 14);
  abi_MTD_ShakesCount = abi_ByteN(pkt, 15);
}

abi_MTD_GetFaceAccelX(const faceN)
{
  new a=0;

  switch(faceN)
  {
    case 0:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Z_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_Z_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Z_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Z_NEG];
    }

    case 1:
    {
      if(abi_MTD_Accel[MTD_ACCEL_X_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_X_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_X_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_X_NEG];
    }

    case 2:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Y_POS] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Y_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Y_NEG] > 0) a = abi_MTD_Accel[MTD_ACCEL_Y_NEG];
    }
  }

  return a;
}

abi_MTD_GetFaceAccelY(const faceN)
{
  new a=0;

  switch(faceN)
  {
    case 0:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Y_POS] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Y_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Y_NEG] > 0) a = abi_MTD_Accel[MTD_ACCEL_Y_NEG];
    }

    case 1:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Z_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_Z_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Z_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Z_NEG];
    }

    case 2:
    {
      if(abi_MTD_Accel[MTD_ACCEL_X_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_X_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_X_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_X_NEG];
    }
  }

  return a;
}

abi_MTD_GetFaceAccelZ(const faceN)
{
  new a=0;

  switch(faceN)
  {
    case 0:
    {
      if(abi_MTD_Accel[MTD_ACCEL_X_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_X_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_X_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_X_NEG];
    }

    case 1:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Y_POS] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Y_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Y_NEG] > 0) a = abi_MTD_Accel[MTD_ACCEL_Y_NEG];
    }

    case 2:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Z_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_Z_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Z_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Z_NEG];
    }
  }

  return a;
}

abi_MTD_GetFaceGyroX(const faceN)
{
  new a=0;

  switch(faceN)
  {
    case 0:
    {
      if(abi_MTD_Gyro[MTD_ACCEL_Z_POS] > 0) a = abi_MTD_Gyro[MTD_ACCEL_Z_POS];
      else if(abi_MTD_Gyro[MTD_ACCEL_Z_NEG] > 0) a = -abi_MTD_Gyro[MTD_ACCEL_Z_NEG];
    }

    case 1:
    {
      if(abi_MTD_Gyro[MTD_ACCEL_X_POS] > 0) a = abi_MTD_Gyro[MTD_ACCEL_X_POS];
      else if(abi_MTD_Gyro[MTD_ACCEL_X_NEG] > 0) a = -abi_MTD_Gyro[MTD_ACCEL_X_NEG];
    }

    case 2:
    {
      if(abi_MTD_Gyro[MTD_ACCEL_Y_POS] > 0) a = -abi_MTD_Gyro[MTD_ACCEL_Y_POS];
      else if(abi_MTD_Gyro[MTD_ACCEL_Y_NEG] > 0) a = abi_MTD_Gyro[MTD_ACCEL_Y_NEG];
    }
  }

  return a;
}

abi_MTD_GetFaceGyroY(const faceN)
{
  new a=0;

  switch(faceN)
  {
    case 0:
    {
      if(abi_MTD_Gyro[MTD_ACCEL_Y_POS] > 0) a = -abi_MTD_Gyro[MTD_ACCEL_Y_POS];
      else if(abi_MTD_Gyro[MTD_ACCEL_Y_NEG] > 0) a = abi_MTD_Gyro[MTD_ACCEL_Y_NEG];
    }

    case 1:
    {
      if(abi_MTD_Gyro[MTD_ACCEL_Z_POS] > 0) a = abi_MTD_Gyro[MTD_ACCEL_Z_POS];
      else if(abi_MTD_Gyro[MTD_ACCEL_Z_NEG] > 0) a = -abi_MTD_Gyro[MTD_ACCEL_Z_NEG];
    }

    case 2:
    {
      if(abi_MTD_Gyro[MTD_ACCEL_X_POS] > 0) a = abi_MTD_Gyro[MTD_ACCEL_X_POS];
      else if(abi_MTD_Gyro[MTD_ACCEL_X_NEG] > 0) a = -abi_MTD_Gyro[MTD_ACCEL_X_NEG];
    }
  }

  return a;
}

abi_MTD_GetFaceGyroZ(const faceN)
{
  new a=0;

  switch(faceN)
  {
    case 0:
    {
      if(abi_MTD_Accel[MTD_ACCEL_X_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_X_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_X_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_X_NEG];
    }

    case 1:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Y_POS] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Y_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Y_NEG] > 0) a = abi_MTD_Accel[MTD_ACCEL_Y_NEG];
    }

    case 2:
    {
      if(abi_MTD_Accel[MTD_ACCEL_Z_POS] > 0) a = abi_MTD_Accel[MTD_ACCEL_Z_POS];
      else if(abi_MTD_Accel[MTD_ACCEL_Z_NEG] > 0) a = -abi_MTD_Accel[MTD_ACCEL_Z_NEG];
    }
  }

  return a;
}

abi_MTD_GetTapFace()
{
  return abi_MTD_TapFace;
}

abi_MTD_IsTapOpposite()
{
  return abi_MTD_TapOpposite;
}

abi_MTD_GetTapsCount()
{
  return abi_MTD_TapsCount;
}

abi_MTD_GetShakesCount()
{
  return abi_MTD_ShakesCount;
}

/*
    Commands to C-code host or Emulator
*/
abi_CMD_REDRAW(const faceN)
{
  new pkt[1] = 0;
  pkt[0] = ((faceN & 0xFF) << 8) | (CMD_REDRAW & 0xFF);
  //abi_LogSndPkt(pkt, 1*4, abi_cubeN);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_exit() {
    new pkt[1] = 0;
    pkt[0] = CMD_EXIT & 0xFF;

#if defined CUBIOS_EMULATOR
    sendpacket(pkt, 1, GUI_ADDR);
#else
    sendpacket(pkt, 1);
#endif
}

abi_trigger_debug_info()
{
  new pkt[1] = 0;
  pkt[0] = CMD_DRAW_OVERLAY & 0xFF;
  //abi_LogSndPkt(pkt, 1*4, abi_cubeN);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_trigger_bluetooth() {
  new pkt[1] = 0;
  pkt[0] = CMD_TRIGGER_BLUETOOTH & 0xFF;
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_FILL(const R, const G, const B)
{
  new pkt[1] = 0;
  pkt[0] = ((B & 0x1F) << 24) | ((G & 0x3F) << 16) | ((R & 0x1F) << 8) | (CMD_FILL & 0xFF); // RGB565, Rmax=31, Gmax=63, Bmax=31
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_FILL_2(const rgb) /* rgb is a 24-bit number (3 bytes). The most significant byte is unused, then goes red, then green, then blue. */
{
  new pkt[1] = 0;
  /* Converting  to RGB565. Here blue should be the most significant 5 bits, then 6 bits for green, then 5 bits for red. */
  pkt[0] = ((rgb & 0x1F) << 24) | ((rgb & 0x3F00) << 8) | ((rgb & 0x1F0000) >> 8) | (CMD_FILL & 0xFF);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_TEXT(const text[], const fontResID, const x, const y, const scale, const angle, const align, const r, const g, const b, useG2D=false, text_cell_size = sizeof(text)) {
  // to use system font: fontResID = -1
  new pkt[4 + 16] = 0; // max text length is 63 letters + null-char (zero-terminated string)
  if (text_cell_size > 16)
    text_cell_size = 16;

  /*
    pkt | 0 - 31 bits | little-endian

    pkt1 | CMD_TEXT{8} fontResID{16} x{first 8} |
    pkt2 | x{last 8} y{16} scale{first 8} |
    pkt3 | scale{last 8} angle{16} align{8} |
    pkt4 | r{8} g{8} b{8} _{8}, |
    pkt5 | text{8...}
    ...
  */

  pkt[0] = abi_ToByte(CMD_TEXT) | abi_PackWordIn32(fontResID, 1) | abi_PackIn32(abi_WordFirst(x), 3);
  pkt[1] = abi_WordSecond(x) | abi_PackWordIn32(y, 1) | abi_PackIn32(abi_WordFirst(scale), 3);
  pkt[2] = abi_WordSecond(scale) | abi_PackWordIn32(angle, 1) | abi_PackByteIn32(align, 3);
  pkt[3] = abi_ToByte(r) | abi_PackByteIn32(g, 1) | abi_PackByteIn32(b, 2) |  abi_PackByteIn32(useG2D, 3);

  new j = 4;
  new sizeof_cell = 4;
  new mmm = 8*(sizeof_cell-1);
  for (new i = 0; i < text_cell_size; i++) {
      for (new c = 0; c < sizeof_cell; c++) {
          new tmp = (text[i] >> (mmm - 8*c)) & 0xff;
          // if (tmp == '\0')
          //     break;
          //printf("i: %d, tmp: %c (0x%x)\n", i, tmp, tmp);

          pkt[j] |= abi_PackByteIn32(tmp, c);
      }
      j++;
  }

  #if defined CUBIOS_EMULATOR
    sendpacket(pkt, j, GUI_ADDR);
  #else
    sendpacket(pkt, j);
  #endif
}

abi_CMD_TEXT_ITOA(const num, const fontResID, const x, const y, const scale, const angle, const align, const r, const g, const b, useG2D=false) {
    new string[3];
    valstr(string, num, true);
    abi_CMD_TEXT(string, fontResID, x, y, scale, angle, align, r, g, b, .useG2D = useG2D);
}

abi_CMD_BITMAP(const resID, const x, const y, const angle, const mirror, const bool:g2d = false)
{
  new pkt[3] = 0;
  pkt[0] = ((x & 0xFF) << 24) | ((resID & 0xFFFF) << 8) | (CMD_BITMAP & 0xFF);
  pkt[1] = ((angle & 0xFF) << 24) | ((y & 0xFFFF) << 8) | ((x & 0xFF00) >> 8);
  pkt[2] = ((g2d & 0x01) << 16) | ((mirror & 0xFF) << 8) | ((angle & 0xFF00) >> 8);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 3, GUI_ADDR);
#else
  sendpacket(pkt, 3);
#endif
}

abi_CMD_PLAYSND(const id, const volume)
{
  new pkt[1] = 0;
  pkt[0] = ((volume & 0xFF) << 16) |((id & 0xFF) << 8) | (CMD_PLAYSND & 0xFF);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_LINE(const x1, const y1, const x2, const y2, const R, const G, const B, const thickness = 1)
{
  new pkt[4] = 0;
  pkt[0] = ((y1 & 0xFF) << 24) | ((x1 & 0xFFFF) << 8) | (CMD_LINE & 0xFF);
  pkt[1] = ((y2 & 0xFF) << 24) | ((x2 & 0xFFFF) << 8) | ((y1 & 0xFF00) >> 8);
  pkt[2] = ((B & 0x1F) << 24) | ((G & 0x3F) << 16) | ((R & 0x1F) << 8) | ((y2 & 0xFF00) >> 8);
  pkt[3] = thickness;
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 4, GUI_ADDR);
#else
  sendpacket(pkt, 4);
#endif
}

abi_CMD_RECT(const x1, const y1, const x2, const y2, const R, const G, const B)
{
  new pkt[3] = 0;
  pkt[0] = ((y1 & 0xFF) << 24) | ((x1 & 0xFFFF) << 8) | (CMD_RECT & 0xFF);
  pkt[1] = ((y2 & 0xFF) << 24) | ((x2 & 0xFFFF) << 8) | ((y1 & 0xFF00) >> 8);
  pkt[2] = ((B & 0x1F) << 24) | ((G & 0x3F) << 16) | ((R & 0x1F) << 8) | ((y2 & 0xFF00) >> 8);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 3, GUI_ADDR);
#else
  sendpacket(pkt, 3);
#endif
}

abi_CMD_NET_TX(const line_tx, const TTL, const data[], const with_pool = NET_SEND_WITH_TX_POOL)
{
  new pkt[5] = 0;
  pkt[0] = (((with_pool & 0xFF) << 24) | ((TTL & 0xFF) << 16) | ((line_tx & 0xFF) << 8) | (CMD_NET_TX & 0xFF)); // NOTE: (0xFF << 24) - 4th MSB RESERVED for future use
  for(new i=1; i<5; i++) pkt[i] = data[i-1];
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 5, GUI_ADDR);
#else
  sendpacket(pkt, 5);
#endif
}

bool:abi_CMD_SAVE_STATE(const data[], size = sizeof(data))
{
  if (size > GAME_SAVE_SIZE)
    return(false);

  new pkt[GAME_SAVE_SIZE + 1] = 0;
  // <<2 = *4 need to convert pawn cells to bytes
  pkt[0] = ((size << 2) << 8) | (CMD_STATE_SAVE & 0xFF);
  for(new i=0; i<size; i++) pkt[i+1] = data[i];
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, size + 1, GUI_ADDR);
#else
  sendpacket(pkt, size + 1);
#endif
  return(true);
}

abi_CMD_LOAD_STATE()
{
  new pkt[1] = 0;
  pkt[0] = CMD_STATE_LOAD & 0xFF;
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_CHANGE_SCRIPT(const scriptID)
{
  new pkt[1] = 0;
  pkt[0] = ((scriptID & 0xFF) << 8) | (CMD_CHANGE_SCRIPT & 0xFF);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_SLEEP()
{
  new pkt[1] = 0;
  pkt[0] = CMD_SLEEP & 0xFF;
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_G2D_BEGIN_BITMAP(const resID, const width, const height, const bool:replace)
{
  new pkt[2] = 0;
  pkt[0] = abi_ToByte(CMD_G2D_BEGIN_BITMAP) | abi_PackWordIn32(resID, 1) | abi_PackIn32(abi_WordFirst(width), 3);
  pkt[1] = abi_WordSecond(width) | abi_PackWordIn32(height, 1) | abi_PackByteIn32(replace & 0x01, 3);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 2, GUI_ADDR);
#else
  sendpacket(pkt, 2);
#endif
}

abi_CMD_G2D_BEGIN_DISPLAY(const display, const bool:replace)
{
  new pkt[1] = 0;
  pkt[0] = abi_ToByte(CMD_G2D_BEGIN_DISPLAY) | abi_PackByteIn32(display, 1) | abi_PackByteIn32(replace, 2);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_G2D_ADD_SPRITE(const resID, const bool:g2d, const x, const y, const alpha, const color, const rotation, const mirror)
{
    new pkt[4] = 0;
    pkt[0] = abi_ToByte(CMD_G2D_ADD_SPRITE) | abi_PackWordIn32(resID, 1) | abi_PackByteIn32(g2d, 3);
    pkt[1] = abi_ToWord(x) | abi_PackWordIn32(y, 2);
    pkt[2] = color;
    pkt[3] = abi_ToByte(alpha) | abi_PackWordIn32(rotation, 1) | abi_PackByteIn32(mirror, 3);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 4, GUI_ADDR);
#else
  sendpacket(pkt, 4);
#endif
}

abi_CMD_G2D_ADD_RECTANGLE(const x, const y, const width, const height, const color)
{
    new pkt[4] = 0;
    pkt[0] = abi_ToByte(CMD_G2D_ADD_RECTANGLE) | abi_PackWordIn32(x, 1) | abi_PackByteIn32(abi_WordFirst(y), 3);
    pkt[1] = abi_WordSecond(y) | abi_PackWordIn32(width, 1) | abi_PackByteIn32(abi_WordFirst(height), 3);
    pkt[2] = abi_WordSecond(height) | ((color & 0x00FFFFFF) << 8);
    pkt[3] = ((color & 0xFF000000) >> 24);

#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 4, GUI_ADDR);
#else
  sendpacket(pkt, 4);
#endif
}

abi_CMD_G2D_END()
{
    new pkt[1] = 0;
    pkt[0] = abi_ToByte(CMD_G2D_END);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}
//trigger to nightlamp
abi_trigger_nightlamp(const c_mode) {
  new pkt[1];
  pkt[0] = abi_PackByteIn32( CMD_TRIGGER_NIGHTLAMP, 0) | abi_PackByteIn32(c_mode, 1);
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, 1, GUI_ADDR);
#else
  sendpacket(pkt, 1);
#endif
}

abi_CMD_DYNAMIC_TEXTURE(const effectId, const time, const args[], const argsCount, const bool:g2d = false)
{
  new pkt[argsCount + 2] = 0;
  pkt[0] = abi_ToByte(CMD_G2D_DYNAMIC_TEXTURE) |  abi_PackByteIn32(effectId, 1) |  abi_PackByteIn32(g2d, 2)
  pkt[1] = time;
  for(new i = 0; i < argsCount; i++)
    pkt[i + 2] = args[i];
#if defined CUBIOS_EMULATOR
  sendpacket(pkt, argsCount + 2, GUI_ADDR);
#else
  sendpacket(pkt, argsCount + 2);
#endif
}

// Process binary commands from GUI
#if defined CUBIOS_EMULATOR
@receivepacket(const packet[], size, const source[])
{
  run(packet, size, source);
}

// This is for run CLI Pawn until key press. Will not be used in MCU version.
@keypressed(key)
{
  exit;
}
#endif
