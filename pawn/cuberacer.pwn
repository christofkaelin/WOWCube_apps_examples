#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

new roads[8][3][2];

ONTICK() {
  // TODO: Tap should turn road by 90 degrees clockwise.
  // Inspiration: https://wiki.wowcube.com/wiki/API#Examples_2
  for (new screenI = 0; screenI < FACES_MAX; screenI++) {
    if (screenI == (abi_MTD_GetTapFace())) {
      abi_CMD_FILL(0, 0, 0);
      roads[abi_cubeN][screenI][1] = roads[abi_cubeN][screenI][1] + (90 * abi_MTD_GetTapsCount());
      abi_CMD_BITMAP(roads[abi_cubeN][screenI][0], DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + roads[abi_cubeN][screenI][1], MIRROR_BLANK);
    }
    abi_CMD_REDRAW(screenI);
  }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {
  // First field will always be a straight road
  roads[0][0][0] = 0;
  roads[0][0][1] = 90;
  // TODO: set to random(8), once all elements are implemented.
  // We might want to set probabilities for special road types (boost, warp, guardian, k.o.).
  roads[0][1][0] = random(2);
  roads[0][2][0] = random(2);
  roads[1][0][0] = random(2);
  roads[1][1][0] = random(2);
  roads[1][2][0] = random(2);
  roads[2][0][0] = random(2);
  roads[2][1][0] = random(2);
  roads[2][2][0] = random(2);
  roads[3][0][0] = random(2);
  roads[3][1][0] = random(2);
  roads[3][2][0] = random(2);
  roads[4][0][0] = random(2);
  roads[4][1][0] = random(2);
  roads[4][2][0] = random(2);
  roads[5][0][0] = random(2);
  roads[5][1][0] = random(2);
  roads[5][2][0] = random(2);
  roads[6][0][0] = random(2);
  roads[6][1][0] = random(2);
  roads[6][2][0] = random(2);
  roads[7][0][0] = random(2);
  roads[7][1][0] = random(2);
  roads[7][2][0] = random(2);

  // Randomly generate rotation of the roads
  roads[0][1][1] = random(3) * 90;
  roads[0][2][1] = random(3) * 90;
  roads[1][0][1] = random(3) * 90;
  roads[1][1][1] = random(3) * 90;
  roads[1][2][1] = random(3) * 90;
  roads[2][0][1] = random(3) * 90;
  roads[2][1][1] = random(3) * 90;
  roads[2][2][1] = random(3) * 90;
  roads[3][0][1] = random(3) * 90;
  roads[3][1][1] = random(3) * 90;
  roads[3][2][1] = random(3) * 90;
  roads[4][0][1] = random(3) * 90;
  roads[4][1][1] = random(3) * 90;
  roads[4][2][1] = random(3) * 90;
  roads[5][0][1] = random(3) * 90;
  roads[5][1][1] = random(3) * 90;
  roads[5][2][1] = random(3) * 90;
  roads[6][0][1] = random(3) * 90;
  roads[6][1][1] = random(3) * 90;
  roads[6][2][1] = random(3) * 90;
  roads[7][0][1] = random(3) * 90;
  roads[7][1][1] = random(3) * 90;
  roads[7][2][1] = random(3) * 90;
  for (new screenI = 0; screenI < FACES_MAX; screenI++) {
      abi_CMD_FILL(0, 0, 0);
      abi_CMD_BITMAP(roads[abi_cubeN][screenI][0], DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + roads[abi_cubeN][screenI][1], MIRROR_BLANK);
      abi_CMD_REDRAW(screenI);
  }
}
ON_CHECK_ROTATE() {}
