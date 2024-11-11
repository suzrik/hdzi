#!/bin/bash

# HDZero DVR Utility Script
# Author: iam@suzrik.dev, Team: splitS

# Usage:
#   ./hdzi.sh mount         - Mount the HDZero flash drive.
#   ./hdzi.sh umount        - Unmount the HDZero flash drive.
#   ./hdzi.sh import [arg]  - Import and convert DVR recordings from HDZero.
#                             [arg] can be:
#                             - A single number (e.g., 1) to import one .ts file.
#                             - A range (e.g., 28-30) to import multiple .ts files.
#                             - 'all' to import all available .ts files.
#
# This script is designed to download and convert DsVR recordings from HDZero FPV goggles. It includes commands to:
# 1. Mount the flash drive from the goggles.
# 2. Import and convert DVR recordings (in .ts format) to MP4 format using ffmpeg.
# 3. Unmount the flash drive after import is completed.
#
# Note:
# - Ensure that ffmpeg is installed on your system to convert the files.
# - This utility is specifically for FPV drone HDZero goggles.

MOUNT_POINT="/Volumes/HDZero"

if [ "$1" == "mount" ]; then
    if [ -d "$MOUNT_POINT" ]; then
        echo "Directory $MOUNT_POINT already exists. Flash drive is already mounted."
        exit 0
    fi
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi
    flash_drive=$(diskutil list | grep "external, physical" -A 2 | grep "/dev/disk" | awk '{print $1}')
    if [ -z "$flash_drive" ]; then
        echo "Flash drive not found. Please connect the device and try again."
        exit 1
    else
        flash_drive="${flash_drive}s1"
        echo "Flash drive found: $flash_drive. Mounting to $MOUNT_POINT..."
    fi
    mount -t msdos "$flash_drive" "$MOUNT_POINT"
    if [ $? -eq 0 ]; then
        echo "Flash drive successfully mounted to $MOUNT_POINT."
    else
        echo "Error mounting flash drive."
        exit 1
    fi
elif [ "$1" == "umount" ]; then
    if [ ! -d "$MOUNT_POINT" ]; then
        echo "Directory $MOUNT_POINT does not exist. Flash drive is not mounted."
        exit 0
    fi
    umount "$MOUNT_POINT"
    if [ $? -eq 0 ]; then
        echo "Flash drive successfully unmounted from $MOUNT_POINT."
        rmdir "$MOUNT_POINT"
        if [ $? -ne 0 ]; then
			echo "Error removing directory $MOUNT_POINT."
			exit 1
		fi
    else
        echo "Error unmounting flash drive."
        exit 1
    fi
elif [ "$1" == "import" ]; then
    MOUNT_POINT_MOVIES="$MOUNT_POINT/movies"
    mounted_now=false
    if [ ! -d "$MOUNT_POINT" ]; then
        "$0" mount
        if [ $? -ne 0 ]; then
            echo "Failed to mount flash drive. Cannot proceed with import."
            exit 1
        fi
        mounted_now=true
    fi
    if [ -z "$2" ]; then
        echo "Please provide a number, range, or 'all' as an argument for the import command."
        exit 1
    fi
    if [ "$2" == "all" ]; then
        total_files=$(ls -1 "$MOUNT_POINT_MOVIES"/hdz_*.ts 2>/dev/null | wc -l)
        current_file=0
        for input_file in "$MOUNT_POINT_MOVIES"/hdz_*.ts; do
            if [ -f "$input_file" ]; then
                formatted_number=$(basename "$input_file" .ts | sed 's/hdz_//')
                output_file="./hdz_${formatted_number}.mp4"
                if ! command -v ffmpeg &> /dev/null; then
                    echo "ffmpeg is not installed. Please install ffmpeg and try again."
                    exit 1
                fi
                current_file=$((current_file + 1))
                echo -ne "Converting file $current_file of $total_files: $input_file...\r"
                ffmpeg -i "$input_file" -c:v libx264 -c:a aac "$output_file" -loglevel quiet &
                pid=$!
                while kill -0 $pid 2>/dev/null; do
                    echo -ne "Converting file $current_file of $total_files: $input_file...\r"
                    sleep 1
                done
                echo -ne "\n"
                if [ $? -eq 0 ]; then
                    echo "File successfully converted to $output_file."
                else
                    echo "Error converting file $input_file."
                fi
            fi
        done
    else
        if [[ "$2" =~ ^[0-9]+-[0-9]+$ ]]; then
            start=$(echo "$2" | cut -d'-' -f1)
            end=$(echo "$2" | cut -d'-' -f2)
        else
            start="$2"
            end="$2"
        fi
        total_files=$((end - start + 1))
        current_file=0
        for ((i=start; i<=end; i++)); do
            formatted_number=$(printf "%03d" "$i")
            input_file="$MOUNT_POINT_MOVIES/hdz_${formatted_number}.ts"
            output_file="./hdz_${formatted_number}.mp4"
            if ! command -v ffmpeg &> /dev/null; then
                echo "ffmpeg is not installed. Please install ffmpeg and try again."
                exit 1
            fi
            if [ ! -f "$input_file" ]; then
                echo "Input file $input_file not found. Skipping..."
                continue
            fi
            current_file=$((current_file + 1))
            echo -ne "Converting file $current_file of $total_files: $input_file...\r"
            ffmpeg -i "$input_file" -c:v libx264 -c:a aac "$output_file" -loglevel quiet &
            pid=$!
            while kill -0 $pid 2>/dev/null; do
                echo -ne "Converting file $current_file of $total_files: $input_file...\r"
                sleep 1
            done
            echo -ne "\n"
            if [ $? -eq 0 ]; then
                echo "File successfully converted to $output_file."
            else
                echo "Error converting file $input_file."
            fi
        done
    fi
    if [ "$mounted_now" == true ]; then
        "$0" umount
    fi
else
    echo "Unknown command. Use: mount, umount, or import"
fi
