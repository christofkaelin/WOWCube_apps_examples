GAMES_LIST = jigsaw crazyfarm worldclock
AMX_FILES_LIST = $(addsuffix .amx, $(GAMES_LIST))

# bytes for .AMX script bytecode and its stack - must be equal to platform config
PAWN_SCRIPT_SIZE_MAX_BYTES=100000

.PHONY: all clean

all: $(AMX_FILES_LIST)

%.amx: %.pwn
	pawncc -X$(PAWN_SCRIPT_SIZE_MAX_BYTES) -d0 -O3 -v2 $<

clean:
	rm -f -- $(AMX_FILES_LIST)
