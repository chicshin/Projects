"""
Scrap Instagram javascript url.
Get the top posts' hashtags.
Save it into 'ig_top_posts_tags2.txt'
The saved data will be analyzed for in use of tags recommendation.
"""
import json
import urllib.request

tag = 'yoga'
url = 'https://www.instagram.com/explore/tags/' + tag + '/?__a=1'

with urllib.request.urlopen(url) as response:
    source = response.read()

# dump javascript data for easily readable
data = json.loads(source.strip(), strict=False)
with open("soup.py", "w") as f:
    json.dump(data, f, indent=4)

def get_tags(data):
    tags_list = []
    for post in data['graphql']['hashtag']['edge_hashtag_to_top_posts']['edges']:
        caption = post['node']['edge_media_to_caption']['edges'][0]['node']['text'].split(" ")
        for text in caption:
            if text.strip().startswith('#') and text.strip() not in tags_list:
                tags_list.append(text.strip())
    return tags_list
get_tags(data)

# write the data in external file
with open('ig_top_posts_tags2.txt', 'w') as f:
    for line in get_tags(data):
        f.write('%s\n' % line)
