#!/usr/bin/env python
import os
import sys
import glob
import shutil
import zipfile
import tempfile
import pawn_base


class example1(pawn_base.PawnModule):
    def __init__(self):
        super(example1, self).__init__()
        self.scriptId = 0
        self.name = 'example1'
        self.ScriptFileName = 'example1.amx'
        self.ScriptResourcePath = 'example1'
        self.ScriptResourceList = []
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example2(pawn_base.PawnModule):
    def __init__(self):
        super(example2, self).__init__()
        self.scriptId = 1
        self.name = 'example2'
        self.ScriptFileName = 'example2.amx'
        self.ScriptResourcePath = 'example2'
        self.ScriptResourceList = []
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example3(pawn_base.PawnModule):
    def __init__(self):
        super(example3, self).__init__()
        self.scriptId = 2
        self.name = 'example3'
        self.ScriptFileName = 'example3.amx'
        self.ScriptResourcePath = 'example3'
        self.ScriptResourceList = [
            '000.png'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example4(pawn_base.PawnModule):
    def __init__(self):
        super(example4, self).__init__()
        self.scriptId = 3
        self.name = 'example4'
        self.ScriptFileName = 'example4.amx'
        self.ScriptResourcePath = 'example4'
        self.ScriptResourceList = [
            '000.png'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example5(pawn_base.PawnModule):
    def __init__(self):
        super(example5, self).__init__()
        self.scriptId = 4
        self.name = 'example5'
        self.ScriptFileName = 'example5.amx'
        self.ScriptResourcePath = 'example5'
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 4)
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example6(pawn_base.PawnModule):
    def __init__(self):
        super(example6, self).__init__()
        self.scriptId = 5
        self.name = 'example6'
        self.ScriptFileName = 'example6.amx'
        self.ScriptResourcePath = 'example6'
        self.ScriptResourceList = [
            '000.png'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example7(pawn_base.PawnModule):
    def __init__(self):
        super(example7, self).__init__()
        self.scriptId = 6
        self.name = 'example7'
        self.ScriptFileName = 'example7.amx'
        self.ScriptResourcePath = 'example7'
        self.ScriptResourceList = [
            '000.png'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example8(pawn_base.PawnModule):
    def __init__(self):
        super(example8, self).__init__()
        self.scriptId = 7
        self.name = 'example8'
        self.ScriptFileName = 'example8.amx'
        self.ScriptResourcePath = 'example8'
        self.ScriptResourceList = []
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example9(pawn_base.PawnModule):
    def __init__(self):
        super(example9, self).__init__()
        self.scriptId = 8
        self.name = 'example9'
        self.ScriptFileName = 'example9.amx'
        self.ScriptResourcePath = 'example9'
        self.ScriptResourceList = []
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class fourelements(pawn_base.PawnModule):
    def __init__(self):
        super(fourelements, self).__init__()
        self.scriptId = 10
        self.name = 'fourelements'
        self.ScriptFileName = 'fourelements.amx'
        self.ScriptResourcePath = 'fourelements'
        self.ScriptResourceList = [
            '%d.webp' % ii for ii in range(0, 2052)
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'fourelements'
        self.SoundList = [
            'fire.wav', 'water.wav'
        ]


class worldclock(pawn_base.PawnModule):
    def __init__(self):
        super(worldclock, self).__init__()
        self.scriptId = 10
        self.name = 'worldclock'
        self.ScriptFileName = 'worldclock.amx'
        self.ScriptResourcePath = 'worldclock'
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_WEBP % ii for ii in range(0, 5)
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'worldclock'
        self.SoundList = []


class cuberacer(pawn_base.PawnModule):
    def __init__(self):
        super(cuberacer, self).__init__()
        self.scriptId = 10
        self.name = 'cuberacer'
        self.ScriptFileName = 'cuberacer.amx'
        self.ScriptResourcePath = 'cuberacer'
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_WEBP % ii for ii in range(0, 188)
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'cuberacer'
        self.SoundList = []


class exampletap(pawn_base.PawnModule):
    def __init__(self):
        super(exampletap, self).__init__()
        self.scriptId = 11
        self.name = 'exampletap'
        self.ScriptFileName = 'exampletap.amx'
        self.ScriptResourcePath = 'exampletap'
        self.ScriptResourceList = []
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'exampletap'
        self.SoundList = []


class example7_1(pawn_base.PawnModule):
    def __init__(self):
        super(example7_1, self).__init__()
        self.scriptId = 12
        self.name = 'example7_1'
        self.ScriptFileName = 'example7_1.amx'
        self.ScriptResourcePath = 'example7_1'
        self.ScriptResourceList = [
            '000.webp', '001.webp', '002.webp'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class example7_2(pawn_base.PawnModule):
    def __init__(self):
        super(example7_2, self).__init__()
        self.scriptId = 12
        self.name = 'example7_2'
        self.ScriptFileName = 'example7_2.amx'
        self.ScriptResourcePath = 'example7_1'
        self.ScriptResourceList = [
            '000.webp', '001.webp', '002.webp'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''
        self.SoundList = []


class examplecubeface(pawn_base.PawnModule):
    def __init__(self):
        super(examplecubeface, self).__init__()
        self.scriptId = 11
        self.name = 'examplecubeface'
        self.ScriptFileName = 'examplecubeface.amx'
        self.ScriptResourcePath = 'examplecubeface'
        self.ScriptResourceList = [
            '000.webp'
        ]
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'examplecubeface'
        self.SoundList = []


class Menu(pawn_base.PawnModule):
    def __init__(self):
        super(Menu, self).__init__()
        self.name = 'MENU'
        self.scriptId = 0
        self.InternalFlashStartAddr = 0x0
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 40)
        ] + [
            'font200x200.png'
        ]
        self.ScriptResourcePath = 'menu'
        self.SoundPath = ''


class Test1(pawn_base.PawnModule):
    def __init__(self):
        super(Test1, self).__init__()
        self.name = 'Test1'
        self.scriptId = 1
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_WEBP % ii for ii in range(0, 24)
        ]
        self.ScriptResourcePath = 'test1'
        self.ScriptFileName = 'test1.amx'
        self.MenuIcon = 'icon.png'


class Test2(pawn_base.PawnModule):
    def __init__(self):
        super(Test2, self).__init__()
        self.name = 'Test2'
        self.scriptId = 2
        self.ScriptResourceList = [
        ]
        self.ScriptResourcePath = 'test2'
        self.ScriptFileName = 'test2.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'test2'
        self.SoundList = [
            '1.wav',
            '2.mp3',
            'piano.mid',
        ]


class Pipes(pawn_base.PawnModule):
    def __init__(self):
        super(Pipes, self).__init__()
        self.name = 'PIPES'
        self.scriptId = 1
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 30)
        ]
        self.ScriptResourcePath = 'pipes'
        self.ScriptFileName = 'pipes.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'pipes'
        self.SoundList = [
            'launch.c',
            'next_level.c',
            'short_burst.c',
            'short_burst2.c',
            'steam_burst.c',
        ]


class Butterflies(pawn_base.PawnModule):
    def __init__(self):
        super(Butterflies, self).__init__()
        self.name = 'BUTTERFLIES'
        self.scriptId = 2
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 32)
        ]
        self.ScriptResourcePath = 'butterflies'
        self.ScriptFileName = 'butterflies.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'butterflies'
        self.SoundList = [
            'assembled.c'
        ]


