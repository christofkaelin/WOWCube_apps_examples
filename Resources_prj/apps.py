import pawn_scripts

script_list = [
    pawn_scripts.example7(),
    pawn_scripts.Cracer(),
    pawn_scripts.jigsaw(),
    pawn_scripts.crazyfarm()
]


def wasm_scripts():
    return [
        pawn_scripts.WasmBalls(),
    ]
