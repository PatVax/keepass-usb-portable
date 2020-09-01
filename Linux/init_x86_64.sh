cd ${0%/*}

printf "This script is part of keepass-usb-portable GitHub repository\n" 
printf "which is released under the MIT License.\n" 
printf "See file License in the directory containing this script\n" 
printf "or go to https://github.com/PatVax/keepass-usb-portable for full detail.\n" 

#In case a Syncthing config already exist
if [ -e portable_appdata/Syncthing/config.xml.aes ]; then

	# Read password
	pass=""
	stty -echo
	printf "Enter password: "
	read pass
	stty echo
	printf "\n"

	# Decrypt Syncthing config
	./x86_64/AESCrypt/aescrypt -p "${pass}" -d portable_appdata/Syncthing/config.xml.aes

#Otherwise
else

	printf "First run. Creating config files...\n"

	#Generate default Syncthing config
	x86_64/Syncthing/syncthing -generate=portable_appdata/Syncthing
	
	printf "Removing default Sync directory from the Config...\n"
	
	state=0
	
	cat portable_appdata/Syncthing/config.xml | while read line 
	do	
		case $state in
		0)
			case $line in *"<folder"*">")
				state="1"
			;;
			*)
				echo "${line}" >> portable_appdata/Syncthing/config_new.xml
			;;esac
		;;
		1)
			case $line in *"</folder>")
				state="0"
			;;esac
		;;esac
	done

	mv -f portable_appdata/Syncthing/config_new.xml portable_appdata/Syncthing/config.xml
	
	printf "Done.\nPlease specify a password:\n"
	
	# Create password
	pass=""
	stty -echo
	printf "Enter password: "
	read pass
	stty echo
	printf "\n"
	
	pass_repeat=""
	stty -echo
	printf "Repeat password: "
	read pass_repeat
	stty echo
	printf "\n"
	
	if [ ! "${pass}" = "${pass_repeat}" ]; then 
	printf "Passwords did not match. Exiting...\n"
		rm portable_appdata/Syncthing/*
		read -rs -n 1 -p "Press any key to continue..."; 
		printf "\n"
		exit
	fi
	
fi

# Continue if decryption was succesfull
if [ -e portable_appdata/Syncthing/config.xml ]; then
	
	# Delete encrypted Syncthing config
	rm portable_appdata/Syncthing/config.xml.aes

	# Reset Syncthing Database to avoid syncing conflicts
	./x86_64/Syncthing/syncthing -home=portable_appdata/Syncthing/ -reset-database
	# Run Syncthing. Stop by using CTRL+C command
	./x86_64/Syncthing/syncthing -home=portable_appdata/Syncthing/ -reset-deltas -no-browser

	# Attempt to encrypt Syncthing config with the original password
	./x86_64/AESCrypt/aescrypt -p "${pass}" -e portable_appdata/Syncthing/config.xml
	
	# Error handling if Syncthing config couldn't be encrypted with the original password
	if [ ! -e portable_appdata/Syncthing/config.xml.aes ]; then
		printf "Error: Password couldn't be set. Proceed to manual input...\n"
		
		# Attempt encryption with manual password input and repeat if failed
		while [ ! -e portable_appdata/Syncthing/config.xml.aes ]; do 
		
			./x86_64/AESCrypt/aescrypt -e portable_appdata/Syncthing/config.xml
			
		done
	fi
	# Delete the Syncthing config and synced KeePass database
	rm portable_appdata/Syncthing/config.xml
	rm DBs/*

else 

	printf "Wrong password. Exiting...\n"
	
fi

read -rs -n 1 -p "Press any key to continue...";
printf "\n"