import pawn_scripts

script_list = [
    pawn_scripts.example1(),
    pawn_scripts.example2(),
    pawn_scripts.example3(),
    pawn_scripts.example4(),
    pawn_scripts.example5(),
    pawn_scripts.example6(),
    pawn_scripts.example7(),
    pawn_scripts.example8(),
    pawn_scripts.example9(),
    pawn_scripts.fourelements(),
    pawn_scripts.worldclock(),
    pawn_scripts.cuberacer(),
    pawn_scripts.exampletap(),
    pawn_scripts.example7_1(),
    pawn_scripts.example7_2(),
    pawn_scripts.examplecubeface(),
    pawn_scripts.Menu(),
    pawn_scripts.Cracer()
]


def wasm_scripts():
    return [
        pawn_scripts.WasmBalls(),
    ]