class CrosswordPuzzle(pawn_base.PawnModule):
    def __init__(self):
        super(CrosswordPuzzle, self).__init__()
        self.name = 'CROSSWORD PUZZLE'
        self.scriptId = 3
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 42)
        ]
        self.ScriptResourcePath = 'scrabble'
        self.ScriptFileName = 'scrabble.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''


class G2048(pawn_base.PawnModule):
    def __init__(self):
        super(G2048, self).__init__()
        self.name = 'G2048'
        self.scriptId = 4
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 18)
        ]
        self.ScriptResourcePath = 'g2048'
        self.ScriptFileName = 'G2048.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'g2048'
        self.SoundList = [
            'newBestChip.c',
            'gameOver.c',
            'stageComplete.c',
            'win.c',
            'sameBestChip.c',
        ]


class Pong(pawn_base.PawnModule):
    def __init__(self):
        super(Pong, self).__init__()
        self.name = 'PONG'
        self.scriptId = 5
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 33)
        ]
        self.ScriptResourcePath = 'pong'
        self.ScriptFileName = 'pong.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'pong'
        self.SoundList = [
            'bounce_mid.c'
        ]


class YellowBall(pawn_base.PawnModule):
    def __init__(self):
        super(YellowBall, self).__init__()
        self.name = 'Yellow Ball'
        self.scriptId = 6
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 51)
        ]
        self.ScriptResourcePath = 'yellowball'
        self.ScriptFileName = 'pacman.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
            'energizer.c',
            'ghostEaten.c',
            'powerup.c',
            'deathLong.c',
            'gameStartL.c',
            'nextLevel.c',
            'portalIn.c',
            'portalOut.c',
            'WA.c',
            'KA.c',
            'portalGhost.c',
        ]
        self.SoundPath = 'yellowball'


