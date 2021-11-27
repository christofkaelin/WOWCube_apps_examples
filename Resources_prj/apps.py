import pawn_scripts

script_list = [
    pawn_scripts.example8(),
    pawn_scripts.jigsaw(),
    pawn_scripts.crazyfarm()
]


def wasm_scripts():
    return [
        pawn_scripts.WasmBalls(),
    ]
