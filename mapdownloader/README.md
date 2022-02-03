# Map Downloader

Automatically download missing maps.

## Usage

To use the plugin simple change the level using `rcon changelevel ...` as normal, the plugin will detect when you're trying to load a non existing map and will automatically attempt to download the map before changing to it.

## Configuration

The config file is located at `addons/sourcemod/configs/mapdownloader.txt`.

Each line denotes a FastDL URL that the plugin will try to fetch the missing map from.

The order that the URLs are checked is sequential.