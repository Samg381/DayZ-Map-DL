#!/bin/bash

# DayZ ChernarusPlus Map Downloader
# Created by Samg381 | samg381.com
# Usage: ./getmap [Res] [Type] [Version]
#		 [Res]  Map resolution: 1-8
#		[Type]  Map image type: sat, top
#    [Version]  Desired DayZ Version (e.g. 1.19.0)

RES=$1
TYP=$2
VER=$3


if [ $# -eq 3 ] 
then
    printf "\nDayZ ChernarusPlus Map Downloader by Samg381 | samg381.com\n\n"
else
    echo "Invalid arguments. Please check documentation."
    echo "Example usage: ./getmap.sh [Res (1-8)] [Type (sat/top)] [Version (e.g. 1.19.0)]"
    exit
fi


printf "Downloading $TYP map at ${RES}x resolution.\n\n\n"

if [ $RES == 1 ]; then
	SIZE=1
elif [ $RES == 2 ]; then
	SIZE=3
elif [ $RES == 3 ]; then
	SIZE=7
elif [ $RES == 4 ]; then
	SIZE=15
elif [ $RES == 5 ]; then
	SIZE=31
elif [ $RES == 6 ]; then
	SIZE=63
elif [ $RES == 7 ]; then
	SIZE=127
elif [ $RES == 8 ]; then
	SIZE=255
	printf "Warning! You have selected 8x resolution- This will create a FOUR GIGAPIXEL (65000x65000px) image. This will take a while!\n"
	printf "Processing images of this size is prone to failure. If you encounter errors, please check imagemagick config in /etc/imagemagick/policy.xml.\n"
else
	printf "Please specify a valid resolution (1-8) ( ex: ./getmap 4 sat )\n"
	exit;
fi




printf "Setting up...\n"

mkdir -p maps
rm -r -f tmp > /dev/null 2>&1
mkdir -p tmp
ulimit -n 2048

touch TilesToDownload.txt
truncate -s 0 TilesToDownload.txt

TOT=$((SIZE+1))




printf "Generating download list...\n"

for (( y=0; y<=$SIZE; y++ ))
do
	for (( x=0; x<=$SIZE; x++ ))
	do
	
		xFileName=$(printf "%03d" $x)
		yFileName=$(printf "%03d" $y)
	
		
		# echo https://maps.izurvive.com/maps/ChernarusPlus-Top/"$VER"/tiles/"$RES"/"$x"/"$y".jpg | xargs wget -O "${yFileName}_${xFileName}.jpg" > /dev/null 2>&1
		
		# aria2c -x 16 -o "${yFileName}_${xFileName}.jpg" https://maps.izurvive.com/maps/ChernarusPlus-Top/"$VER"/tiles/"$RES"/"$x"/"$y".jpg > /dev/null 2>&1
		
		
		if [ $2 == "top" ]; then
			echo https://maps.izurvive.com/maps/ChernarusPlus-Top/"$VER"/tiles/"$RES"/"$x"/"$y".jpg >> TilesToDownload.txt
			echo "	out=${yFileName}_${xFileName}.jpg" >> TilesToDownload.txt
		elif [ $2 == "sat" ]; then
			echo https://maps.izurvive.com/maps/ChernarusPlus-Sat/"$VER"/tiles/"$RES"/"$x"/"$y".jpg >> TilesToDownload.txt
			echo "	out=${yFileName}_${xFileName}.jpg" >> TilesToDownload.txt
		else
			printf "Please specify satellite / topographic (sat/top) ( ex: ./getmap 4 sat )\n"
			exit;
		fi
	
		
		if [ $RES -ge 5 ]
		then
			if ! (( $x % 10 )) ; then
				if ! (( $y % 10 )) ; then
					printf "[${yFileName}_${xFileName}]"
				fi
			fi
		else
			printf "[${yFileName}_${xFileName}]"
		fi
	
		
	done
	
	if [ $RES -ge 5 ]
	then
		if ! (( $y % 10 )) ; then
			printf "\n"
		fi
	else
		printf "\n"
	fi
	
done



printf "Done.\nInitiating download (this may take a while)\n"

aria2c --dir=./tmp --input-file=TilesToDownload.txt --auto-file-renaming=false --allow-overwrite=false --max-tries=0 --retry-wait=3 --timeout=5 --max-concurrent-downloads=400 --connect-timeout=60 --max-connection-per-server=16 --split=16 --min-split-size=1M --download-result=full

# max-concurrent-downloads (getmap 7 sat) speed tests:
# 300: 1:13
# 500: 1:12
# 600: 1:11
# 800: Errors

printf "Downloads complete!\n"

rm TilesToDownload.txt

cd tmp



# If resolution is 8, saving each tile at 256x256 resolution will cause an error when we concatenate, as the max JPG size is 65500. 
# So, we check if the resolution is 8, and if so resize each tile to 254x254 BEFORE concatenating.
if [ $RES -ge 8 ]
then
	printf "Resizing tiles prior to concatenation to avoid .JPG 65500 max overshoot.\n"
	mogrify -resize 254x254 -format jpg *.jpg
	printf "Resizing complete.\n"
fi

printf "Generating map from tiles. This may take a while.\n"

# This presupposes the user has at least 10 GB of RAM. If they do not, ImageMagick will throw a "memory allocation failed" error.
montage -limit area 0 -limit memory 10GB -limit map 10GB -monitor -mode concatenate *_*.jpg -tile "${TOT}x${TOT}" "DayZ_${3}_Chernarus_Map_${TOT}x${TOT}_${2}.jpg"

printf "\nMap generation complete! Opening image (saved in maps folder)\n"



mv "DayZ_${3}_Chernarus_Map_${TOT}x${TOT}_${2}.jpg" ../maps

cd ../maps

# Check if explorer (Windows) is available and open newly created image. If not, use eog
explorer "DayZ_${3}_Chernarus_Map_${TOT}x${TOT}_${2}.jpg" || eog "DayZ_${3}_Chernarus_Map_${TOT}x${TOT}_${2}.jpg" || xdg-open "DayZ_${3}_Chernarus_Map_${TOT}x${TOT}_${2}.jpg"

cd ..


if [ $RES -ge 8 ]
then
	printf "Since Res [8] was selected, skipping deletion of /tmp directory to avoid re-download if re-run is necessary. Feel free to delete /tmp if you are satisfied with image.\n\n"
else
	rm -r -f tmp
fi
