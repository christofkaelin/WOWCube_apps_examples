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
        self.SoundList = []


class worldclock(pawn_base.PawnModule):
    def __init__(self):
        super(worldclock, self).__init__()
        self.scriptId = 10
        self.name = 'worldclock'
        self.ScriptFileName = 'worldclock.amx'
        self.ScriptResourcePath = 'worldclock'
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 5)
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
            self.FILE_TEMPLATE_WEBP % ii for ii in range(0, 144)
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


class Cracer(pawn_base.PawnModule):
    def __init__(self):
        super(Cracer, self).__init__()
        self.name = 'Cracer'
        self.scriptId = 13
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_WEBP % ii for ii in range(0, 85)
        ]
        self.ScriptResourcePath = 'cracer'
        self.ScriptFileName = 'cracer.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
            'start.wav',
            'crash.wav',
            'bomb.wav',
            'guardian.wav',
            'guardian_drop.wav',
            'boost.wav',
        ]
        self.SoundPath = 'cracer'


class jigsaw(pawn_base.PawnModule):
    def __init__(self):
        super(jigsaw, self).__init__()
        self.name = 'jigsaw'
        self.scriptId = 13
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 34)
        ]
        self.ScriptResourcePath = 'jigsaw'
        self.ScriptFileName = 'jigsaw.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = [
        ]
        self.SoundPath = 'jigsaw'


class crazyfarm(pawn_base.PawnModule):
    def __init__(self):
        super(crazyfarm, self).__init__()
        self.name = 'crazyfarm'
        self.scriptId = 14
        self.ScriptResourceList = [
            self.FILE_TEMPLATE_PNG % ii for ii in range(0, 35)
        ]
        self.ScriptResourcePath = 'crazyfarm'
        self.ScriptFileName = 'crazyfarm.amx'
        self.MenuIcon = 'icon.png'
        self.SoundList = []
        self.SoundPath = 'crazyfarm'
