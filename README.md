# Chernarus+ Map Downloader
Downloads the latest Chernarus+ Map from iZurvive. Choose between resolution incriments from 1-8.

![Animation](https://user-images.githubusercontent.com/3127698/208580587-369eb715-0002-4da2-9047-1493bee4ebf7.gif)

# Prerequisites

`aria2c` `ImageMagick` `g++`

# Usage

`./getmap [Res] [Type]`

[Res]  Map resolution: 1-8

[Type] Map image type: sat (satellite), top (topographic)

# Warning

Filesize grows exponentially as [Res] increases. The highest resolution setting, 8, will generate a TWO GIGAPIXEL image.

This tool is best used on a powerful system with a strong internet connection.
