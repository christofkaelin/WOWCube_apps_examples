#!/usr/bin/env python
from __future__ import print_function
import os
import argparse
import struct
import time
import pawn_scripts
import convert
try:
    import intelhex
except ImportError:
    intelhex = None


ScriptList = [
    pawn_scripts.Menu(),
    pawn_scripts.Pipes(),
    pawn_scripts.Butterflies(),
    pawn_scripts.CrosswordPuzzle(),
    pawn_scripts.G2048(),
    pawn_scripts.Pong(),
    pawn_scripts.YellowBall(),
    pawn_scripts.Rubik_2x2(),
    #pawn_scripts.MonsterMath(),
    pawn_scripts.EndlessButterflies(),
    pawn_scripts.EatThePizza(),
    pawn_scripts.Arkanoid(),
    pawn_scripts.Bonbon(),
	pawn_scripts.Shapes(),
]


class FlashResourceGen(object):
    HEADER_FILE_DATA = """//DO NOT EDIT. This code is autogenerated by resource_map_parser.py
#ifndef _CUBIOS_RESOURCE_AUTOGEN_
#define _CUBIOS_RESOURCE_AUTOGEN_

#include "resources.h"

extern const script_t flash_resources[AMX_MAX_GAME_ID];

#endif //_CUBIOS_RESOURCE_AUTOGEN_
"""

    C_FILE_DATA_BEGIN = """//DO NOT EDIT. This code is autogenerated by resource_map_parser.py
#include "{0}"

"""
    C_FILE_RESOURCE_ARRAY = """
const script_t flash_resources[AMX_MAX_GAME_ID] = {
"""

    C_ARRAY_END = """};\n"""

    ARRAY_TYPE = 'static const cubios_bitmap_res_t'

    HEADER_EXT = '.h'
    C_EXT = '.c'

    def __init__(self):
        pass

    def print_size(self):
        whole_size = 0
        print('\n----- Script resource size ------')
        for script in ScriptList:
            print("Script: %s Size: %2.2fKB (%dB)" % (script.name, script.size() / 1024.0, script.size()))
            whole_size += script.size()
        print('\n----- Overall size ------')
        print("%2.2fKB (%dB)" % (whole_size / 1024.0, whole_size))

    def calculate_internal_flash_addr(self, last_addr, res_size):
        # if res_size % 4:
        #     return last_addr + res_size + (4 - res_size % 4)
        # else:
        return last_addr + res_size

    def generatre_resources(self, resource_path):
        for script in ScriptList:
            script.create_bin_resource(resource_path)

    def create_resource_file(self, dest_res, make_hex):
        print('\n----- Building resource HEX file ------')
        if make_hex:
            if intelhex is None:
                print("Python module 'IntelHEX' is not installed")
                exit(1)
            ih = intelhex.IntelHex()
        binary_image = b''
        # 12 bytes header
        external_addr = 12
        internal_addr = ScriptList[0].InternalFlashStartAddr
        # for bt in [0xff, 0xff, 0xff, 0xff]:
        #     ih.puts(external_addr, struct.pack('B', bt))
        #     external_addr += 1
        for script in ScriptList:
            internal_addr = script.InternalFlashStartAddr
            script.InternalFlashStartAddr = internal_addr
            script.ScriptCode.externalAddr = external_addr
            script.ScriptCode.internalAddr = internal_addr
            script.ScriptCString = '{0x%x, 0x%x, 0x%x, 0x%x}' % (
                script.ScriptCode.externalAddr,
                script.ScriptCode.internalAddr,
                script.ScriptCode.size(),
                script.ScriptCode.crc32()
            )
            for res in script.ScriptCode.cres:
                tmp_s = struct.pack('B', res)
                if make_hex:
                    ih.puts(external_addr, tmp_s)
                binary_image += tmp_s
                external_addr += 1  # sizeof(unsigned char)
            internal_addr = self.calculate_internal_flash_addr(internal_addr, script.ScriptCode.size())
            for script_res in script.ScriptResourceCodeList:
                script_res.externalAddr = external_addr
                script_res.internalAddr = internal_addr
                script.resourceCString += '    {0x%x, 0x%x, 0x%x, 0x%x}, //%s\n' % (
                    script_res.externalAddr,
                    script_res.internalAddr,
                    script_res.size(),
                    script_res.crc32(),
                    script_res.fileName
                )
                for res in script_res.cres:
                    tmp_s = struct.pack('H', res)
                    if make_hex:
                        ih.puts(external_addr, tmp_s)
                    binary_image += tmp_s
                    external_addr += 2  # sizeof(unsigned short)
                internal_addr = self.calculate_internal_flash_addr(internal_addr, script_res.size())
        bi_file = open(dest_res.replace('hex', 'bin'), 'wb')
        bi_file.write(binary_image)
        bi_file.close()

        if make_hex:
            ih.write_hex_file(dest_res, eolstyle="CRLF")

        image_byte_array = bytearray(binary_image)
        size = len(image_byte_array)
        crc = convert.crc32(image_byte_array) & 0xffffffff
        print("CRC: %s" % hex(crc))
        image_byte_array[0:0] = struct.pack('I', crc)
        image_byte_array[0:0] = struct.pack('I', size)
        image_byte_array[0:0] = [0xff, 0xff, 0xff, 0xff]
        binary_image_with_header = open('res_converted.bin', 'wb')
        binary_image_with_header.write(image_byte_array)
        binary_image_with_header.close()

    def create_resource_map(self, file_name):
        print('\n----- Building C map file ------')
        h_file_path = "%s%s" % (file_name, self.HEADER_EXT)
        h_file = open(h_file_path, 'wt')
        h_file.write(self.HEADER_FILE_DATA)
        h_file.close()

        c_file_name = "%s%s" % (file_name, self.C_EXT)
        c_file = open(c_file_name, 'wt')

        _, h_file = os.path.split(h_file_path)
        c_file.write(self.C_FILE_DATA_BEGIN.format(h_file))
        for script in sorted(ScriptList, key=lambda pawn: pawn.scriptId):
            if script.ScriptCString:
                c_file.write("%s %s = %s; //%s\n\n" % (
                    self.ARRAY_TYPE,
                    script.script_c_name(),
                    script.ScriptCString,
                    script.ScriptFileName)
                )
            if script.resourceCString:
                c_file.write("%s %s[] = {\n" % (self.ARRAY_TYPE, script.c_name()))
                c_file.write(script.resourceCString)
                c_file.write("};\n\n")

        c_file.write(self.C_FILE_RESOURCE_ARRAY)
        for script in sorted(ScriptList, key=lambda pawn: pawn.scriptId):
            c_logic_pointer = script.script_c_name() if script.ScriptCString else '0'
            c_res_pointer = script.c_name() if script.resourceCString else '0'
            c_file.write("    {&%s, %s, %d},\n" % (
                c_logic_pointer,
                c_res_pointer,
                len(script.ScriptResourceCodeList)))
        c_file.write(self.C_ARRAY_END)

        c_file.close()


def generate(resource_path, dest_res, dest_c_map, make_hex=False):
    start_build = time.time()
    res_map = FlashResourceGen()
    res_map.generatre_resources(resource_path)
    res_map.create_resource_file(dest_res, make_hex)
    res_map.create_resource_map(dest_c_map)
    res_map.print_size()
    print("Build time: %2.2fsec" % (time.time() - start_build))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Parse map file from resources build')
    parser.add_argument('-s', dest='resource_path', action='store', default="../Content",
                        help='Resource folder')
    parser.add_argument('-d', dest='destination', action='store', default="res.hex",
                        help='Destination file name')
    parser.add_argument('-m', dest='map', action='store', default="../../CubiosV2/GUI/cubios_resources",
                        help='Destination map file name')
    parser.add_argument('--hex', dest='make_hex', action='store_true', default=False,
                        help='Destination map file name')

    args = parser.parse_args()
    generate(args.resource_path, args.destination, args.map, args.make_hex)
