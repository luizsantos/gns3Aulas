#!/bin/bash
echo "Iniciando script para configuração da VM do GNS3 para as aulas de Redes de Computadores e Cibersegurança da UTFPR-C"

echo "Atualizando lista de pacotes Linux da VM"
#sudo apt update

echo "Gerando links das Appliances do GNS3 para a aula"
#sudo ln -s appliances/*.gns3a /usr/local/lib/python3.8/dist-packages/gns3server/appliances/

echo "Usar a interface gráfica GNS3-gui para acessar o GNS3?"
echo "Atenção - Caso você não instale isso, você utilizará apenas a interface Web para usar o GNS3"
echo "Instalar o interface gráfica GNS3-gui? (S)im ou (N)ão? Padrão Não"
read installGui

if [ "$installGui" = "Y"] | [ "$installGui" = "S"] | [ "$installGui" = "s"] | [ "$installGui" = "y"]; then

    echo "Preparando o SSH do Linux para acessar X11 via SSH"
    #sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config-bkp
    #sudo cp configure/sshd_config /etc/ssh/sshd_config

    echo "Instalando o GNS3-gui, para acessar via SSH"
    #sudo apt install gns3-gui
else
    echo "Pulando instalão do GNS3-gui..."
fi


