#!/bin/bash
# folder upload script with gpg encryption support
# $1 = folder path that you will feed into tar, $2 = password, $3 = webhook url (optional

processes=4
filesize_per_process=$((256*1024*1024+256))
uploadapiurl="https://example.com/upload"

cat << EOF > /tmp/tempbitte114514.sh
function formdata_pipeline(){
    # local filename="wiebitte114514.txt"
    local filename="\$1"
    local mimetype="text/plain"
    echo -n $'-----------------------------11451419198108932147483647\r\nContent-Disposition: form-data; name="file"; filename="'"\$filename"'"'
    echo -n $'\r\nContent-Type: text/plain'$'\r\n\r\n'
    cat -
    echo -n $'\r\n-----------------------------11451419198108932147483647--\r\n'
}

function upload(){ # \$1 = part no
    local url=""
    local resp=""
    resp=\`curl '$uploadapiurl' -X POST -H 'Content-Type: multipart/form-data; boundary=---------------------------11451419198108932147483647' --data-binary "@-"\`
    if [ \`echo "\$resp" | grep -c "http"\` -eq 0 ]
    then
        echo -e "\e[31m\$resp\e[0m" 1>&2
    else
        echo -e "\e[32m\$resp\e[0m" 1>&2
    fi
    url=\`echo "\$resp" | sed 's/?.*//g;s/"/\n/g' | grep http\`
    echo "\$1|\$url"
}

password="\$1"
cat - > /tmp/barbruh114514
echo -e "\e[36mupload batch started\e[0m" 1>&2
size=\`ls -l /tmp/barbruh114514 | cut -d' ' -f5\`
sizeperpart=$filesize_per_process
partno=0

function upload_subprocess(){ # \$1 = part no but started at 0, \$2 = offset
    local partno="\$1"
    local offset="\$2"
    local checksum=\`tail -c +\$offset /tmp/barbruh114514 | head -c \$sizeperpart | sha512sum | cut -f1 -d' '\`
    local link=""
    
    while [ \`echo "\$link" | grep -c "http"\` -eq 0 ]
    do
        link=\`tail -c +\$offset /tmp/barbruh114514 | head -c \$sizeperpart | gpg --batch -c --cipher-algo AES256 --passphrase "\$password" | formdata_pipeline "\$checksum.txt" | upload \$partno\`
    done
    echo "\$link|\$checksum"
}

starttime=\`date +%s%N\`

time for offset in \`seq 1 \$sizeperpart \$size\`
do
    let partno++
    echo -e "\e[36mpart \$partno started upload\e[0m" 1>&2
    # [ \$((partno%5)) -eq 0 ] && sleep 1
    sleep 1
    { 
    upload_subprocess \$partno \$offset
    } &
done | sort -n | cut -d'|' -f2-
wait

finaltime=\`date +%s%N\`
usedtime=`awk -v x=$finaltime -v y=$starttime 'BEGIN{printf "%.3f",(x-y)/1000000000}'`

echo -e "\e[36mtime used: \`awk -v x=\$finaltime -v y=\$starttime 'BEGIN{printf "%.3f",(x-y)/1000000000}'\` sec(s)\e[0m" 1>&2

rm /tmp/barbruh114514 -f

echo -e "\e[36mupload batch ended\e[0m" 1>&2

EOF

function dir_upload() { # $1 = dirname, $2 = password
    tar -cv "$1" | split -b $((filesize_per_process*processes)) --filter "cat | bash /tmp/tempbitte114514.sh \"$2\" >> /tmp/wiebitte114514.txt; sleep 1"
}

cat /dev/null > /tmp/wiebitte114514.txt
dir_upload "$1" "$2"
finallink=`cat /tmp/wiebitte114514.txt | bash /tmp/tempbitte114514.sh "$2"`
finallink2=`echo "$finallink" | cut -d\| -f1`
size=`du -b --max-depth=0 "$1" | awk '{ print $1 }'`
[ "$3" ] && webhookurl="$3"
curl -k --connect-timeout 20 --retry 20 --retry-delay 0 --retry-max-time 40 -F "payload_json={\"content\":\"encrypted link of **$1** ($size bytes): $finallink2\",\"username\":\"EulaAAAAAAAA\",\"avatar_url\":\"https://cdn.discordapp.com/attachments/524633631012945922/937727442171342868/eulaAAAAAAAA.png\"}" "$webhookurl" # || 
echo "encrypted link of $1 ($size bytes): $finallink2" >> ~/localdb.txt
echo "$1|$size|$finallink"
echo "$1|$size|$finallink" >> results.txt
rm /tmp/wiebitte114514.txt /tmp/tempbitte114514.sh -f
