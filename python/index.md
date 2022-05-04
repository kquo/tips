# PYTHON
Python tips.


## HTTP Server
Start a simple HTTP server to serve files.
```
mkdir foo
cd foo
python -m SimpleHTTPServer
Serving HTTP on 0.0.0.0 port 8000 ...
```


## Random Numbers
```
python
>>> import random ; a = range(10)
>>> random.shuffle(a) ; a
```


## Colorize Strings
```
import os, sys
# Simple color functions need to be defined as early as possible
def whi2 (strg): return '\033[1;37m' + strg + '\033[0m'
def whi1 (strg): return '\033[0;37m' + strg + '\033[0m'
def gra1 (strg): return '\033[1;30m' + strg + '\033[0m'
def red2 (strg): return '\033[1;31m' + strg + '\033[0m'
def yel2 (strg): return '\033[1;33m' + strg + '\033[0m'
def blu1 (strg): return '\033[0;34m' + strg + '\033[0m'
def blu2 (strg): return '\033[1;34m' + strg + '\033[0m'
def pur2 (strg): return '\033[1;35m' + strg + '\033[0m'
strg = "hello"
print whi2(strg) + whi1(strg) + gra1(strg) + red2(strg) + yel2(strg) + blu1(strg) + blu2(strg) + pur2(strg)
```


## Dump Object
```
def dumpObj(obj):
  for attr in dir(obj):
    print "obj.%s = %s" % (attr, getattr(obj, attr))
```


## Print JSON
```
import json
# Read from file
with open('my.json') as f:
  prgConf = json.load(f)
# Write to another file
with open('another.json', 'w') as f:
    json.dump(prgConf, f)
# Pretty print
print json.dumps(prgConf, sort_keys=True, indent=2, separators=(',', ': '))
```


## REPLACE FILENAME EXTENSION
```
import os
OldFilename = 'myfile.txt'
NewFilename = os.path.splitext(OldFilename)[0]+'.json'
```


## Print Cursor Position
```
print("\033[6;3HHello")
# Or
import sys
def printxy(x, y, text):
  sys.stdout.write("\x1b7\x1b[%d;%df%s\x1b8" % (x, y, text))
  sys.stdout.flush()
# See also bash.txt
```

## Class As C Struct
```
class DnsT():         # Our own AWS DNS record structure
  def __init__(self, ZoneId=None,Name=None,Type=None,Ttl=None,Count=None,Values=None,AccountId=None,AccountAlias=None):
    self.ZoneId       = ZoneId
    self.Name         = Name           # Primary key
    self.Type         = Type
    self.Ttl          = Ttl
    self.Count        = Count
    self.Values       = []
    self.AccountId    = AccountId
    self.AccountAlias = AccountAlias
d = DnsT()                          # Create empty DNS rec object
d.AccountId    = awsAccountId
d.AccountAlias = awsAccountAlias
d.ZoneId       = z.Id
```


## Serialize Datetime Variable
```
# AWS datetime vars are not JSON serializable, so below is one way of serializing it
json.JSONEncoder.default = lambda self,obj: (obj.isoformat() if isinstance(obj, datetime.datetime) else None)
```


## Formatted PrintF Like C
```
>>> a = "hello"; b = "me"
>>> print '{0: <20}'.format(b), a
me                   hello
```

## Install a Python Program
There are many ways to do this.
- Method 1
```
git pull
sudo python setup.py install OR
pip install .
```

- Method 2
```
pip install myprogram
```


## Rename Files
Rename files FROM and TO, as listed in `list.txt` file.
```
#!/usr/bin/env python
# ren.py
import os
cwd = os.getcwd()
f = open("list.txt")
lines = f.readlines()
for old in lines:
    newf = cwd + '/' + old[:-7] + '.mp3'   # Remove trailing ' 1'
    oldf = cwd + '/' + old[:-1]            # Removing trailing newline
    if os.path.isfile(oldf):
        os.rename(oldf, newf)
```


## Console Input
```
if option == "normal":
    msg = "Are you sure you want to STOP " + whi1(vmName) + "? y/n "
    response = raw_input(msg)
    if response != "y":
        return 1
```


