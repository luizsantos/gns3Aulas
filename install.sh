#!/bin/bash

# verifica se a configuração do SSH já foi feita ou não
ssh=0

# hostname
hostname="utfpr.cm"

sshConf () {
    if [ $ssh -eq 0 ]; then
        echo "\nConfiguring SSH from Linux to access X11 (desktop graphical interface)...\n"
        sudo cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config-bkp
        sudo cp -f configure/sshd_config /etc/ssh/sshd_config
        ssh=1
    fi
}

confHost () {
    echo "\nConfigure hostname"
    sudo echo $hostname > /etc/hostname
}

confGNS3Menu () {
    echo "\nConfigure GNS3 menu"
    sudo cp -f /usr/local/bin/gns3welcome.py /usr/local/bin/gns3welcome.py-bkp
    sudo cp -f configure/gns3welcome.py /usr/local/bin/gns3welcome.py
}

confGNS3local () {
    echo "\nConfigure GNS3 to run on local"
    sudo cp -f /lib/systemd/system/gns3.service /lib/systemd/system/gns3.service-def
    sudo cp -f configure/gns3.service /lib/systemd/system/gns3.service

    # quando instala a interface gráfica desktop o server muda pedindo a autenticação da interface web, esta configuração vai desabilitar isso e por garantia o usuário/senha vai ser gns3.
    echo "\nConfigure GNS3 server web password and auth"
    sudo cp -f /home/gns3/.config/GNS3/2.2/gns3_server.conf /home/gns3/.config/GNS3/2.2/gns3_server.conf-bkp
    sudo cp -f configure/gns3_server.conf /home/gns3/.config/GNS3/2.2/gns3_server.conf
}


ciscoPT (){
    echo "\nDownloading Cisco Packet Tracer...\n"

	id="1mup__k4iq0PwcBxlE1XWTzmCl30nGomk"
	#fname="CiscoPacketTracer_801_Ubuntu_64bit.deb"
	fname="CiscoPacketTracer_Ubuntu_64bit.deb"

	URL="https://docs.google.com/uc?export=download&id=$id"

	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate $URL -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$id" -O $fname && rm -rf /tmp/cookies.txt

	echo "\nInstall Cisco Packet Trace.\n"
	sudo apt install ./CiscoPacketTracer_Ubuntu_64bit.deb

	echo "\nCisco PacketTracer installed...\n"
}

appliances () {
    # gerar links para a interface web
    echo "\nGenerate links to templates/appliances web...\n"
    sudo ln -f -s `pwd`/appliances/*.gns3a /usr/local/lib/python3.8/dist-packages/gns3server/appliances/

    # gerar links para a interface installGui
    #echo "\nGenerate links to templates/appliances gui...\n"
    #ln -f -s `pwd`/appliances/*.gns3a /home/gns3/GNS3/appliances/

    # cisco ios
    sudo ln -f -s `pwd`/appliances/c7200-adventerprisek9-mz.124-24.T5.bin /opt/gns3/images/IOS/
    sudo md5sum appliances/c7200-adventerprisek9-mz.124-24.T5.bin | cut -d' ' -f1 > /opt/gns3/images/IOS/c7200-adventerprisek9-mz.124-24.T5.bin.md5sum
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

# configurar nome do host
confHost

# configurar menu do GNS3 server da VM
confGNS3Menu

#instalar appliances
echo "\n\nInstall GNS3 templates/appliances? \n[N/y]\n"
read installTemp
if [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    echo "\nInstalling templates/appliances to Computer Network and Cybersecurity classes.\n"
    appliances
else
    echo "\nInstalling templates/appliances canceled!!!\n"
fi

#instalar interface gráfica GNS3
echo "\nInstall GNS3-gui to use graphical interface desktop (to access using SSH)?"
echo "\n Attention: If you not install it, you'll use only web interface do the GNS3 access.\n"
echo "Install? \n[N/y]\n"
read installGui

if [ "$installGui" = "y" ] || [ "$installGui" = "Y" ] ;  then
    echo "\nInstalling GNS3-gui.\n"
    gns3Cli
    sshConf
    #configurar o GNS3 para executar localmente... caso contrário não salva
    confGNS3local
else
    echo "\nInstalling GNS3-gui canceled!!!\n"
fi

#instalar cisto packet tracer
echo "\nInstall Cisco Packet Tracer (to access using SSH)? \n[N\y]\n"
read installPT
if [ "$installPT" = "s" ] || [ "$installPT" = "S" ] || [ "$installPT" = "y" ] || [ "$installPT" = "Y" ] ;  then
    echo "\nInstalling Cisco Packet Tracer.\n"
    ciscoPT
    sshConf
else
    echo "\nInstalling Cisco Packet Tracer canceled!!!\n"
fi

# finalização
echo "\n\nFinish..."
echo "\n To menu and hostname works, please reboot system!!!"

