#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"
#include <time>

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

new gmt = 0;

getHour() {
    return (gettime() % 86400) / 3600;
}

getMin() {    
    return (gettime() % 3600) / 60;
}

getSec() {
    return gettime() % 60;
}

ONTICK() {
    new screenI;
    //recalculate angle based on trbl
    CheckAngles();
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        abi_CMD_FILL(0, 0, 0);
        
        //set time zone
        gmt = (abi_cubeN + 1) * (screenI + 1);
        
        //draw watch face
        abi_CMD_BITMAP(gmt, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);
        
        // draw hours
        abi_CMD_BITMAP(25, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + ((getHour() + gmt) * 30), MIRROR_BLANK);
        
        // draw minutes
        abi_CMD_BITMAP(26, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + (getMin() * 6), MIRROR_BLANK);
        
        // draw seconds
        abi_CMD_BITMAP(27, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + (getSec() * 6), MIRROR_BLANK);
        
        //draw center
        abi_CMD_BITMAP(28, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);

        //push buffer at screen
        abi_CMD_REDRAW(screenI);
    }
    if (0 == abi_cubeN) {
        abi_checkShake();
    }
}
ON_PHYSICS_TICK() {}
RENDER() {}
ON_CMD_NET_RX(const pkt[]) {}
ON_LOAD_GAME_DATA() {}
ON_INIT() {}
ON_CHECK_ROTATE() {}
