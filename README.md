# WOWCube Apps Examples

Application examples and demos.

<details>
<summary><b>Table of Content</b></summary>

- [Cubios ResourcesV2](#cubios-resourcesv2)
    * [Requirements](#requirements)
        + [Installing](#installing)
    * [Build rootfs](#build-rootfs)
        + [Windows (with WSL)](#windows--with-wsl-)
        + [Windows (without WSL)](#windows--without-wsl-)
        + [Linux](#linux)
    * [Flashing rootfs](#flashing-rootfs)
        + [Windows](#windows)
        + [Linux](#linux-1)
    * [Flashing cubelet](#flashing-cubelet)
- [HowTo's](#howto-s)
    * [New Pawn game integration](#new-pawn-game-integration)
    * [Converting png to webp](#converting-png-to-webp)
    * [Audio](#audio)
        + [WAV requirements](#wav-requirements)
        + [MP3 requirements](#mp3-requirements)
</details>

[comment]: <> (TOC generated by https://ecotrust-canada.github.io/markdown-toc/)

## Requirements
- Python
- Pillow, IntelHex, pySerial

[comment]: <> (- buildImage)

### Installing
1. Install Python 3 with PIP
2. Install Python dependencies
   ```shell
   pip install -r requirements.txt
   ```

## Build rootfs
### Windows (with WSL)
Simply build all:
```shell
./build.sh
```

### Windows (without WSL)
1. Remove old cublets and rootfs images if they are exists:
   ```shell
   rd /s /q Resources_prj\build_output
   ```

1. Build Pawn scripts:
   ```shell
    cd pawn
    .\_build.bat
   ```

1. Build cubelets:
   ```shell
   cd ..\Resources_prj
   python build_cubios_apps.py
   ```

1. Pack all cublets as `cubios_rootfs.img`:
   ```shell
   buildImage.exe -g build_output
   ```
   Then convert it to `rootfs.img`:
   ```shell
   python convert.py -s cubios_rootfs.img -d build_output\rootfs.img 
   ```


### Linux
```shell
./build.sh
```

## Flashing rootfs
Connect WOWCube module first.

### Windows
Find your COM Port:
```shell
reg query HKLM\HARDWARE\DEVICEMAP\SERIALCOMM
```
Flash binary file into internal memory:
```shell
python Resources_prj/flashBurn.py Resources_prj/build_output/rootfs.img -c COM5
```

### Linux
```shell
python flashBurn.py rootfs.img -c /dev/ttyACM0
```

## Flashing cubelet
Same as Flashing rootfs, but instead of `rootfs.img` use the name of your cubelet, for example `pipes.cub`.


# HowTo's

## New Pawn game integration
1. Create script inside `pawn` folder
2. Add it to build files (`Makefile`, `_build.bat` and `build.sh`)
3. Inside `Resources_prj/pawn_scripts.py`, create game description class inherited from `PawnModule`:
   - `self.name` - name of game that will be displayed in WOWCube's menu
   - `self.scriptId` (obsolete) - id that reflects script order. The same id should be assigned in menu script.
   - `self.ScriptFileName` - name of built file.
   - `self.ScriptResourcePath` - folder name with sprites inside `Contents` folder.
   - `self.ScriptResourceList` - list of sprites. An order of resources is important because it represents linkage between pawn and platform. When pawn requests to load and show some resource it is referenced by id.
   
     Resource id is and index in resource list associated with loaded script.
   - `self.MenuIcon` - menu icon (only png images)

4. Update `script_list` in `Resources_prj/apps.py`

## Converting png to webp
**NOTE: Lossless WebP image, or WebP image with alpha channel, requires more memory on the platform to decode it.** The larger lossless or transparent image is, the more memory is required to decode it.

You can use [squoosh.app](https://squoosh.app/) to find the best settings for your needs.

Or you can use cwebp tool:
```shell
cwebp [-preset <...>] [options] [-o out_file] -- in_file
```
Docs: https://developers.google.com/speed/webp/docs/cwebp#options

Installation:
```shell
sudo apt install webp
```

Examples:
- Default batch processing for all sprites:
  ```shell
  find ./Content -name "*.png" -exec bash -c 'cwebp -q 100 -blend_alpha 0x000000 -o "${0%.png}.webp" -- $0' {} \;
  ```
  - `-q 100` quality level 100. This value is used because black pixels can be lighter, or some lighter pixels can be black after encoding with lower quality level. So transparent pixel may become opaque or vice-versa.
  - `-blend_alpha 0x000000` blends alpha with provided color and discards alpha channel. Avoid `-noalpha`.
  
  Note:
  - `-sharp_yuv` should not be used here, see `-q 100` explanation above. 
  - Try also `-pass <num>` and `-m <num>` controls with low values to reach higher PSNR, see `-q 100` explanation above.
    
- For games with a lot of content, where transparency quality is not significant, such as Manga:
  ```shell
  find ./Content -name "*.png" -exec bash -c 'cwebp -q 90 -sharp_yuv -pass 10 -m 6 -noalpha -o "${0%.png}.webp" -- $0' {} \;
  ```
  - `-q 90` is quality level 90. It may be even lower to fit more content.
  - `-sharp_yuv` significantly [improves visual image quality](https://www.ctrl.blog/entry/webp-sharp-yuv.html).
  - `-pass 10` produces better PSNR/size ratio.
  - `-m 6` controls the trade off between encoding speed and the compressed file size and quality.

## Audio

### WAV requirements
- Channels: 1 (mono)
- Sample rate: 22050 Hz
- Audio codec: pcm_s16le (others not tested)

```shell
ffmpeg -y -i input.wav -ac 1 -acodec pcm_s16le -ar 22050 output.wav
```

### MP3 requirements
WIP.

- Channels: 1 (mono)
- Bitrate: 48 kb/s
- Sample rate: 48000 Hz

```shell
ffmpeg -y -i input.wav -vn -ac 1 -ar 48000 -b:a 48k output.mp3
```

Batch processing:
```shell
for i in *.wav; do ffmpeg -i "$i" -vn -ac 2 -ar 48000 -b:a 48k "${i%}.mp3"; done
```
