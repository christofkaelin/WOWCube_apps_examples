import pawn_scripts

script_list = [
    pawn_scripts.jigsaw(),
    pawn_scripts.crazyfarm(),
    pawn_scripts.worldclock()
]


def wasm_scripts():
    return [
        pawn_scripts.WasmBalls(),
    ]
