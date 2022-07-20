# Applications
Application tips.


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

semiphemeral unlike --filename ~/Downloads/data/like.js
(Had to lower tweppy version: pip install tweepy==3.10.0)

`tweepy`: 
  - <https://github.com/tweepy/tweepy>
  - Semiphemeral needs this to work

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


## vi
`vi` text editor tips.

  ```
  CTRL-V    u                  Change case
  SHIFT-I   spaces             Indent
  INDENT BLOCK
    Go to line, and press v then jj, selecting all the lines you want
    :le 4   for 4 spaces
  UNIDENT ENTIRE FILE
    :gg=G
  SET AUTOINDENT
    :set ai
  SEARCH/REPLACE g multiple instances per line, c confirm
    :%s/OLD/NEW/gc             
  ```

## Text Message From CLI
Send a text message a **macOS** shell command-line interface, using the <https://textbelt.com> service (they typically allow 250 messages for $10).

- For example, using `curl` and your own Textbelt key:

  ```
  curl -X POST https://textbelt.com/text \
      --data-urlencode phone="5557727420" \
      --data-urlencode message="Hello world" \
      -d key=aslkjdfkja_purchase-your-own-key!_lkajsdkj3j22jk34h54i3ijri3jr3jri34jrio3j4ir
  ```

Repo <https://github.com/lencap/sms> also has a Bash, GoLang and C programs for doing this.

- Or for free using an Apple Script such as:

  ```
  #!/usr/bin/osascript
  # sms
  on waitUntilRunning(appName, delayTime)
      repeat until application appName is running
          tell application appName to close window 1
          delay delayTime
      end repeat
      delay delayTime
  end waitUntilRunning
  on run {targetBuddyPhone, targetMessage}
      tell application "Messages"
          # Launch Messages.app if not running
          set wasRunning to true
          if it is not running then
              set wasRunning to false
              launch
              close window 1
              my waitUntilRunning("Messages", 1)
              close window 1
          end if
          # Send the message
          set targetService to 1st service whose service type = iMessage
          set targetBuddy to buddy targetBuddyPhone of targetService
          send targetMessage to targetBuddy
          # Close window if app wasn't originally running
          if not wasRunning
              close window 1
          end if
      end tell
  end run
  ```

A better script be found also  in <https://github.com/lencap/sms>.


## Siege Web Stress Testing tool
Typical siege load test commands.

  ```
  [root@loadtester ~]# siege -t20M -d5 -c5  -i -f urls-stag.site1.txt
  [root@loadtester ~]# siege -t20M -d5 -c50 -i -f urls-prod.site1.txt
  ```

- Arguments:

  ```
  -t20M         Run for 20 minutes
  -d5           Random range (0-5) of seconds to sleep between each user hit
  -c5 or -c50   Number of concurrent users
  -i            Randomize URL to hit from the file
  -f <FILE>     File with list of URLs to hit (one per line)
  ```

- Options:

  ```
  -v            Output each URL hit to standard out during load test
  ```

- Typical content of URLs file:
  ```
  www.site1.com/
  www.site1.com/path1
  www.site1.com/this-other path
  www.site1.com/path2/anothe-path
  ```


## Email DMARC
[DMARC](https://dmarc.org/) is an open email Internet standard detailed in [RFC 7489](https://datatracker.ietf.org/doc/html/rfc7489). 

Domain-based Message Authentication, Reporting, and Conformance (DMARC) works with Sender Policy Framework (SPF) and DomainKeys Identified Mail (DKIM) to authenticate mail senders and ensure that destination email systems trust messages sent from your domain. Implementing DMARC with SPF and DKIM provides additional protection against spoofing and phishing email. DMARC helps receiving mail systems determine what to do with messages sent from your domain that fail SPF or DKIM checks.

- Sample DNS TXT record DMARC setup: 

  ```
  dig txt _dmarc.mydomain.com +short
  "v=DMARC1; p=reject; pct=100; rua=mailto:dmarc@mydomain.com"
  ```

- Microsoft has a good write-up here <https://docs.microsoft.com/en-us/microsoft-365/security/office-365-security/use-dmarc-to-validate-email?view=o365-worldwide>

- Prajit Sindhkar also has another good write-up here <https://medium.com/techiepedia/how-to-report-dmarc-vulnerabilities-efficiently-to-earn-bounties-easily-f7a65ecdd20b>

- ProtonMail has yet another good post here <https://protonmail.com/support/knowledge-base/anti-spoofing/>


## PDF
- **Size Reduction**:
You can use ImageMagick to reduce the size of a PDF by lowering its resolution.
From https://apple.stackexchange.com/questions/297417/how-to-decrease-pdf-size-without-losing-quality :

  ```
  brew install imagemagick
  convert -density 72 oldfile.pdf new.pdf
  ```
where 72 is the target DPI.

- **PDF Join/Merge**:
Best option is to use `pdfunite`, from `brew install poppler` which also installs other useful PDF tools:

  ```
  pdfunit one.pdf sub/*.pdf merged.pdf
  ```

  - **References**:
    - <https://apple.stackexchange.com/questions/230437/how-can-i-combine-multiple-pdfs-using-the-command-line>
    - <https://www.mankier.com/package/poppler-utils>
