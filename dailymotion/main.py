import dailymotion
import argparse
from secrets import *

INFO = {'username': USERNAME, 'password': PASSWORD}
# add your video directory here
VID_DIR = '/mnt/krishna/Kakoune/Quotes/videos/'

# parsing arguments
parser = argparse.ArgumentParser()
parser.add_argument("--author", help="Name of the author")
parser.add_argument("--part", help="Part name")
parser.add_argument("--count", help="Number of Quotes")

options = parser.parse_args()

author = options.author
part = options.part
count = int(options.count) or 10


def upload(author, part, count=10):
    """
        Upload video to dailymotion
        uses api details imported from secrets.py
        @param author as str
        @param part as str
        @param count as int
    """
    
    video = f"{VID_DIR}/{author}/final{part}.mp4"
    name = author.title().replace("-", " ")
    title = f"{count} Inspirational {name} quotes"

    # dailymotion api
    d = dailymotion.Dailymotion()
    d.set_grant_type('password', api_key=API_KEY, api_secret=API_SECRET,
                        scope=['manage_videos'], info=INFO)
    
    url = d.upload(video)
    try:
        d.post('/me/videos',
            {'url': url, 'title': title,
            'published': 'true', 'channel': 'lifestyle'})
        print("uploaded")
    except:
        print("error while uploading")

upload(author, part, count)
