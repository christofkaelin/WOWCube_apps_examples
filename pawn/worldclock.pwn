#include "cubios_abi.pwn"
#include "trbl.pwn"

#include "math.pwn"
#include "run.pwn"
#include "angles.pwn"
#include <time>

#define DISPLAY_WIDTH   240
#define DISPLAY_HEIGHT  240

new gmt;
new city[4];

getHour() {
    return (gettime() % 86400) / 3600;
}

getMin() {
    return (gettime() % 3600) / 60;
}

getSec() {
    return gettime() % 60;
}

setCity(gmt) {
    switch (gmt) {
        case 0:
            strformat(city, sizeof(city), true, "Berlin");
        case 1:
            strformat(city, sizeof(city), true, "Bucharest");
        case 2:
            strformat(city, sizeof(city), true, "Moscow");
        case 3:
            strformat(city, sizeof(city), true, "Dubai");
        case 4:
            strformat(city, sizeof(city), true, "Karachi");
        case 5:
            strformat(city, sizeof(city), true, "Dhaka");
        case 6:
            strformat(city, sizeof(city), true, "Bangkok");
        case 7:
            strformat(city, sizeof(city), true, "Hong Kong");
        case 8:
            strformat(city, sizeof(city), true, "Seoul");
        case 9:
            strformat(city, sizeof(city), true, "Sydney");
        case 10:
            strformat(city, sizeof(city), true, "Kolonia");
        case 11:
            strformat(city, sizeof(city), true, "Auckland");
        case 12:
            strformat(city, sizeof(city), true, "Samoa");
        case 13:
            strformat(city, sizeof(city), true, "Honolulu");
        case 14:
            strformat(city, sizeof(city), true, "Anchorage");
        case 15:
            strformat(city, sizeof(city), true, "Vancouver");
        case 16:
            strformat(city, sizeof(city), true, "Denver");
        case 17:
            strformat(city, sizeof(city), true, "Mexico City");
        case 18:
            strformat(city, sizeof(city), true, "New York");
        case 19:
            strformat(city, sizeof(city), true, "Halifax");
        case 20:
            strformat(city, sizeof(city), true, "Sao Paulo");
        case 21:
            strformat(city, sizeof(city), true, "Grytviken");
        case 22:
            strformat(city, sizeof(city), true, "Santa Cruz");
        case 23:
            strformat(city, sizeof(city), true, "London");
    }
}

ONTICK() {
    new screenI;
    //recalculate angle based on trbl
    CheckAngles();
    for (screenI = 0; screenI < FACES_MAX; screenI++) {
        //clear screen before output
        abi_CMD_FILL(0, 0, 0);

        //set time zone
        gmt = ((abi_cubeN + 1) * FACES_MAX) - (FACES_MAX - (screenI + 1)) - 1;

        //draw watch face
        abi_CMD_BITMAP(0, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);

        //draw city
        setCity(gmt);
        switch (newAngles[screenI]) {
            case 180:
                abi_CMD_TEXT(city, 0, DISPLAY_WIDTH / 2, (DISPLAY_HEIGHT / 3) * 2, 6, newAngles[screenI], TEXT_ALIGN_CENTER, 0, 0, 0);
            case 90:
                abi_CMD_TEXT(city, 0, (DISPLAY_WIDTH / 3) * 2, DISPLAY_HEIGHT / 2, 6, newAngles[screenI], TEXT_ALIGN_CENTER, 0, 0, 0);
            case 270:
                abi_CMD_TEXT(city, 0, DISPLAY_WIDTH / 3, DISPLAY_HEIGHT / 2, 6, newAngles[screenI], TEXT_ALIGN_CENTER, 0, 0, 0);
            case 0:
                abi_CMD_TEXT(city, 0, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 3, 6, newAngles[screenI], TEXT_ALIGN_CENTER, 0, 0, 0);
        }

        // draw hours
        abi_CMD_BITMAP(1, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + ((getHour() + gmt) * 30), MIRROR_BLANK);

        // draw minutes
        abi_CMD_BITMAP(2, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + (getMin() * 6), MIRROR_BLANK);

        // draw seconds
        abi_CMD_BITMAP(3, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI] + (getSec() * 6), MIRROR_BLANK);

        //draw center
        abi_CMD_BITMAP(4, DISPLAY_WIDTH / 2, DISPLAY_HEIGHT / 2, newAngles[screenI], MIRROR_BLANK);

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
