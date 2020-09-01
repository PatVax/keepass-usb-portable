# This script is part of keepass-usb-portable GitHub repository which is released under the MIT License.
# See file License in the directory containing this script or go to https://github.com/PatVax/keepass-usb-portable for full detail.

cd ${0%/*}

if [ ! -e portable_appdata/Syncthing/config.xml.aes ]; then
	printf "No Syncthing config found. Use the init script to initialize the config. Exiting...\n"
	read -rs -n 1 -p "Press any key to continue..."; 
	printf "\n"
	exit
fi

# Read old password
pass_old=""
stty -echo
printf "Enter old password: "
read pass_old
stty echo
printf "\n"

# Try to decrypt Syncthing config
./x86_64/AESCrypt/aescrypt -p "${pass_old}" -d portable_appdata/Syncthing/config.xml.aes

# Check if the password was correct
if [ ! -e portable_appdata/Syncthing/config.xml ]; then
	printf "Wrong password. Exiting...\n"
	read -rs -n 1 -p "Press any key to continue..."; 
	printf "\n"
	exit
fi

pass_new="pass_new"
pass_repeat="pass_repeat"

# Read password
while test 0;
do

	# Read new password
	stty -echo
	printf "Enter new password: "
	read pass_new
	stty echo
	printf "\n"

	# Read repeat new password
	stty -echo
	printf "Repeat new password: "
	read pass_repeat
	stty echo
	printf "\n"
	
	# End execution if passwords match
	if [ $pass_new = $pass_repeat ]; then
		./x86_64/AESCrypt/aescrypt -p "${pass_new}" -e portable_appdata/Syncthing/config.xml
		rm portable_appdata/Syncthing/config.xml
		printf "Password changed successfully.\n"
		read -rs -n 1 -p "Press any key to continue..."; 
		printf "\n"
		exit
	fi
	
	printf "Passwords did not match. Repeat.\n"
	
done