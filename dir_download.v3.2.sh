#!/bin/bash
# file download and extraction script with gpg encryption support
# add -mt for multiple file download (file number = your processor's logical processors count
# $1 = list url, $2 = password, $3 = output dir

# cygwin format of tempdir
tmpdir2="Z:"
tmpdir=`cygpath "$tmpdir2"`

# linux format of tempdir
# tmpdir2="/tmp"
# tmpdir="$tmpdir2"

function download_and_extarct_dir_v3() { # $1 = link file in link
    [ "$3" ] && outdir="$3" || outdir="./"
    for line in `curl -k "$1" | gpg -d --cipher-algo AES256 --passphrase "$2"`
    do
        url=`echo $line | cut -d\| -f1`
        checksums=`echo $line | cut -d\| -f2`
        checksums2="bruhfei"
        while [ $checksums2 != $checksums ]
        do
            rm "$tmpdir/barbruh114514.encrypted" "$tmpdir/barbruh114514.encrypted.arai2" -f
            aria2c --check-certificate=false -k 1M -x 32 -s 32 -j 64 -R -c --auto-file-renaming=false --dir "$tmpdir2" --out "barbruh114514.encrypted" "$url" 1>&2
            cat "$tmpdir/barbruh114514.encrypted" | gpg -d --cipher-algo AES256 --passphrase "$2" > "$tmpdir/barbruh114514"
            rm "$tmpdir/barbruh114514.encrypted" "$tmpdir/barbruh114514.encrypted.arai2" -f
            checksums2=`sha512sum "$tmpdir/barbruh114514" | cut -f1 -d' '`
        done
        cat "$tmpdir/barbruh114514"
        rm "$tmpdir/barbruh114514" -f
    done | tar -C "$outdir" -xv
}

function download_and_extarct_dir_mt_v3(){ # $1 = link, $2 = password, $3 = output dir
    [ "$3" ] && outdir="$3" || outdir="./"
    cat << EOF > /tmp/wiebitte114514.sh
password="\$1"
totalfiles=0
for line in \`cat - \`
do
    let totalfiles++
    url=\`echo \$line | cut -d\| -f1\`
    checksums=\`echo \$line | cut -d\| -f2\`
    checksums2="bruhfei"
    while [ \$checksums2 != \$checksums ]
    do
        rm "$tmpdir/barbruh\$totalfiles.encrypted" "$tmpdir/barbruh\$totalfiles.encrypted.aria2" -f
        aria2c --check-certificate=false -k 1M -x 32 -s 32 -j 64 -R -c --auto-file-renaming=false --dir "$tmpdir2" --out "barbruh\$totalfiles.encrypted" "\$url" 1>&2
        cat "$tmpdir/barbruh\$totalfiles.encrypted" | gpg -d --cipher-algo AES256 --passphrase "$2" > "$tmpdir/barbruh\$totalfiles"
        rm "$tmpdir/barbruh\$totalfiles.encrypted" "$tmpdir/barbruh\$totalfiles.encrypted.aria2" -f
        checksums2=\`sha512sum "$tmpdir/barbruh\$totalfiles" | cut -f1 -d' '\`
    done &
done
wait
for num in \`seq 1 \$totalfiles\`
do
    cat "$tmpdir/barbruh\$num" 
    rm "$tmpdir/barbruh\$num" -f
done
EOF

    processes=`cat /proc/cpuinfo | grep "processor" | wc -l`
    # processes=4
    [ "$3" ] && outdir="$3" || outdir="./"
    curl -k "$1" | gpg -d --cipher-algo AES256 --passphrase "$2" | split -l "$processes" --filter 'cat | bash /tmp/wiebitte114514.sh' | tar -C "$outdir" -xv
    rm /tmp/wiebitte114514.sh -f
}

[ "$1" = "-mt" ] && download_and_extarct_dir_mt_v3 "$2" "$3" "$4" || download_and_extarct_dir_v3 "$1" "$2" "$3"
