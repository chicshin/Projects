"""
Scrap Instagram javascript url by using shortcode.
Get the hashtags from captions and comments.
Saved data will be analyzed for in use of tags recommendation.
"""
import json
import urllib.request

tag = 'yoga'
url = 'https://www.instagram.com/explore/tags/' + tag + '/?__a=1'

def get_json(url):
    with urllib.request.urlopen(url) as response:
        source = response.read()
    data = json.loads(source.strip(), strict=False)
    # with open('tag_json.py', 'w') as f:
        # json.dump(data, f, indent=4)
    return data

data = get_json(url)
path = data['graphql']['hashtag']['edge_hashtag_to_top_posts']['edges']

def get_shortcode():
    shortcode_urls = []
    for post in path:
        shortcode = post['node']['shortcode']
        url = 'http://www.instagram.com/p/' + shortcode + '/?__a=1'
        shortcode_urls.append(url)
    return shortcode_urls
# print(get_shortcode(path))

def get_tags():
    tag_list =[]
    url = get_shortcode()
    for i in range(len(url)):
        with urllib.request.urlopen(url[i]) as response:
            source = response.read()
        data = json.loads(source.strip(), strict=False)

        for post in data['graphql']['shortcode_media']['edge_media_to_caption']['edges']:
            caption_tags = post['node']['text'].split(' ')
            for text in caption_tags:
                if text.strip().startswith('#') and text.strip() not in tag_list:
                    tag_list.append(text.strip())
        for post in data['graphql']['shortcode_media']['edge_media_to_comment']['edges']:
            comment_tags = post['node']['text'].split(' ')
            for text in comment_tags:
                if text.strip().startswith('#') and text.strip() not in tag_list:
                    tag_list.append(text.strip())
    print(tag_list)
get_tags()
