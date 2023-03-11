#!/bin/bash

# instalation config ---------------------------------------------------
# New user username and passwordf
username="fic"
password="SuperSecretPassword1."
#instalation config

#install mate desktop
installMateDesktop=1

#install VNC client for desktop selected
installVnc=1

#auto run vnc
autoRunVnc=1
vncServerParameters="--geometry 1800x900 :1"

#select browser(s) to install
installChrome=1
installFirefox=1

#instal midnight commander
installMc=1

#Config end script start --------------------------------------

if [ ! -f phase1.mark ]; then
	echo "phase 1 ----------------------------------------------------------"
	cp .bashrc .bashrc.tempBack
	echo "\n\n ./installAll.sh \n" >>.bashrc
	sudo apt update
	sudo apt -y upgrade
	touch phase1.mark
	echo "phase 1 END PLS reboot--------------------------------------------"
	exit 0
fi

if [ ! -f phase2.mark ]; then
	echo "phase 2 ----------------------------------------------------------"
	if [ $installMateDesktop -eq 1 ]; then
		sudo apt -y install ubuntu-mate-desktop
		if [ $installVnc -eq 1 ]; then
			sudo apt -y install tightvncserver
		fi
		sudo apt update
		sudo apt -y upgrade
	fi
	touch phase2.mark
	echo "phase 2 END PLS reboot--------------------------------------------"
	exit 0
fi

if [ ! -f phase3.mark ]; then
	echo "phase 3 ----------------------------------------------------------"
	echo "Creating new user $username"
	sudo adduser $username <<- \
____
	$password
	$password








____
	sudo usermod -aG sudo $username
#	need to define userdir because ~ does not expand othervise
	userdir=$(eval echo "~$username")
	sudo cp ./installAll.sh $userdir
	sudo cp .bashrc.tempBack .bashrc
	sudo -u $username \
		cp $userdir/.bashrc $userdir/.bashrc.tempBack
	sudo -u $username \
		echo "\n\n ./installAll.sh \n" >> $userdir/.bashrc
	sudo -u $username touch $userdir/phase1.mark
	sudo -u $username touch $userdir/phase2.mark
	sudo -u $username touch $userdir/phase3.mark
	sudo chown $username.$username $userdir/*
	rm phase1.mark
	rm phase2.mark
	# rm installAll.sh
	echo "phase 3 END PLS reboot  AS $username ----------------------------------"
	exit 0
fi

if [ ! -f phase4.mark ]; then
	echo "phase 4 ----------------------------------------------------------"
	tightvncserver :1
	sleep 2
	tightvncserver -kill :1
	sleep 2
	cd .vnc
	mv xstartup xstartup.bak
	echo "#!/bin/bash \n" >xstartup
	echo "\n" >>xstartup
	echo "exec /usr/bin/start-mate-session & \n">>xstartup
	cd ~
	sudo apt update
	sudo apt -y upgrade
	touch phase4.mark
	echo "phase 4 END PLS reboot  AS $username ----------------------------------"
	exit 0
fi

if [ ! -f phase5.mark ]; then
	echo "phase 5 ----------------------------------------------------------"
	if [ $installChrome -eq 1 ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo apt install -y ./google-chrome-stable_current_amd64.deb
	fi
	if [ $installFirefox -eq 1 ]; then
		sudo apt purge firefox
		sudo apt remove --autoremove firefox
		sudo snap remove --purge firefox
		sudo add-apt-repository ppa:mozillateam/ppa

		sudo cat >>/etc/apt/preferences.d/99mozillateamppa <<- \
_______________________________________
	Package: firefox*
	Pin: release o=LP-PPA-mozillateam
	Pin-Priority: 501
	
	Package: firefox*
	Pin: release o=Ubuntu
	Pin-Priority: -1
_______________________________________
		echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' \
		| sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
		sudo apt update
		sudo apt install -t 'o=LP-PPA-mozillateam' firefox
	fi
	if [ $installMc -eq 1 ]; then
		wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
		sudo apt install -y mc
	fi
	touch phase5.mark
	echo "phase 5 END PLS reboot  AS $username ----------------------------------"
#	exit 0
fi

cp .bashrc.tempBack .bashrc
rm phase1.mark
rm phase2.mark
rm phase3.mark
rm phase4.mark
rm phase5.mark
#rm inbstallAll.sh

echo "Install END ----------------------------------------------------------"

