#!/usr/bin/env python
from __future__ import print_function
import os
import resource_handler


class PawnModule(object):
    FILE_TEMPLATE_PNG = '%03d.png'
    FILE_TEMPLATE_WEBP = '%03d.webp'

    PAWN_INTERPRETER_ID = 0
    WASM_INTERPRETER_ID = 1

    CODE_C_FORMAT = 0
    CODE_BINARY_FORMAT = 1

    def __init__(self):
        self.name = ''
        self.ScriptResourceList = []
        self.ScriptResourceCodeList = []
        self.ScriptResourcePath = ''
        self.resourceCString = ''
        self.InternalFlashStartAddr = 0x0
        self.scriptId = None
        self.ScriptPath = os.path.join('..', 'pawn')
        self.ScriptFileName = None
        self.ScriptCode = None
        self.ScriptCString = ''
        self.MenuIcon = ''
        self.MenuIconCode = ''
        self.MenuSubscriptionIcon = ''
        self.MenuSubscriptionIconCode = ''
        self.version = '0.0.1'
        self.SoundList = []
        self.SoundCodeList = []
        self.SoundPath = ''
        self.InterpreterId = self.PAWN_INTERPRETER_ID
        self.scriptFormat = self.CODE_BINARY_FORMAT

    def c_name(self):
        return self.name.replace(' ', '_')

    def script_c_name(self):
        return '%s_%s' % (self.name.replace(' ', '_'), 'SCR')

    def get_int_version(self):
        version_arr = self.version.split('.')
        if len(version_arr) != 3:
            raise Exception("Invalid version format")

        version_arr = [int(version_item) for version_item in version_arr]
        if version_arr[0] > 0xF or version_arr[1] > 0xF or version_arr[2] > 0xFFFF:
            raise Exception("Invalid version")
        print("Version: %s" % self.version)
        return version_arr[0] << 20 | version_arr[1] << 16 | version_arr[2]

    def size(self):
        c_res_size = 0
        for c_res in self.ScriptResourceCodeList:
            c_res_size += c_res.size()
        return c_res_size

    def select_code_handler(self):
        if self.scriptFormat == self.CODE_C_FORMAT:
            return resource_handler.CResource
        elif self.scriptFormat == self.CODE_BINARY_FORMAT:
            return resource_handler.BinResource
        else:
            raise Exception("Invalid code format: %d" % self.scriptFormat)

    def convert_sound_to_code(self, sound_path, sound_res):
        sound_file_ext = os.path.splitext(sound_res)[1][1:].lower()

        if sound_file_ext == 'c':
            sound_handler = resource_handler.CResource
            encoding = resource_handler.SoundEncoding.ENCODING_WAVE
        elif sound_file_ext == 'wav':
            sound_handler = resource_handler.BinResource
            encoding = resource_handler.SoundEncoding.ENCODING_WAVE
        elif sound_file_ext == 'mid':
            sound_handler = resource_handler.BinResource
            encoding = resource_handler.SoundEncoding.ENCODING_MIDI
        elif sound_file_ext == 'mp3':
            sound_handler = resource_handler.BinResource
            encoding = resource_handler.SoundEncoding.ENCODING_MP3
        else:
            raise Exception("Invalid sound file")

        sound_code = sound_handler(sound_path, sound_res)
        sound_code.encoding = encoding
        return sound_code

    def create_bin_resource(self, res_path, sound_path=None):
        if self.ScriptResourcePath is not None: 
            res_path += '/' + self.ScriptResourcePath
        if self.SoundPath is not None: 
            sound_path += '/' + self.SoundPath

        print("Creating binary PAWN for %s" % self.name)
        if self.ScriptFileName and self.ScriptFileName.lower().endswith(".pwn"):
            print('Error: Pawn sources is not supported (expected .amx file extension in self.ScriptFileName = "%s")' % self.ScriptFileName)
            os.exit(1)
        code_handler = self.select_code_handler()
        self.ScriptCode = code_handler(self.ScriptPath, self.ScriptFileName)
        print("Creating menu icon for %s" % self.name)
        self.MenuIconCode = resource_handler.PngResoure(res_path, self.MenuIcon)
        print("Creating menu subscription icon for %s" % self.name)
        self.MenuSubscriptionIconCode = resource_handler.PngResoure(res_path, self.MenuSubscriptionIcon)

        print("Creating binary RGB for %s" % self.name)
        for res in self.ScriptResourceList:
            if str(res).lower().endswith(".webp"):
                tmp = resource_handler.WebpResource(res_path, res)
                self.ScriptResourceCodeList.append(tmp)
                print("    Processing WebP sprite: %s/%s size: %d B" % (res_path, res, tmp.size()))
                continue
            tmp = resource_handler.PngResoure(res_path, res)
            self.ScriptResourceCodeList.append(tmp)
            print("    Processing RGB-565 RLE-encoded sprite: %s/%s size: %d B" % (res_path, res, tmp.size()))

        print("Creating binary sound list for %s" % self.name)
        if sound_path is not None:
            for sound_res in self.SoundList:
                tmp = self.convert_sound_to_code(sound_path, sound_res)
                self.SoundCodeList.append(tmp)
                print("    Processing sound: %s/%s size: %d B" % (sound_path, sound_res, tmp.size()))
        print('')


class WasmModule(PawnModule):
    def __init__(self):
        super(WasmModule, self).__init__()
        self.InterpreterId = self.WASM_INTERPRETER_ID
        self.scriptFormat = self.CODE_BINARY_FORMAT