class Rubik_2x2(pawn_base.PawnModule):
    def __init__(self):
        super(Rubik_2x2, self).__init__()
        self.name = 'Rubik 2x2'
        self.scriptId = 7
        self.ScriptResourceList = []
        self.ScriptResourcePath = 'rubik_2x2'
        self.ScriptFileName = 'rubik_2x2.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''


"""
class MonsterMath(pawn_base.PawnModule):
    def __init__(self):
        super(MonsterMath, self).__init__()
        self.name = 'MonsterMath'
        self.scriptId = 8
        self.ScriptResourceList = [
            self.PNG_FILE_TEMPLATE % ii for ii in range(0, 64)
        ]
        self.ScriptResourcePath = 'monstermath'
        self.ScriptFileName = 'monster_math.amx'
        self.MenuIcon = 'icon.png'
        self.MenuSubscriptionIcon = 'label.png'
"""


class EndlessButterflies(pawn_base.PawnModule):
    def __init__(self):
        super(EndlessButterflies, self).__init__()
        self.name = 'Endless Butterflies'
        self.scriptId = 8
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 39)
        ]
        self.ScriptResourcePath = 'endlessbutterflies'
        self.ScriptFileName = 'endless_butterfly.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'endless_butterflies'
        self.SoundList = [
            'assembled.c',
            'new_1.c',
            'new_2.c'
        ]


class EatThePizza(pawn_base.PawnModule):
    def __init__(self):
        super(EatThePizza, self).__init__()
        self.name = 'Eat_the_pizza'
        self.scriptId = 9
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 90)
        ]
        self.ScriptResourcePath = 'eatthepizza'
        self.ScriptFileName = 'eat_the_pizza.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'eatthepizza'
        self.SoundList = [
            'onto_dough.c',
            'eats.c'
        ]


class Arkanoid(pawn_base.PawnModule):
    def __init__(self):
        super(Arkanoid, self).__init__()
        self.name = 'Arkanoid'
        self.scriptId = 10
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 31)
        ]
        self.ScriptResourcePath = 'arkanoid'
        self.ScriptFileName = 'arkanoid.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''


class Bonbon(pawn_base.PawnModule):
    def __init__(self):
        super(Bonbon, self).__init__()
        self.name = 'Bonbon'
        self.scriptId = 11
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 53)
        ]
        self.ScriptResourcePath = 'bonbon'
        self.ScriptFileName = 'bonbon.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
            'gameStart.mp3',
            'combined.mp3',
            'newSweet.mp3',
            'winCake.mp3',
        ]
        self.SoundPath = 'bonbon'


class Shapes(pawn_base.PawnModule):
    def __init__(self):
        super(Shapes, self).__init__()
        self.name = 'Shapes'
        self.scriptId = 12  # 13
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 50)
        ]
        self.ScriptResourcePath = 'shapes'
        self.ScriptFileName = 'shapes.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''


