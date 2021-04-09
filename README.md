# Quote uploader

## Working 
0. Select an author's name from author_list.txt
1. Download images from brainyquote using wget
2. Divide them in parts (10 pics / part).
3. crop the images using imagemagick
4. create a video slideshow with bg music using ffmpeg
5. upload the video to dailymotion using their Python API
6. add author name to logs.txt

## Assets
Require audio 'bgm.mp3' in ./audios folder
Require author_list.txt

## Usage
Change directory name, and bgm.mp3 in the 'main.sh' file
Change video directory name in dailymotion/main.py 
#### If you want to upload to dailymotion
Get dailymotion API info and add them in dailymotion/secrets.py

finally you can run the script with bash

```bash
bash main.sh
```
or (dont forget to make it executable )
```bash
chmod +x main.sh
```
```bash
./main.sh
```
