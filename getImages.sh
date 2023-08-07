#!/bin/bash

# to execute:
# $ sh install.sh
# or
# $ ./install.sh
eco="/bin/echo -e"

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
    # https://drive.google.com/file/d/1bNmQjB72YIwwA98hl1XRtwnFOvmYzSrK/view?usp=drive_link
    fileCPT="CiscoPacketTracer_821_Ubuntu_64bit.deb"
    md5_CPT="a052156107f1fba3c2316085827e1223"

	gDriveDown "1bNmQjB72YIwwA98hl1XRtwnFOvmYzSrK" $fileCPT $md5_CPT

	$eco "\nCisco PacketTracer installed...\n"
}

openBSDimg () {
    $eco "\nDownloading OpenBSD qemu image...\n"
    fileOBSD="obsd2023.qcow2"
    md5OBSD="a315d9eb2e7d07dcd50f379e182651b1"

    gDriveDown "18dazxHHl_wiBLGfyzpM65-RWUvSgvxlJ" $fileOBSD $md5OBSD
 
    $eco "\nOpenBSD qemu done...\n"

}

appliances () {
    #download file

    file7200="appliances/c7200-adventerprisek9-mz.124-24.T5.bin"
    md5_7200="3c4148f62acf56602ce3b371ebae60c9"

    gDriveDownVerify "1uR5e3nsfgvpRE9bNXSok4rZO4HCkqjET" $file7200 $md5_7200
    soma=`md5sum appliances/c7200-adventerprisek9-mz.124-24.T5.bin | awk '{print $1}'`
    sudo bash -c 'echo '$soma' > appliances/c7200-adventerprisek9-mz.124-24.T5.bin.md5sum'


    file3640="appliances/c3640-a3js-mz.124-25d.image"
    md5_3640="493c4ef6578801d74d715e7d11596964"

    # cisco ios switch (na verdade é um router, mas vamos usar como switch
    gDriveDownVerify "1sKkWOzx0Cl-TvwGBQufpmmQerAYpSznM" $file3640 $md5_3640

    soma=`md5sum appliances/c3640-a3js-mz.124-25d.image| awk '{print $1}'`
    sudo bash -c 'echo '$soma' > appliances/c3640-a3js-mz.124-25d.image.md5sum'
}

# Iniciar script
$eco "\nStarting script to configure GNS3 VM to Computer Network and Cybersecurity classes from UTFPR-CM"

#instalar appliances
$eco "\n\nDownloading GNS3 templates/appliances? \n[N/y]\n"
read installTemp
if [ "$installTemp" = "y" ] || [ "$installTemp" = "Y" ] ;  then
    $eco "\nDownloading templates/appliances to Computer Network and Cybersecurity classes.\n"
    appliances
else
    $eco "\nDownloaded templates/appliances canceled!!!\n"
fi

# instalar imagem do OpenBSD do qemu
$eco "\nDownload/copy OpenBSD image to use with Qemu\n"
$eco "Install? \n[N/y]\n"
read installOBSD

if [ "$installOBSD" = "y" ] || [ "$installOBSD" = "Y" ] ;  then
    $eco "\nDownloading/copying OpenBSD image.\n"
    openBSDimg
else
    $eco "\nDownloaded/copying OpenBSD image canceled!!!\n"
fi

#instalar cisto packet tracer
$eco "\nDownload Cisco Packet Tracer (to access using SSH)? \n[N\y]\n"
read installPT
if [ "$installPT" = "s" ] || [ "$installPT" = "S" ] || [ "$installPT" = "y" ] || [ "$installPT" = "Y" ] ;  then
    $eco "\nDownload Cisco Packet Tracer.\n"
    ciscoPT
else
    $eco "\nDownload Cisco Packet Tracer canceled!!!\n"
fi


# finalização
$eco "\n\nFinished..."

