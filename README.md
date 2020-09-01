# keepass-usb-portable
Collection of scripts and file system structure for mobile USB KeePassXC usage

Supported platforms: Windows 32 and 64 bit, Linux 64 bit(Due to lack of 32 bit AppImage package for KeePassXC on linux).

## Installation

Install this suit by simply copying all contents of the directory in the desirec location(e.g. a USB storage device)

## Usage

The scripts assume that the synced directory is called DBs in the scripts location. A key file for KeePassXC can reside somewhere in the script directory.

Both Linux and Windows versions provide 4 scripts:

### init

Initializes Syncthing. It is capable of creating all the necessary config files for Syncthing and creating a password on first time usage. To shutdown Syncthing press CTRL+C but don't terminate the batch job if the prompt appears. The script performs clean up tasks at the end. It cleans the DBs directory and encrypts the Syncthing config. This way the only way to obtain the password database is to input the decryption key.

### run_kpxc

This script simply runs KeePassXC.

### change_password

This script provides the capability to change the password for the encrypted config. Run only if Syncthing is not working.

### reset_config

THis is a simple cleanup script to delete all Syncthing config. After this step the init script will repeat the first run configuration steps.

## Notes:

For correct syncing functionality all other devices running Syncthing need to set "ignore delete"-flag on the right directory.

## Dependencies

This solution makes use of the following utilities:

### Syncthing

Syncthing is a MPL 2.0 licensed peer-2-peer synchronisation utility.

Version: 1.8.0

Get the code from: https://github.com/syncthing/syncthing

### KeePassXC

KeePassXC is a GPL 3.0 licensed password manager.

Version: 2.6.1

Get the code from: https://github.com/keepassxreboot/keepassxc

### AESCrypt

AESCrypt is an open source utility for AES encryption. It is licensed as freeware in exception to some files which are licensed under the GPL 2.0. See license notes in AESCrypt directory.

Version: 3.10

Get the code from: https://www.aescrypt.com/
