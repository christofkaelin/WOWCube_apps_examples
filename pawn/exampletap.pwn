#include "cubios_abi.pwn"
#include "trbl.pwn"
#include "math.pwn"
#include "run.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

#define TEXT_SIZE       8

// Implementation of: https://wiki.wowcube.com/wiki/API#Examples_2
new delay = 0;
new color = 0x000000; 
ONTICK() {
  if (!color) {
    switch (abi_MTD_GetTapsCount()) {
    case 1:
      color = 0xff0000;
    case 2:
      color = 0x00ff00;
    case 3:
      color = 0x0000ff;
    }
  }
  if (delay % 25 == 0) {
    for (new i = 0; i < FACES_MAX; i++) {
      if (i == (abi_MTD_GetTapFace())) {
        abi_CMD_FILL_2(color);
        color = 0x000000;
        switch (abi_MTD_GetTapFace()) {
        case 1:
          abi_CMD_TEXT(['1', '\0'], -1, 120, 120, 14, 0, 0xff, 0xff, 0xff);
        case 2:
          abi_CMD_TEXT(['2', '\0'], -1, 120, 120, 14, 0, 0xff, 0xff, 0xff);
        case 3:
          abi_CMD_TEXT(['3', '\0'], -1, 120, 120, 14, 0, 0xff, 0xff, 0xff);
        }
      } else {
        abi_CMD_FILL(0, 0, 0);
      }
      abi_CMD_REDRAW(i);
    }
  }
  delay++;
   if (abi_cubeN == 0) {
       abi_checkShake();
   }
}

ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}