## Convert List To Dictionary
```
new_dict = dict(map(None, *[iter(mylist)]*2))
```


## Test Stale TCP Socket
```
#!/bin/env python
# stale-socket-tester.py

import sys, requests, socket, json, time, datetime

url = 'https://sandbox.itunes.apple.com/verifyReceipt'
#url = 'http://52.41.90.67'

headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Cache-Control': 'no-cache', 'Postman-Token': 'a095818a-6477-8553-4200-506dbe3688a7'}

data = {'password': 'f22df5678b1e4aec804dc2e8647e32fb', 'receipt-data': 'ewoJInNpZ25hdHVyZSIgPSAiQWs4c2RJdVZQUjJ3bitHL0JuZnZ1dW5rYTFwd0w0aEk3OEFmTHRCTEJnV2haZGVuazdlb0FkSGdpdURlNEUzdEpSTGxYUzhrVU1hcnFXYURuZWxpU3F0alNDbGloQ0xKM3B4d3lSeVJiTjBwVVJBbW54UTNiREp5OTh5dXRhTXdjeE03ZnJ4a1ZJMmk5N3lKcWlpcG5yWUJIUjgvWTd4YXA0bnlqTzBjay8wbUFBQURWekNDQTFNd2dnSTdvQU1DQVFJQ0NHVVVrVTNaV0FTMU1BMEdDU3FHU0liM0RRRUJCUVVBTUg4eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUtEQXBCY0hCc1pTQkpibU11TVNZd0pBWURWUVFMREIxQmNIQnNaU0JEWlhKMGFXWnBZMkYwYVc5dUlFRjFkR2h2Y21sMGVURXpNREVHQTFVRUF3d3FRWEJ3YkdVZ2FWUjFibVZ6SUZOMGIzSmxJRU5sY25ScFptbGpZWFJwYjI0Z1FYVjBhRzl5YVhSNU1CNFhEVEE1TURZeE5USXlNRFUxTmxvWERURTBNRFl4TkRJeU1EVTFObG93WkRFak1DRUdBMVVFQXd3YVVIVnlZMmhoYzJWU1pXTmxhWEIwUTJWeWRHbG1hV05oZEdVeEd6QVpCZ05WQkFzTUVrRndjR3hsSUdsVWRXNWxjeUJUZEc5eVpURVRNQkVHQTFVRUNnd0tRWEJ3YkdVZ1NXNWpMakVMTUFrR0ExVUVCaE1DVlZNd2daOHdEUVlKS29aSWh2Y05BUUVCQlFBRGdZMEFNSUdKQW9HQkFNclJqRjJjdDRJclNkaVRDaGFJMGc4cHd2L2NtSHM4cC9Sd1YvcnQvOTFYS1ZoTmw0WElCaW1LalFRTmZnSHNEczZ5anUrK0RyS0pFN3VLc3BoTWRkS1lmRkU1ckdYc0FkQkVqQndSSXhleFRldngzSExFRkdBdDFtb0t4NTA5ZGh4dGlJZERnSnYyWWFWczQ5QjB1SnZOZHk2U01xTk5MSHNETHpEUzlvWkhBZ01CQUFHamNqQndNQXdHQTFVZEV3RUIvd1FDTUFBd0h3WURWUjBqQkJnd0ZvQVVOaDNvNHAyQzBnRVl0VEpyRHRkREM1RllRem93RGdZRFZSMFBBUUgvQkFRREFnZUFNQjBHQTFVZERnUVdCQlNwZzRQeUdVakZQaEpYQ0JUTXphTittVjhrOVRBUUJnb3Foa2lHOTJOa0JnVUJCQUlGQURBTkJna3Foa2lHOXcwQkFRVUZBQU9DQVFFQUVhU2JQanRtTjRDL0lCM1FFcEszMlJ4YWNDRFhkVlhBZVZSZVM1RmFaeGMrdDg4cFFQOTNCaUF4dmRXLzNlVFNNR1k1RmJlQVlMM2V0cVA1Z204d3JGb2pYMGlreVZSU3RRKy9BUTBLRWp0cUIwN2tMczlRVWU4Y3pSOFVHZmRNMUV1bVYvVWd2RGQ0TndOWXhMUU1nNFdUUWZna1FRVnk4R1had1ZIZ2JFL1VDNlk3MDUzcEdYQms1MU5QTTN3b3hoZDNnU1JMdlhqK2xvSHNTdGNURXFlOXBCRHBtRzUrc2s0dHcrR0szR01lRU41LytlMVFUOW5wL0tsMW5qK2FCdzdDMHhzeTBiRm5hQWQxY1NTNnhkb3J5L0NVdk02Z3RLc21uT09kcVRlc2JwMGJzOHNuNldxczBDOWRnY3hSSHVPTVoydG04bnBMVW03YXJnT1N6UT09IjsKCSJwdXJjaGFzZS1pbmZvIiA9ICJld29KSW5CMWNtTm9ZWE5sTFdSaGRHVWlJRDBnSWpJd01URXRNRFV0TVRjZ01UVTZNVE02TlRBZ1JYUmpMMGROVkNJN0Nna2lhWFJsYlMxcFpDSWdQU0FpTkRJd01Ua3hOamd6SWpzS0NTSnZjbWxuYVc1aGJDMTBjbUZ1YzJGamRHbHZiaTFwWkNJZ1BTQWlNVEF3TURBd01EQXdNakkxTWprME9TSTdDZ2tpWlhod2FYSmxjeTFrWVhSbElpQTlJQ0l4TXpBMU5qUTFOVE13TmpRM0lqc0tDU0p3Y205a2RXTjBMV2xrSWlBOUlDSmpiMjB1WTI5dVpHVnVaWFF1Ym1WM2VXOXlhMlZ5TG5OMVlpNHhiVzhpT3dvSkluUnlZVzV6WVdOMGFXOXVMV2xrSWlBOUlDSXhNREF3TURBd01EQXlNemswTkRFMElqc0tDU0p4ZFdGdWRHbDBlU0lnUFNBaU1TSTdDZ2tpYjNKcFoybHVZV3d0Y0hWeVkyaGhjMlV0WkdGMFpTSWdQU0FpTWpBeE1TMHdOUzB3TkNBeE9Ub3lOam96TUNCRmRHTXZSMDFVSWpzS0NTSmlhV1FpSUQwZ0ltTnZiUzVqYjI1a1pXNWxkQzV1WlhkNWIzSnJaWElpT3dvSkltSjJjbk1pSUQwZ0lqRXVOeTR6TGpBdU1DSTdDbjA9IjsKCSJlbnZpcm9ubWVudCIgPSAiU2FuZGJveCI7CgkicG9kIiA9ICIxMDAiOwoJInNpZ25pbmctc3RhdHVzIiA9ICIwIjsKfQ' }

session = requests.Session() # Setup a session

# Use the socket to do the GET|POST
try:
    response = session.post(url, data=json.dumps(data), headers=headers, timeout=None, stream=False)
    #response = ses.get(url, timeout=None, stream=False)
    print response
except Exception as error_string:
    print error_string

time.sleep(400) # Sleep for over 5 minutes (most routers timeouts)

# Try to re-use existing session socket for next GET|POST
try:
    response = session.post(url, data=json.dumps(data), headers=headers, timeout=None, stream=False)
    #response = ses.get(url, timeout=None, stream=False)
    print response
except Exception as error_string:
    print error_string
```


## Pip Config
```
[global]
timeout = 60
trusted-host = pypi.org, files.pythonhosted.org
```

- Windows Notes
```
pip config list -v shows where pip config files are expected
```


## Certifi
Use certifi module to deal or cicumvent CERTIFICATE_VERIFY_FAILED issues
```
pip install certifi
python -m certifi
/Users/user1/Library/Python/2.7/lib/python/site-packages/certifi/cacert.pem
```
1. Get your corporate CA bundle
2. Append corp bundle to end of above cacert.pem file

