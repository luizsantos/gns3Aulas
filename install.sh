#!/bin/bash

# verifica se a configuração do SSH já foi feita ou não
ssh=0

sshConf () {
    if [$ssh -eq 0]; then
        echo "\n\tConfiguring SSH from Linux to access X11 (desktop graphical interface)...\n"
        sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bkp
        sudo cp configure/sshd_config /etc/ssh/sshd_config
        $ssh=1
    fi
}


ciscoPT (){
    echo "\n\tDownloading Cisco Packet Tracer...\n"

	id="1mup__k4iq0PwcBxlE1XWTzmCl30nGomk"
	#fname="CiscoPacketTracer_801_Ubuntu_64bit.deb"
	fname="CiscoPacketTracer_Ubuntu_64bit.deb"

	URL="https://docs.google.com/uc?export=download&id=$id"

	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate $URL -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$id" -O $fname && rm -rf /tmp/cookies.txt

	echo "\n\tInstall Cisco Packet Trace.\n"
	sudo apt install ./CiscoPacketTracer_Ubuntu_64bit.deb

	echo "\n\tCisco PacketTracer installed...\n"
}

appliances () {
    echo "\tGenerate links to templates/appliances...\n"
    sudo ln -f -s `pwd`/appliances/*.gns3a /usr/local/lib/python3.8/dist-packages/gns3server/appliances/
}

gns3Cli () {
    sudo apt install gns3-gui
    sshConf
}


# Iniciar script
echo "\nStarting script to configure GNS3 VM to Computer Network and Cybersecurity classes from UTFPR-CM"

# atualizar linux
echo "\nUpdating Ubuntu mirrors"
sudo apt update

#instalar appliances
echo "\n\nInstall GNS3 templates/appliances? \n[N/y]\n"
read installTemp
if [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    echo "\tInstalling templates/appliances to Computer Network and Cybersecurity classes.\n"
    appliances
else
    echo "\tInstalling templates/appliances canceled!!!\n"
fi

#instalar interface gráfica GNS3
echo "\nInstall GNS3-gui to use graphical interface desktop (to access using SSH)?"
echo "\tAttention: If you not install it, you'll use only web interface do the GNS3 access.\n"
echo "Install? \n[N/y]\n"
read installGui

if [ "$installGui" = "y" ] || [ "$installGui" = "Y" ] ;  then
    echo "\tInstalling GNS3-gui.\n"
    gns3Cli
    sshConf
else
    echo "\tInstalling GNS3-gui canceled!!!\n"
fi

#instalar cisto packet tracer
echo "\nInstall Cisco Packet Tracer (to access using SSH)? \n[N\y]\n"
read installPT
if [ "$installPT" = "s" ] || [ "$installPT" = "S" ] || [ "$installPT" = "y" ] || [ "$installPT" = "Y" ] ;  then
    echo "\tInstalling Cisco Packet Tracer.\n"
    ciscoPT
    sshConf
else
    echo "\tInstalling Cisco Packet Tracer canceled!!!\n"
fi

