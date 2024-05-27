# Chernarus+ Map Downloader
Downloads the latest Chernarus+ Map from iZurvive. Choose between resolution incriments from 1-8.

![Animation](https://user-images.githubusercontent.com/3127698/208580587-369eb715-0002-4da2-9047-1493bee4ebf7.gif)

# Prerequisites

`aria2c` `ImageMagick` `g++`

# Usage

`./getmap [Map] [Res] [Type] [Version]`

[Map] Map name: chernarus, livonia (case sensitive - all lowercase)

[Res]  Map resolution: 1-8

[Type] Map image type: sat (satellite), top (topographic)

[Version] Desired DayZ map version (must be exact, e.g. 1.19.0)

--

_Example:_ `./getmap.sh chernarus 6 sat 1.25.0`

_Example:_ `./getmap.sh livonia 4 sat 1.19.0`

# Warning

Filesize grows exponentially as [Res] increases. The highest resolution setting, 8, will generate a TWO GIGAPIXEL image.

This tool is best used on a powerful system with a strong internet connection. **An NVMe SSD is strongly recommended.**
