# Twitter
Twitter tips.

## Deleting Twitter Data
For most of these utilities you have to [download an archive of your Twitter Data](https://twitter.com/settings/download_your_data). Once downloaded and extracted, the data looks like: 
```
drwx------ 80 user1 staff 2560 Jul  9 15:04 data
drwx------  5 user1 staff  160 Jul  9 15:04 assets
-rw-------  1 user1 staff 1432 Jul  9 15:04 Your archive.html
```

`delete-tweets`: 
  - <https://github.com/koenrh/delete-tweets>
  - Install with `python3 -m pip install delete-tweets`
  - Follow Github README to set up credentials: 

```
export TWITTER_CONSUMER_KEY="your_consumer_key"
export TWITTER_CONSUMER_SECRET="your_consumer_secret"
export TWITTER_ACCESS_TOKEN="your_access_token"
export TWITTER_ACCESS_TOKEN_SECRET="your_access_token_secret"
```

  - `delete-tweets --since 2010-01-01 data/tweet.js`
  - `delete-tweets --since 2010-01-01 data/tweet.js --spare-min-likes 100 --spare-min-retweets 50`

`tweepy`: 
  - <https://github.com/tweepy/tweepy>
  - Semiphemeral needs this to work
  - Had to lower version to get `semiphemeral` to work: `pip install tweepy==3.10.0`

`semiphemeral`: 
  -  <https://github.com/micahflee/semiphemeral>
  - Again, setup credentials as per README
  - Once installed and configure, see `cat ~/.semiphemeral/settings.json` to confirm that: 

```
"api_key": "your_consumer_key",
"api_secret": "your_consumer_secret",
"access_token_key": "your_access_token",
"access_token_secret": "your_access_token_secret",
```

  - `semiphemeral unlike --filename data/like.js`
  - Many other options

