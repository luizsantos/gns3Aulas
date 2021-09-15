#!/bin/bash
echo "Iniciando script para configuração da VM do GNS3 para as aulas de Redes de Computadores e Cibersegurança da UTFPR-C"

echo "Atualizando lista de pacotes Linux da VM"
sudo apt update

echo -e "\n\nInstalar os templates da aula? (s)im ou (n)ão? Padrão Não.\n"
read installTemp

if [ "$installTemp" = "s" ] || [ "$installTemp" = "S" ] || [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    echo "\tGerando links das Appliances do GNS3 para a aula"
    sudo ln -s appliances/*.gns3a /usr/local/lib/python3.8/dist-packages/gns3server/appliances/
else
    echo "\tPulando a instalação dos templates..."
fi

echo -e "\tInstalar a interface gráfica desktop GNS3-gui? (s)im ou (n)ão? Padrão Não.\n"
echo -e "\tAtenção - Caso você não instale isso, você utilizará apenas a interface Web para usar o GNS3."
read installGui

if [ "$installGui" = "s" ] || [ "$installGui" = "S" ] || [ "$installGui" = "y" ] || [ "$installGui" = "Y" ] ;  then
    echo "\tPreparando o SSH do Linux para acessar X11 via SSH"
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bkp
    sudo cp configure/sshd_config /etc/ssh/sshd_config

    echo "\tInstalando o GNS3-gui, para acessar via SSH"
    sudo apt install gns3-gui
else
    echo "\tPulando a instalação do GNS3-gui..."
fi
