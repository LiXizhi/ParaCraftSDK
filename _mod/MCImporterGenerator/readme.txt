- Author: LiPeng, LiXizhi
- Date: 2015.11

### Introduction
added /mcimport command to import minecraft world directory. Please note, it does not import at once, instead it uses the ChunkGenerator interface to load the world dynamically according to current player position. 

### Install
- download the plugin from https://github.com/LiXizhi/MCImporter/releases
- copy MCImporter.dll to paracraft root directory. (currently only 32bits version is built)
- copy MCImporterGenerator.zip to ./Mod folder of paracraft root directory and enable the importer plugin. 

###  How to use
- type /mcimport and select a valid minecraft world directory. or alternatively select from menu::file::import mc world...
- a new world with the same name will be created locally, one may need to teleport the player to correct position to see the world load progressively as the player moves. 

###  reference
source code is based on mapcrafter-master
https://github.com/m0r13/mapcrafter (all files in /mc folder)
require boost zlib 
minecraft is is a trademark of mojang.com. this software is only a converter from minecraft world file to paracraft. 