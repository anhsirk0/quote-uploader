#!/bin/bash
dir="/mnt/krishna/Kakoune/Quotes"
base_url="https://www.brainyquote.com"
author_list=$dir/author_list.txt

get_author_name () {
    local num=$(wc $author_list -l | cut -d " " -f1)
    for i in $(seq $num) ; do
        # author=$(sed "${i}q;d" $author_list)
        author=$(awk "NR == ${i} {print}" $author_list)
        local exists=$(grep "$author" $log_file -c)
        if [[ "$exists" -eq "0" ]] ; then
            break
        fi
    done
    echo $author
}

get_image_urls () {
    [[ -z "$1" ]] && exit
    echo "Author : $1"
    mkdir -p  "$dir/images/$1" 
    url="$base_url/authors/$1-quotes"

    curl -s $url --output $dir/result
    if [[ -f $dir/result ]] ; then
        grep -Eo "img-url=.*?.jpg" $dir/result | \
                               cut -d \" -f2 > $dir/$1-img_urls.txt

        echo "Retrieved image urls , $(wc -l $dir/$1-img_urls.txt)"
        sed -i 's/.jpg$/-2x.jpg/g' $dir/$1-img_urls.txt
    fi    
}

download_images () {
    if [[ -f "$dir/$author-img_urls.txt" ]] ; then
        local i=0
        # only 10 images
        sed -i 10q $dir/$author-img_urls.txt
        [[ -d "$dir/images/$author" ]] || mkdir $dir/images/$author -p 
        while read img; do
            if [[ $i -lt 10 ]] ; then
                local name="img_0$i.jpg"
            else
                local name="img_$i.jpg"
            fi

            wget "$base_url$img" -O "$dir/images/$author/$name"
            i=$(( i + 1 ))
        done < $dir/$author-img_urls.txt

        echo "Downloaded $i images of $author quotes"
    else
        echo "$1 not exists"
    fi
}

divide_images () {
    local cdir=$dir/images/$author
    
    local total=$(ls $cdir | grep -Ec ".jpg$")
    if [[ $total -gt 9 ]] ; then
        mkdir $cdir/part0
        mv $cdir/img_{00..09}.jpg $cdir/part0
        echo "part0 created"
    fi

    if [[ $total -gt 19 ]] ; then
        mkdir $cdir/part1
        mv $cdir/img_{10..19}.jpg $cdir/part1
        echo "part1 created"
    else
        mkdir $cdir/part1
        mv $cdir/*.jpg $cdir/part1
    fi

    if [[ $total -gt 29 ]] ; then
        mkdir $cdir/part2
        mv $cdir/img_{20..29}.jpg $cdir/part2
        echo "part2 created"
    fi

    local left=$(ls $cdir | grep -Ec ".jpg$")

    if [[ $left -gt 0 ]] ; then
        mkdir $cdir/part3
        mv $cdir/*.jpg $cdir/part3
        echo "part3 created"
    fi

    echo "Done dividing images"
}

crop_images () {
    ## takes a dir as arguement
    echo "Cropping images from: $1 " 
    ls $1/*.jpg > temp_file
    while read img ; do
        local name=$(echo $img | awk -F "/" '{print $NF}')
        local num=${name//[^0-9]/}
        convert $img -crop 1200x564+0+0 $1/out_$num.jpg
        echo "Cropped $img"
    done < temp_file
    rm temp_file
    rm -r $1/img*
    echo "Deleted original"
}

create_video () {
    ## takes a dir as input
    local vid_dir=$dir/videos/$author
    [[ -d $vid_dir ]] || mkdir $vid_dir -p
    local part=${1//[^0-9]/}
    local vid=$vid_dir/final$part.mp4
    ffmpeg -r 1/6 -i $1/out_$part%d.jpg -y -r 30 \
                                    -pix_fmt yuv420p $1/out.mp4
                                    
    ffmpeg -i $1/out.mp4 -y -i $dir/audios/bgm.mp3 \
                        -map 0:v -map 1:a -shortest $vid
                        
    if [[ -f "$vid" ]] ; then
        echo "Video saved as $vid_dir/final.mp4"
    else
        echo "Failed to create video"
    fi
}

upload_video () {
    echo "Starting upload"
    local output=$(python3 $dir/dailymotion/main.py --author="$1" \
                                     --part="$2" \
                                     --count="$3")
    if [[ "$output" == "uploaded" ]] ; then
        echo "$1 $2 $3" >> $log_file
        echo "Uploaded $1/final$2.mp4"
    else
        echo "Error occured"
    fi
}

main () {
    # echo "Enter part (0, 1, 2 ...)"
    # read p
    p=0
    log_file="$dir/logs$p.txt"
    [[ -f $log_file ]] || touch $log_file
    author="$(get_author_name)"
    get_image_urls "$author"
    download_images
    divide_images
    crop_images "$dir/images/$author/part$p"
    create_video "$dir/images/$author/part$p"
    upload_video "$author" "$p" "10" 
    rm *img_urls* result*
}

main