class Ladybug(pawn_base.PawnModule):
    def __init__(self):
        super(Ladybug, self).__init__()
        self.name = 'Ladybug'
        self.scriptId = 13
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 59)
        ]
        self.ScriptResourcePath = 'ladybug'
        self.ScriptFileName = 'ladybug.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
            'starting.c',
            'game_over.c',
            'poison.c',
            'berry_eaten.c',
        ]
        self.SoundPath = 'ladybug'


class Widgets(pawn_base.PawnModule):
    def __init__(self):
        super(Widgets, self).__init__()
        self.name = 'Widgets'
        self.scriptId = 14
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 28)
        ]
        self.ScriptResourcePath = 'widgets'
        self.ScriptFileName = 'widgets.amx'
        self.SoundPath = ''


class SpaceInvaders(pawn_base.PawnModule):
    def __init__(self):
        super(SpaceInvaders, self).__init__()
        self.name = 'Space_invaders'
        self.scriptId = 15
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 20)
        ]
        self.ScriptResourcePath = 'spaceinvaders'
        self.ScriptFileName = 'space_invaders.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''


class CutTheRope(pawn_base.PawnModule):
    def __init__(self):
        super(CutTheRope, self).__init__()
        self.name = 'Cut_the_rope'
        self.scriptId = 16
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 10)
        ]
        self.ScriptResourcePath = 'cuttherope'
        self.ScriptFileName = 'cut_the_rope.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = ''


class Timer(pawn_base.PawnModule):
    def __init__(self):
        super(Timer, self).__init__()
        self.name = 'Timer'
        self.scriptId = 17
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 6)
        ]
        self.ScriptResourcePath = 'timer'
        self.ScriptFileName = 'timer.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
            'timerEnd.mp3',
        ]
        self.SoundPath = 'timer'


class Racing(pawn_base.PawnModule):
    def __init__(self):
        super(Racing, self).__init__()
        self.name = 'Racing'
        self.scriptId = 18
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 29)
        ]
        self.ScriptResourcePath = 'racing'
        self.ScriptFileName = 'racing.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
        ]
        self.SoundPath = 'racing'


class Aquarium(pawn_base.PawnModule):
    def __init__(self):
        super(Aquarium, self).__init__()
        self.name = 'Aquarium'
        self.scriptId = 18
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 18)
        ]
        self.ScriptResourcePath = 'aquarium'
        self.ScriptFileName = 'aquarium.amx'
        self.MenuIcon = 'icon.png'
        self.SoundPath = 'aquarium'


def url_retrieve(url):
    if sys.version_info[0] <= 2:
        import urllib
        return urllib.urlretrieve(url)[0]
    elif sys.version_info[0] <= 3:
        import urllib.request
        return urllib.request.urlretrieve(url)[0]


def download_unzip_wasm(script_path):
    if getattr(download_unzip_wasm, 'done', None):
        return
    download_unzip_wasm.done = True
    print('Getting WASM release bits...')
    bin_zip = url_retrieve(
        'https://github.com/wowcube/wasm/releases/download/0.0.5/bin.zip')
    extract = os.path.join(tempfile.mkdtemp())
    print('Unzipping WASM release bits...')
    with zipfile.ZipFile(bin_zip, 'r') as zip_ref:
        zip_ref.extractall(extract)
    pawn_dir = os.path.join(os.getcwd(), script_path)
    print('Copying *_r.wasm files...')
    for file in glob.glob(os.path.join(extract, 'bin', '*_r.wasm')):
        shutil.copy(file, pawn_dir)
    print('Done.')


class WasmBalls(pawn_base.WasmModule):
    def __init__(self):
        super(WasmBalls, self).__init__()
        download_unzip_wasm(self.ScriptPath)
        self.name = 'WasmBalls'
        self.ScriptFileName = 'ball_r.wasm'
        self.ScriptResourcePath = 'WasmBalls'
        self.MenuIcon = 'icon.png'
