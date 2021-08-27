#define CMD_SEND_SETTINGS P2P_CMD_BASE_SCRIPT_1 + 1
new settings[2] = { 0, 0 };
new bool:game_running = false;

send_settings() {
    new data[4];

    data[0] = ((CMD_SEND_SETTINGS & 0xFF));
    data[1] = ((game_running & 0xFF) | ((settings[0] & 0xFF) << 8) | ((settings[1] & 0xFF) << 16));

    // send message through UART
    abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(1, NET_BROADCAST_TTL_MAX, data);
    abi_CMD_NET_TX(2, NET_BROADCAST_TTL_MAX, data);
}

menu() {
    CheckAngles();
    for (new screenI = 0; screenI < FACES_MAX; screenI++) {
        abi_CMD_FILL(0, 0, 0);
        switch (newAngles[screenI]) {
            case 180:
                abi_CMD_BITMAP(0, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);

            case 90:
                abi_CMD_BITMAP(2, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);

            case 270:
                abi_CMD_BITMAP(settings[0] + 10, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);

            case 0:
                abi_CMD_BITMAP(settings[1] + 13, 240 / 2, 240 / 2, newAngles[screenI], MIRROR_BLANK);
        }
        abi_CMD_REDRAW(screenI);

        if ((screenI == abi_MTD_GetTapFace()) && (abi_MTD_GetTapsCount() >= 1)) {
            abi_CMD_FILL(0, 0, 0);

            switch (newAngles[screenI]) {
                case 90 :  {
                    printf("INFO - Tapped start\n");
                    game_running = true;
                    send_settings();
                    //abi_CMD_NET_TX(0, NET_BROADCAST_TTL_MAX, game_running);
                }

                case 270 :  {
                    settings[0] = (settings[0] + abi_MTD_GetTapsCount()) % 3;
                    printf("INFO - Changed car, new car: %d\n", settings[0]);
                    send_settings();
                }

                case 0 :  {
                    settings[1] = (settings[1] + abi_MTD_GetTapsCount()) % 3;
                    printf("INFO - Changed map, new map: %d\n", settings[1]);
                    send_settings();
                }
            }
        }
    }
}
