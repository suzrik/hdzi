# HDZero DVR Utility

## Overview
The HDZero DVR Utility Script is designed to make it easier to manage and convert DVR recordings from HDZero FPV goggles. These goggles can record in both `.mpg` and `.ts` formats, but `.ts` is more reliable because it won't become corrupted if the goggles are suddenly powered off. Therefore, it's recommended to record in `.ts` format for improved reliability.

However, `.ts` files present two major challenges:

1. **Compatibility Issues**: If the flash drive is formatted within the goggles, it may not be recognized by macOS, making it difficult to access your recordings directly.
2. **Inconvenience for Viewing and Sharing**: `.ts` files are not as user-friendly for playback or sharing with others, which can make handling recorded footage cumbersome.

This script addresses these challenges by automating the process of mounting the flash drive, converting `.ts` files to `.mp4`, and then unmounting the drive when finished. It is tailored specifically for HDZero FPV goggles used in drone flights.

## Features
- **Mount the Flash Drive**: Easily mount the HDZero goggles' flash drive to your macOS system.
- **Import and Convert DVR Recordings**: Convert `.ts` recordings to `.mp4` using `ffmpeg`, which provides better compatibility for playback and sharing.
- **Unmount the Flash Drive**: Safely unmount the flash drive after the import and conversion are complete.

## Installation
1. Clone this repository to your local machine.
   ```sh
   git clone https://github.com/suzrik/hdzi.git
   ```
2. Navigate to the directory and make the script executable.
   ```sh
   cd hdzi
   chmod +x hdzi.sh
   ```
3. Move the script to a directory in your `$PATH` (e.g., `/usr/local/bin`), so it can be used system-wide.
   ```sh
   sudo mv hdzi.sh /usr/local/bin/hdzi
   ```

## Usage
This utility provides three main commands: `mount`, `umount`, and `import`.

### Mount the Flash Drive
Mount the flash drive connected to your macOS system:
```sh
sudo hdzi mount
```
If the flash drive is already mounted, the script will inform you accordingly.

### Unmount the Flash Drive
Unmount the flash drive:
```sh
sudo hdzi umount
```
If the flash drive is not mounted, the script will notify you.

### Import and Convert DVR Recordings
Import and convert `.ts` recordings to `.mp4` format. You can provide different arguments to specify which files to convert:
- **Single File**: Convert a specific file by providing its number.
  ```sh
  sudo hdzi import 1
  ```
  This command will convert the file `hdz_001.ts` to `hdz_001.mp4`.

- **Range of Files**: Convert a range of files by providing the starting and ending numbers.
  ```sh
  hdzi import 28-30
  ```
  This will convert files `hdz_028.ts` through `hdz_030.ts`.

- **All Files**: Convert all available `.ts` files.
  ```sh
  hdzi import all
  ```

During conversion, a progress bar will be displayed to show the status of each file being processed.

## Requirements
- **macOS**: This script is tailored for macOS systems and relies on the `diskutil` command to manage the flash drive.
- **ffmpeg**: Ensure that `ffmpeg` is installed, as it is used to convert the `.ts` files to `.mp4` format. You can install `ffmpeg` via Homebrew:
  ```sh
  brew install ffmpeg
  ```

## Why Use `.ts` Format?
HDZero FPV goggles offer both `.mpg` and `.ts` recording formats. While `.mpg` is easier to handle, `.ts` is far more reliable in case of sudden power loss. This reliability is crucial during drone flights where unexpected power loss can occur. Recording in `.ts` format ensures your footage remains intact, even if the goggles are abruptly disconnected.

However, `.ts` files are not ideal for playback or sharing due to their compatibility issues. This utility script simplifies the conversion process, making `.ts` recordings just as easy to use as `.mp4` files.

- **iam@suzrik.dev**
- Team: **splitS**

Feel free to reach out for any questions or contributions to this project.

## License
This project is licensed under the MIT License.

