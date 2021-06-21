#define TICKS_BEFORE_LOGIC_STARTED    20 // some time period at start during which HWIDs translated to CIDs, because all modules started by default with CID==0


new tick = 0;
new bool:initialization = false;
new bool:is_rotation = false;

public run(const pkt[], size, const src[]) // public Pawn function seen from C
{
  if (initialization==false)
  {
    tick++;
    if (abi_ByteN(pkt, 0) == CMD_MTD)
    {
      abi_MTD_Deserialize(pkt);
      _seed += (ABS(abi_MTD_GetFaceGyroX(0)) + ABS(abi_MTD_GetFaceGyroY(0)) + ABS(abi_MTD_GetFaceGyroZ(0)));
    }

    if (tick<TICKS_BEFORE_LOGIC_STARTED)
      return;
    initialization=true;
    
    //time=0;
    //moves=0;
    trbl_init();
    ON_INIT();
    for(new faceN=0;faceN<FACES_MAX;faceN++)
      abi_TRBL_backup[faceN] = abi_topCubeN(abi_cubeN, faceN);
  }
  switch(abi_ByteN(pkt, 0))
  {
    case CMD_PHYSICS_TICK:
    {
      ON_PHYSICS_TICK();
    }
    case CMD_TICK:
    {
      trbl_on_tick();
      if ((is_rotation == true) || (abi_check_rotate()))//(abi_check_rotate()==true)
      {
        is_rotation=false;
        trbl_count_rotations = ((trbl_count_rotations == TRBL_COUNT_ROTATIONS_MAX) ? 0 : trbl_count_rotations + 1);
        get_rotation_side();
        ON_CHECK_ROTATE();
        trbl_clear_after_rotation();
      }
      update_trbl_record_for_rotation();

      ONTICK();  // game logic
      RENDER();  // render frame

      //tick = (tick+1)%0xFFFFFFFF;
    }

    case CMD_TIME:
    {
      abi_Time_Deserialize(pkt);
    }

    case CMD_GEO:
    {
      is_rotation = abi_check_rotate();
      abi_TRBL_Deserialize(pkt);
    }

    case CMD_NET_RX:
    {
      // abi_ByteN(pkt, 0) - CMD_NET_RX,
      // abi_ByteN(pkt, 1) - line_rx
      // abi_ByteN(pkt, 2) - neighbor_line_tx - neighbor's TX line through which neighbor sent this packet to this module RX line
      // abi_ByteN(pkt, 3) - TTL
      // 4 cells of data in pkt[1..4]
      ON_CMD_NET_RX(pkt);
      switch (abi_ByteN(pkt, 4))
      {
        case P2P_CMD_SEND_TRBL:
        {
          //save TRBL from cubeN
          if ((((abi_ByteN(pkt,6) == 0) && (abi_ByteN(pkt,6) > 200)) || (abi_ByteN(pkt,6) >= trbl_count_rotations)) && (abi_ByteN(pkt,5) != abi_cubeN))
          //new cubeN=abi_ByteN(pkt,5);
          //if (cubeN != abi_cubeN)
          {
            //if (((abi_ByteN(pkt,6) == 0) || (abi_ByteN(pkt,6) > trbl_count_rotations)) && (trbl_count_rotations!=abi_ByteN(pkt,6)))
            trbl_count_rotations=abi_ByteN(pkt,6);
            abi_TRBL[abi_ByteN(pkt,5)][0]=pkt[2];
            abi_TRBL[abi_ByteN(pkt,5)][1]=pkt[3];
            abi_TRBL[abi_ByteN(pkt,5)][2]=pkt[4];
            ticks_for_trbl_clear[abi_ByteN(pkt,5)]=0;
          }
        }
      }
    }

    case CMD_MTD:
    {
      abi_MTD_Deserialize(pkt);
    }

    case CMD_STATE_LOAD:
    {
      // Handle game save here
      ON_LOAD_GAME_DATA (pkt);
    }
  }
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
