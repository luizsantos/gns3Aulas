#!/bin/bash

# $0 - idGoogleFile - id of Google Drive File
# $2 - outFile - name of file
eco="/bin/echo -e"
$eco "\nThis program download a file from Google Drive, then you need pass ID from google URL and any name to the downloaded file.\n"
$eco "Example:\n\thttps://drive.google.com/file/d/1-qxMW1D6pPXtaMWVOCA0gw7xqzcc-3YJ/view?usp=sharing"
$eco "\tIn the previus URL, the ID is: 1-qxMW1D6pPXtaMWVOCA0gw7xqzcc-3YJ"
$eco "An example command will be: \n\t$0 1-qxMW1D6pPXtaMWVOCA0gw7xqzcc-3YJ example.txt"

if [[ $# != 2 ]]
then
    $eco "You need type two args, such as:\n\t$0 idGoodleFile outFile"
else
    URL="https://docs.google.com/uc?export=download&id=$1"
    $eco "else"
    wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate $URL -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=$1" -O $2 && rm -rf /tmp/cookies.txt
fi

