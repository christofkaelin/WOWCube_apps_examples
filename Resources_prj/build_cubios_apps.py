import argparse
import struct
import time
import apps
import os
import convert


def create_string(in_str, field_size):
    str_arr = bytearray(in_str, encoding="ascii")
    for _ in range(field_size - len(in_str)):
        str_arr += struct.pack('b', 0)
    return str_arr


def res_to_bin_array(resource, bin_format):
    app_res_bin = struct.pack(bin_format * len(resource.cres), *resource.cres)
    return app_res_bin


class CubRes(object):
    NAME_LEN = 16

    def __init__(self, a_offset=0, a_size=0, a_name=None, a_encoding=0):
        self.Offset = a_offset
        self.Size = a_size
        self.Name = ' ' * self.NAME_LEN if a_name is None else create_string(a_name, self.NAME_LEN)
        self.Encoding = a_encoding

    @staticmethod
    def len():
        return CubRes.NAME_LEN + 3 * len(struct.pack('I', 0))

    def bin(self):
        bin_data = bytearray()
        bin_data += struct.pack('III', self.Offset, self.Size, int(self.Encoding))
        bin_data += self.Name
        return bin_data


class CubResTable(object):
    def __init__(self, resource_list=None):
        self.ResourceList = resource_list

    @staticmethod
    def header_len():
        return 2 * len(struct.pack('I', 0))

    def header_bin(self, offset):
        return struct.pack('II', offset, len(self.ResourceList))

    def descriptor_len(self):
        return CubRes.len() * len(self.ResourceList)

    def descriptor_bin(self, offset):
        bin_array = bytearray()
        for res in self.ResourceList:
            pic_res = CubRes(offset, res.size(), res.fileName, res.encoding)
            bin_array += pic_res.bin()
            offset += res.size()
        return bin_array

    def table_len(self):
        data_len = 0
        for res in self.ResourceList:
            data_len += res.size()
        return data_len

    def table_bin(self, ):
        bin_array = bytearray()
        for res in self.ResourceList:
            bin_array += res_to_bin_array(res, res.rawDataType)
        return bin_array


class CubiosAppBuilder(object):
    BUILD_OUTPUT_DIR = 'build_output'
    APP_PACK_VERSION = 1
    HEADER_SIZE = 12

    def __init__(self, app_list=None, wasm=False):
        if not os.path.exists(self.BUILD_OUTPUT_DIR):
            os.mkdir(self.BUILD_OUTPUT_DIR)
        if wasm:
            apps.script_list += apps.wasm_scripts()
        else:
            print('Add -w arg to build wasm scripts too')
        if app_list is None:
            self.appList = apps.script_list
        else:
            self.appList = []
            for app in app_list:
                for available_app in apps.script_list:
                    if app.upper() == available_app.name.upper():
                        self.appList.append(available_app)
                        break
                else:
                    print("WARNING! Application %s not found" % app)

    def build_applications(self, gui_path, sound_path):
        app_l = {}
        for app in self.appList:
            application_name = "{}.cub".format(app.c_name())
            print('\n----- Building {}------'.format(application_name))
            app.create_bin_resource(gui_path, sound_path)

            app_bin_pack = bytearray()

            app_bin_pack += struct.pack('I', self.APP_PACK_VERSION << 24 | app.get_int_version())
            app_bin_pack += create_string('{}'.format(application_name), 64)
            app_bin_pack += struct.pack('I', app.ScriptCode.size())
            app_bin_pack += struct.pack('I', app.InterpreterId)

            offset = len(app_bin_pack) + 2 * CubResTable.header_len() + 3 * CubRes.len() + self.HEADER_SIZE
            # adding GUI table
            gui_table = CubResTable(app.ScriptResourceCodeList)
            app_bin_pack += gui_table.header_bin(offset)
            offset += gui_table.descriptor_len()

            # adding sound table
            sound_table = CubResTable(app.SoundCodeList)
            app_bin_pack += sound_table.header_bin(offset)
            offset += sound_table.descriptor_len()

            # menu icon
            menu_icon = res_to_bin_array(app.MenuIconCode, 'H') if app.MenuIcon else b''
            menu_icon_res = CubRes(offset, len(menu_icon), app.MenuIcon)
            offset += len(menu_icon)
            app_bin_pack += menu_icon_res.bin()

            # menu subscription icon
            menu_subscr_icon = res_to_bin_array(app.MenuSubscriptionIconCode, 'H') if app.MenuSubscriptionIcon else b''
            menu_subscr_icon_res = CubRes(offset, len(menu_subscr_icon), app.MenuSubscriptionIcon)
            offset += len(menu_subscr_icon)
            app_bin_pack += menu_subscr_icon_res.bin()

            # code
            code = res_to_bin_array(app.ScriptCode, 'B')
            code_res = CubRes(offset, len(code), '')
            offset += len(code)
            app_bin_pack += code_res.bin()

            app_bin_pack += gui_table.descriptor_bin(offset)
            offset += gui_table.table_len()

            app_bin_pack += sound_table.descriptor_bin(offset)
            app_bin_pack += menu_icon
            app_bin_pack += menu_subscr_icon
            app_bin_pack += code
            app_bin_pack += gui_table.table_bin()
            app_bin_pack += sound_table.table_bin()

            app_str = self.append_file_header(app_bin_pack)

            fl = open('%s/%s' % (self.BUILD_OUTPUT_DIR, application_name), 'wb')
            fl.write(app_str)
            app_l[app.c_name()] = app_str
            fl.close()

        print('\n----- Script resource size ------')
        for key, value in app_l.items():
            print("App: %s Size: %2.2fKB" % (key, len(value) / 1024.0))

    @staticmethod
    def append_file_header(app_data):
        size = len(app_data)
        crc = convert.crc32(app_data) & 0xffffffff
        print("CRC: %s" % hex(crc))
        app_data[0:0] = struct.pack('I', crc)
        app_data[0:0] = struct.pack('I', size)
        app_data[0:0] = [0xCC, 0xCC, 0xCC, 0xCC]
        return app_data


def build(gui_path, sound_path, app_list, wasm=False):
    start_build = time.time()
    builder = CubiosAppBuilder(app_list, wasm)
    builder.build_applications(gui_path, sound_path)
    print("Build time: %2.2fsec" % (time.time() - start_build))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Parse map file from resources build')
    parser.add_argument('-g', dest='gui_path', action='store', default="../Content",
                        help='Gui resource folder')
    parser.add_argument('-s', dest='sound_path', action='store', default="../Sound",
                        help='Sound resource folder')
    parser.add_argument('-i', dest='app_list', nargs='+', action='store', default=None,
                        help='Application list')
    parser.add_argument('-w', dest='wasm', action='store_true', default=None,
                        help='Pack Wasm apps')

    args = parser.parse_args()
    build(args.gui_path, args.sound_path, args.app_list, args.wasm)
