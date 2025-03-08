#!/bin/bash

# arguments:
# 1) base names of the packs - namespace, from which the <name>-resourcepack and <name>-datapack will be derived
# 2) display name of the song - what will be visible on the disc
# 3) filename - name of the .ogg file, plus will be used as an ID of the item
# 4) length of the song in seconds - integer

# make sure that the .ogg file is mono, stereo won't work.

# for the datapack, make sure to rename inner folders as well when renaming the pack - they must match

# the name of the resource pack should match, probalby... idk, why would you even name them different ways

# also, change the pack descriptions (and you might need to change the version, so that Minecraft won't yell at you that "your pack is old!!1!1". You'll probably have to look that up on minecraft wiki)

#########################################################

# creates mcfunction to give the disc
echo "give @s minecraft:music_disc_13[minecraft:jukebox_playable={song:\"$1:$3\"},minecraft:custom_model_data={strings:[\"music_disc_$3\"]}]" > $1-datapack/data/$1/function/$3.mcfunction

# adds the main JSON of the disc
echo -e "{\n    \"comparator_output\": 15,\n    \"description\": \"$2\",\n    \"length_in_seconds\": $4.0,\n    \"sound_event\": {\n      \"sound_id\": \"minecraft:music_disc.$3\"\n    }\n }" > $1-datapack/data/$1/jukebox_song/$3.json

# edit the model file:
# first, load the original
original=`cat $1-resourcepack/assets/minecraft/items/music_disc_13.json`

# find the "cases" thing, so I can insert a new list item there later
searchfor='"cases": ['
rest=${original#*$searchfor}
position=$(( ${#original} - ${#rest} ))

# split on the "cases"
startpart=${original:0:position}
endpart=${original:position:1000000}  # this is a problem for future me

# insert new case
newstring="$startpart      {\n        \"when\": \"music_disc_$3\",\n        \"model\": {\n          \"type\": \"model\",\n          \"model\": \"item/music_disc_$3\"\n        }\n      },$endpart"
echo -e $newstring > $1-resourcepack/assets/minecraft/items/music_disc_13.json


# add item model
echo -e "{\n	\"parent\": \"item/generated\",\n	\"textures\": {\n		\"layer0\": \"item/music_disc_$3\"\n	}\n}" > $1-resourcepack/assets/minecraft/models/item/music_disc_$3.json

# add to the sound file
soundsfile=`cat $1-resourcepack/assets/minecraft/sounds.json`
# delete the first "{"
withoutfirstbracket=${soundsfile:1:1000000}  # once again, problem for future me
echo -e "{\n\"music_disc.$3\": {\n	\"sounds\": [\n		{\n		\"name\": \"records/$3\"\n		}\n	]\n}, $withoutfirstbracket" > $1-resourcepack/assets/minecraft/sounds.json 

# final info for the user
echo "Add your .ogg file to $1-resourcepack/assets/minecraft/sounds/records/$3.ogg"
echo "Add your .png texture file to $1-resourcepack/assets/minecraft/textures/item/music_disc_$3.ogg"

