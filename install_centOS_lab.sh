#!/bin/bash

# to execute:
# $ sh install.sh
# or
# $ ./install.sh
eco="/bin/echo -e"
dirUsu="/home/aluno"

confGNS3local () {
    $eco "\nConfigure GNS3 to run on local"
#    sudo cp -f /lib/systemd/system/gns3.service /lib/systemd/system/gns3.service-def
#    sudo cp -f configure/gns3.service /lib/systemd/system/gns3.service

    # quando instala a interface gráfica desktop o server muda pedindo a autenticação da interface web, esta configuração vai desabilitar isso e por garantia o usuário/senha vai ser gns3.
    #$eco "\nConfigure GNS3 server web password and auth"
    #sudo mkdir -p $dirUsu/.config/GNS3/2.2/
    #sudo cp -f $dirUsu/.config/GNS3/2.2/gns3_server.conf $dirUsu/.config/GNS3/2.2/gns3_server.conf-bkp
    #sudo cp -f configure/gns3_server.conf $dirUsu/.config/GNS3/2.2/gns3_server.conf
    #sudo chown -R aluno.aluno $dirUsu/.config/GNS3/2.2/
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

appliances () {
    # gerar links para a interface web
    $eco "\nGenerate links to templates/appliances web...\n"
    sudo ln -f -s `pwd`/appliances/*.gns3a /usr/local/lib/python3.10/dist-packages/gns3server/appliances/

    # gerar links para a interface installGui
    #echo "\nGenerate links to templates/appliances gui...\n"
    #ln -f -s `pwd`/appliances/*.gns3a ~/GNS3/appliances/

    # cisco ios
    dirImg="/opt/gns3/images/IOS/"
    sudo mkdir -p $dirImg 

    #download file

    file7200="c7200-adventerprisek9-mz.124-24.T5.bin"
    md5_7200="3c4148f62acf56602ce3b371ebae60c9"

    #gDriveDownVerify "1uR5e3nsfgvpRE9bNXSok4rZO4HCkqjET" $dirImg$file7200 $dirImg$md5_7200
    #sudo mv `pwd`/appliances/c7200-adventerprisek9-mz.124-24.T5.bin /opt/gns3/images/IOS/
    soma=`md5sum $dirImg/c7200-adventerprisek9-mz.124-24.T5.bin | awk '{print $1}'`
    echo $soma do arquivo 7200
    sudo bash -c 'echo '$soma' > /opt/gns3/images/IOS/c7200-adventerprisek9-mz.124-24.T5.bin.md5sum'


    file3640="c3640-a3js-mz.124-25d.image"
    md5_3640="493c4ef6578801d74d715e7d11596964"

    # cisco ios switch (na verdade é um router, mas vamos usar como switch
    gDriveDownVerify "1sKkWOzx0Cl-TvwGBQufpmmQerAYpSznM" $dirImg$file3640 $dirImag$md5_3640

    #sudo mv `pwd`/appliances/c3640-a3js-mz.124-25d.image /opt/gns3/images/IOS/
    soma=`md5sum $dirImg/c3640-a3js-mz.124-25d.image| awk '{print $1}'`
    sudo bash -c 'echo '$soma' > $dirImg/c3640-a3js-mz.124-25d.image.image.md5sum'

    # copying imagens to user
    sudo mkdir -p $dirUsu/GNS3/images/IOS/
    sudo ln -f -s /opt/gns3/images/IOS/* $dirUsu/GNS3/images/IOS/

    # add templates and icons
    $eco "\nCopying icons..."
    sudo cp icons/routerLinux.svg /usr/local/lib/python3.10/dist-packages/gns3server/symbols/classic/

    $eco "\nConfigure templates - copynt controller"
    sudo mkdir -p $dirUsu/.config/GNS3/2.2/
    sudo cp configure/*.conf $dirUsu/.config/GNS3/2.2/
    sudo chown -R aluno.aluno $dirUsu/.config/GNS3/2.2/
}


# Iniciar script
$eco "\nConfigure GNS3 to the computer network and Cybersecurity labs on CentOS from UTFPR-CM labs"

#instalar appliances
$eco "\n\nInstall GNS3 templates/appliances? \n[N/y]\n"
read installTemp
if [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    $eco "\nInstalling templates/appliances to Computer Network and Cybersecurity classes.\n"
    appliances
    #configurar o GNS3 para executar localmente... caso contrário não salva
    confGNS3local
else
    $eco "\nInstalling templates/appliances canceled!!!\n"
fi


#instalar cisto packet tracer
$eco "\nInstall Cisco Packet Tracer (to access using SSH)? \n[N\y]\n"
#read installPT
#if [ "$installPT" = "s" ] || [ "$installPT" = "S" ] || [ "$installPT" = "y" ] || [ "$installPT" = "Y" ] ;  then
#    $eco "\nInstalling Cisco Packet Tracer.\n"
#    # atualizar linux
#    $eco "\nUpdating Ubuntu mirrors"
#    sudo apt update
#    ciscoPT
#else
#    $eco "\nInstalling Cisco Packet Tracer canceled!!!\n"
#fi

$eco "\nmod aluno"
sudo chown -R aluno:aluno /home/aluno

# finalização
$eco "\n\nFinished..."
