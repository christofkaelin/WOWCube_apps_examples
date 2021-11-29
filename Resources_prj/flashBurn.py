import serial
import time
import sys
import argparse

send_block = 0x100


def flash_burn(file_name, com_port):
    flash_data = []
    with open(file_name, 'rb') as fl:
        flash_data = bytearray(fl.read())
    ser = serial.Serial(com_port)

    send_data = 0

    start = time.time()
    log = ''
    while send_data < len(flash_data):
        # just_read = ser.read(40)
        # log += just_read
        time.sleep(0.0035)

        ser.write(flash_data[send_data: send_data + send_block])
        send_data += send_block
        if send_data % 0x1000:
            s = "sent %.2f %%" % (float(send_data) / len(flash_data) * 100)
            sys.stdout.write('\r' + s)

    print("Send time: %f" % (time.time() - start))

    # while "Update finished" not in log:
    #     read_data = ser.read(100)
    #     #time.sleep(0.05)
    #     print(read_data)
    #     log += read_data

    # print log[-100: -1]

    # f = open('log.log', 'wt')
    # f.write(log)
    # f.close()
    ser.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Burn CubiOS flash')
    parser.add_argument('res_file', help='Resource file to burn')
    parser.add_argument('-c', '--com', required=True, dest='com_port', default='',
                        help='COM port')

    args = parser.parse_args()
    flash_burn(args.res_file, args.com_port)
