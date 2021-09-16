#!/bin/bash
echo "Iniciando script para configuração da VM do GNS3 para as aulas de Redes de Computadores e Cibersegurança da UTFPR-C"

echo "Atualizando lista de pacotes Linux da VM"
sudo apt update

echo -e "\n\nInstalar os templates da aula? (s)im ou (n)ão? Padrão Não.\n"
read installTemp

if [ "$installTemp" = "s" ] || [ "$installTemp" = "S" ] || [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    echo -e "\tGerando links das Appliances do GNS3 para a aula"
    sudo ln -s `pwd`/appliances/*.gns3a /usr/local/lib/python3.8/dist-packages/gns3server/appliances/
else
    echo -e "\tPulando a instalação dos templates..."
fi

echo -e "\tInstalar a interface gráfica desktop GNS3-gui? (s)im ou (n)ão? Padrão Não.\n"
echo -e "\tAtenção - Caso você não instale isso, você utilizará apenas a interface Web para usar o GNS3."
read installGui

if [ "$installGui" = "s" ] || [ "$installGui" = "S" ] || [ "$installGui" = "y" ] || [ "$installGui" = "Y" ] ;  then
    echo -e "\tPreparando o SSH do Linux para acessar X11 via SSH"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bkp
    sudo cp configure/sshd_config /etc/ssh/sshd_config

    echo -e "\tInstalando o GNS3-gui, para acessar via SSH"
    sudo apt install gns3-gui
else
    echo -e "\tPulando a instalação do GNS3-gui..."
fi

echo -e "\tInstalar o Cisco PacketTracer? (s)im ou (n)ão? Padrão Não.\n"
read installPT
if [ "$installPT" = "s" ] || [ "$installPT" = "S" ] || [ "$installPT" = "y" ] || [ "$installPT" = "Y" ] ;  then

	echo -e "\t baixando Cisco PacketTracer\n"

	id="1mup__k4iq0PwcBxlE1XWTzmCl30nGomk"
	#fname="CiscoPacketTracer_801_Ubuntu_64bit.deb"
	fname="CiscoPacketTracer_Ubuntu_64bit.deb"

	URL="https://docs.google.com/uc?export=download&id=$id"

	wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate $URL -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$id" -O $fname && rm -rf /tmp/cookies.txt

	echo -e "\n\tInstalando Cisco PacketTracer\n"
	sudo apt install ./CiscoPacketTracer_Ubuntu_64bit.deb

	echo -e "\n\tCisco PacketTracer instalado com sucesso...\n"
else
    echo -e "\tPulando a instalação do Cisco PacketTracer..."
fi

