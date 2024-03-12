#!/bin/bash

# Esse script é para ser utilizado apenas na VM do GNS3 disponível no site oficial do GNS3. Na dúvida converse com o professor. USE POR SUA CONSTA E RISCO!

# to execute:
# $ sh install.sh
# or
# $ ./install.sh
eco="/bin/echo -e"

# verifica se a configuração do SSH já foi feita ou não -
ssh=0

# hostname
hostname="utfpr2024.cm"

sshConf () {
    if [ $ssh -eq 0 ]; then
        $eco "\nConfiguring SSH from Linux to access X11 (desktop graphical interface)...\n"
        sudo cp -f /etc/ssh/sshd_config /etc/ssh/sshd_config-bkp
        sudo cp -f configure/sshd_config /etc/ssh/sshd_config
        ssh=1
    fi
}

confHost () {
    $eco "\nDo you want change the hostname to $hostname?\n[N/y]\n Just for control.\n"
    read installTemp
    if [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
        $eco "\nConfigure hostname"
        sudo bash -c 'echo '$hostname' > /etc/hostname'
    else
        $eco "\nOK, We won't change hostname!!!\n"
    fi
}

confX () {
    $eco "\nInstaling some X11 packets to run GNS3 gui interface into de VM/host.\n"
    sudo apt install -y i3 ubuntu-drivers-common mesa-utils mesa-utils-extra gnupg numlockx xautolock scrot xorg xserver-xorg xtightvncviewer gns3-gui xfce4-terminal
    
    #sudo apt install -y xserver-xorg-core ubuntu-drivers-common mesa-utils mesa-utils-extra gnupg numlockx xautolock scrot xorg xserver-xorg xtightvncviewer qemu-system-gui

    $eco "\nCopying i3 config file\n"
    sudo mkdir -p ~/.config/i3/
    sudo cp configure/i3-config ~/.config/i3/config

    $eco "\nCopying xinitrc config file\n"
    sudo cp configure/xinitrc ~/.xinitrc

}

confGNS3Menu () {
    $eco "\nConfigure GNS3 menu"
    sudo cp -f /usr/local/bin/gns3welcome.py /usr/local/bin/gns3welcome.py-bkp
    sudo cp -f configure/gns3welcome.py /usr/local/bin/gns3welcome.py
}

confGNS3local () {
    $eco "\nConfigure GNS3 to run on local"
    sudo cp -f /lib/systemd/system/gns3.service /lib/systemd/system/gns3.service-def
    sudo cp -f configure/gns3.service /lib/systemd/system/gns3.service

    # quando instala a interface gráfica desktop o server muda pedindo a autenticação da interface web, esta configuração vai desabilitar isso e por garantia o usuário/senha vai ser gns3.
    $eco "\nConfigure GNS3 server web password and auth"
    sudo cp -f ~/.config/GNS3/2.2/gns3_server.conf ~/.config/GNS3/2.2/gns3_server.conf-bkp
    sudo cp -f configure/gns3_server.conf ~/.config/GNS3/2.2/gns3_server.conf
    sudo chown gns3.gns3 ~/.config/GNS3/2.2/*
}

# $1 - idGoogleFile - id of Google Drive File
# $2 - outFile - name of file
gDriveDown() {
    $eco "\nDownloading $2 from Google Drive\n"

    URL="https://docs.google.com/uc?export=download&id=$1"

    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate $URL -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$1" -O $2 && rm -rf /tmp/cookies.txt

}

# $1 - idGoogleFile - id of Google Drive File
# $2 - outFile - name of file
# $3 - md5sum
gDriveDownVerify() {
$eco "\nVerify if $2 exists and it's correct..."
 if [ -f "$2" ]; then
        $eco "\nFile $2 already exists..."
        # verify if md5sum files
        md5FromFile=`md5sum $2 | awk '{print $1}'`
        if [ "$3" = "$md5FromFile" ]; then
            $eco "\nMD5 from file $2 is correct..."
        else
            $eco "$2 exists but is corrupted! Download..."
            gDriveDown $1 $2
        fi
 else
    $eco "$2 not exists! Download..."
    gDriveDown $1 $2
 fi

}

ciscoPT (){
    $eco "\nDownloading Cisco Packet Tracer...\n"
    # # https://drive.google.com/file/d/1bNmQjB72YIwwA98hl1XRtwnFOvmYzSrK/view?usp=drive_link
    fileCPT="CiscoPacketTracer_Ubuntu_64bit.deb"
    md5_CPT="a052156107f1fba3c2316085827e1223"

	gDriveDown "1bNmQjB72YIwwA98hl1XRtwnFOvmYzSrK" $fileCPT $md5_CPT

	$eco "\nInstall Cisco Packet Trace.\n"
	sudo apt -y install ./CiscoPacketTracer_Ubuntu_64bit.deb

	$eco "\nCisco PacketTracer installed...\n"
}

openBSDimg () {
    $eco "\nDownloading OpenBSD qemu image...\n"
    fileOBSD="obsd2023.qcow2"
    md5OBSD="a315d9eb2e7d07dcd50f379e182651b1"

    gDriveDown "18dazxHHl_wiBLGfyzpM65-RWUvSgvxlJ" $fileOBSD $md5OBSD
 
    sudo mv obsd2023.qcow2 /usr/local/lib/python3.8/dist-packages/gns3server/disks/

    $eco "\nOpenBSD qemu done...\n"

}

appliances () {
    # gerar links para a interface web
    $eco "\nGenerate links to templates/appliances web...\n"
    sudo ln -f -s `pwd`/appliances/*.gns3a /usr/local/lib/python3.8/dist-packages/gns3server/appliances/

    # gerar links para a interface installGui
    #echo "\nGenerate links to templates/appliances gui...\n"
    #ln -f -s `pwd`/appliances/*.gns3a ~/GNS3/appliances/

    # cisco ios
    sudo mkdir /opt/gns3/images/IOS/

    #download file

    file7200="appliances/c7200-adventerprisek9-mz.124-24.T5.bin"
    md5_7200="3c4148f62acf56602ce3b371ebae60c9"

    gDriveDownVerify "1uR5e3nsfgvpRE9bNXSok4rZO4HCkqjET" $file7200 $md5_7200
    sudo ln -f -s `pwd`/appliances/c7200-adventerprisek9-mz.124-24.T5.bin /opt/gns3/images/IOS/
    soma=`md5sum appliances/c7200-adventerprisek9-mz.124-24.T5.bin | awk '{print $1}'`
    sudo bash -c 'echo '$soma' > /opt/gns3/images/IOS/c7200-adventerprisek9-mz.124-24.T5.bin.md5sum'


    file3640="appliances/c3640-a3js-mz.124-25d.image"
    md5_3640="493c4ef6578801d74d715e7d11596964"

    # cisco ios switch (na verdade é um router, mas vamos usar como switch
    gDriveDownVerify "1sKkWOzx0Cl-TvwGBQufpmmQerAYpSznM" $file3640 $md5_3640

    sudo ln -f -s `pwd`/appliances/c3640-a3js-mz.124-25d.image /opt/gns3/images/IOS/
    soma=`md5sum appliances/c3640-a3js-mz.124-25d.image| awk '{print $1}'`
    sudo bash -c 'echo '$soma' > /opt/gns3/images/IOS/c3640-a3js-mz.124-25d.image.image.md5sum'

    # add templates and icons
    $eco "\nCopying icons..."
    sudo cp icons/*.svg /usr/local/lib/python3.8/dist-packages/gns3server/symbols/classic/

    $eco "\nConfigure templates"
    sudo cp configure/gns3_controller.conf ~/.config/GNS3/2.2/
    sudo chown gns3.gns3 ~/.config/GNS3/2.2/*
}

gns3Cli () {
    # install gns3-gui
    sudo apt -y install gns3-gui

    # configurar o SSH para dar acesso via X11
    sshConf

    # install xfce terminal - pequeno e fácil
    sudo apt -y install xfce4-terminal

    # configurar a interface para usar o xfce4-terminal
    $eco "\nConfigure GNS3 gui to use xfce4-terminal"
    sudo cp -f ~/.config/GNS3/2.2/gns3_gui.conf ~/.config/GNS3/2.2/gns3_gui.conf-bkp
    sudo cp -f configure/gns3_gui.conf ~/.config/GNS3/2.2/
    sudo chown gns3.gns3 ~/.config/GNS3/2.2/*
}


# Iniciar script
$eco "\nStarting script to configure GNS3 VM to Computer Network and Cybersecurity classes from UTFPR-CM"

# atualizar linux
$eco "\nUpdating Ubuntu mirrors"
sudo apt update

# configurar nome do host
confHost

# configurar menu do GNS3 server da VM
confGNS3Menu

#instalar appliances
$eco "\n\nInstall GNS3 templates/appliances? \n[N/y]\n"
read installTemp
if [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    $eco "\nInstalling templates/appliances to Computer Network and Cybersecurity classes.\n"
    appliances
else
    $eco "\nInstalling templates/appliances canceled!!!\n"
fi

#instalar interface gráfica GNS3
$eco "\nInstall GNS3-gui to use graphical interface desktop (to access using SSH)?"
$eco "\n Attention: If you not install it, you'll use only web interface do the GNS3 access.\n"
$eco "Install? \n[N/y]\n"
read installGui

if [ "$installGui" = "y" ] || [ "$installGui" = "Y" ] ;  then
    $eco "\nInstalling GNS3-gui.\n"
    gns3Cli
    sshConf
    #configurar o GNS3 para executar localmente... caso contrário não salva
    confGNS3local
else
    $eco "\nInstalling GNS3-gui canceled!!!\n"
fi

# instalar ambiente gráfico para acessar o GNS3 gui direto via VM - não só via sshConf
$eco "\nInstall X/i3 to use ghraphical interface into de VM (not just from SSH connection)?"
$eco "\n Attention: If you don't install it, you'll use only remote connection access (SSH or Web).\n"
$eco "Install? \n[N/y]\n"
read installX

if [ "$installX" = "y" ] || [ "$installX" = "Y" ] ;  then
    $eco "\nInstalling X/i3.\n"
    confX
else
    $eco "\nInstalling X/i3 canceled!!!\n"
fi

# instalar imagem do OpenBSD do qemu
$eco "\nInstall/copy OpenBSD image to use with Qemu\n"
$eco "Install? \n[N/y]\n"
read installOBSD

if [ "$installOBSD" = "y" ] || [ "$installOBSD" = "Y" ] ;  then
    $eco "\nInstalling/copying OpenBSD image.\n"
    openBSDimg
else
    $eco "\nInstalling/copying OpenBSD image canceled!!!\n"
fi

#instalar cisto packet tracer
$eco "\nInstall Cisco Packet Tracer (to access using SSH)? \n[N\y]\n"
read installPT
if [ "$installPT" = "s" ] || [ "$installPT" = "S" ] || [ "$installPT" = "y" ] || [ "$installPT" = "Y" ] ;  then
    $eco "\nInstalling Cisco Packet Tracer.\n"
    ciscoPT
    sshConf
else
    $eco "\nInstalling Cisco Packet Tracer canceled!!!\n"
fi

$eco "\nInstall vim-tiny to professor :-p"
sudo apt install -y vim-tiny
cp /usr/share/vim/vimrc ~/.vimrc

# finalização
$eco "\n\nFinished..."
$eco "\n To menu and hostname works, please reboot system!!!"

