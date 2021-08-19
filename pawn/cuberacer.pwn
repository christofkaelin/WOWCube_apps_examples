#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

new roads[8][3][2];

new car_current_angles = 180;
new car_position_x = 180;
new car_position_y = 180;
new car_position_module = 0;
new car_position_screen = 0;

new SHIFT_POS = 5;
new SHIFT_ANGLE = 10; 
new SCORE_GAIN_BASE = 10;

new car_current_module = 0;
new car_current_screem = 0;
new car_neighbour_module = CUBES_MAX;
new car_neighbour_screen = FACES_MAX;

new delay = 0;

ONTICK() {
  // Tapping the screen rotates the displayed element by 90 degrees clockwise.
  // Inspiration: https://wiki.wowcube.com/wiki/API#Examples_2
  for (new screenI = 0; screenI < FACES_MAX; screenI++) {
    if (screenI == (abi_MTD_GetTapFace())) {    
      abi_CMD_FILL(0, 0, 0);
      roads[abi_cubeN][screenI][1] = roads[abi_cubeN][screenI][1] + (90 * abi_MTD_GetTapsCount());   
      abi_CMD_BITMAP(roads[abi_cubeN][screenI][0], DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + roads[abi_cubeN][screenI][1], MIRROR_BLANK);
      abi_CMD_REDRAW(screenI);
    }  
  }

  //Increases base speed (SHIFT_POS) after defined interval (currently 45s)
  //TODO: Implement score system and elevate gain for each increase in movement speed
  if (delay % 45000 == 0) {
    SHIFT_POS = SHIFT_POS + 2;
  }

  //exit program on shake
  if (0 == abi_cubeN) {
        abi_checkShake();
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
  roads[0][1][0] = random(3);
  roads[0][2][0] = random(3);
  roads[1][0][0] = random(3);
  roads[1][1][0] = random(3);
  roads[1][2][0] = random(3);
  roads[2][0][0] = random(3);
  roads[2][1][0] = random(3);
  roads[2][2][0] = random(3);
  roads[3][0][0] = random(3);
  roads[3][1][0] = random(3);
  roads[3][2][0] = random(3);
  roads[4][0][0] = random(3);
  roads[4][1][0] = random(3);
  roads[4][2][0] = random(3);
  roads[5][0][0] = random(3);
  roads[5][1][0] = random(3);
  roads[5][2][0] = random(3);
  roads[6][0][0] = random(3);
  roads[6][1][0] = random(3);
  roads[6][2][0] = random(3);
  roads[7][0][0] = random(3);
  roads[7][1][0] = random(3);
  roads[7][2][0] = random(3);

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
