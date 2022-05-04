# Load Balancers

## F5 Common Commands
- References
  - <http://thesecurityjuggernaut.blogspot.com/2011/09/moving-from-bigpipe-to-tmsh.html>
  - <http://www.fir3net.com/Big-IP-F5-LTM/f5-ltm-commands.html>

```
ssh lb01
[f5admin@LB01:Active] ~ # tmsh
[f5admin@LB02:Active](tmsh)# ?
[f5admin@LB02:Active](tmsh)# show sys hardware
[f5admin@LB02:Active](tmsh)# show sys software

LIST PARTITIONS
[f5admin@LB02:Active](tmsh)# list /auth partition

SWITCH PARTITIONS
[f5admin@LB02:Active](tmsh)# modify /cli admin-partitions query-partitions all update-partition Common
[f5admin@LB02:Active](tmsh)# modify /cli admin-partitions query-partitions all update-partition Part3


CREATE NODE
[f5admin@LB02:Active](tmsh)# create /ltm node 205.217.104.36

COMMON LIST COMMANDS
[f5admin@LB02:Active](tmsh)# ltm
[f5admin@LB02:Active](tmsh)# list /ltm profile http http_x-forwarded-for
[f5admin@LB02:Active](tmsh.ltm)# list rule https-offloaded-header
[f5admin@LB02:Active](tmsh.ltm)# list profile client-ssl www.mysite.com
[f5admin@LB02:Active](tmsh.ltm)# list node | grep 120.57
[f5admin@LB02:Active](tmsh.ltm)# list node *120.57*
[f5admin@LB02:Active](tmsh.ltm)# list pool *105.37*
[f5admin@LB02:Active](tmsh.ltm)# list virtual *105.37*

SAVE/SYNC CONFIG
[f5admin@LB02:Active] ~ # tmsh save sys config
[f5admin@LB02:Active] ~ # tmsh run sys config-sync

CREATING SELF-SIGNED CERTS (using our script)
[f5admin@LB02:Active] ~ # ./genselfcert-f5.sh -n www.mysite.com 2048
  - Creates the following 3 files:
    /config/ssl/ssl.crt/www.mysite.com.crt
    /config/ssl/ssl.csr/www.mysite.com.csr
    /config/ssl/ssl.key/www.mysite.com.key

LIST CERT INFO 
[f5admin@LB02:Active] ~ # openssl x509 -in /config/ssl/ssl.crt/www.mysite.com.crt -noout -text | egrep "Not After|Subject:"

YOU CAN USE *.crt CERT TO CREATE PROPER CERT VIA a CA

CREATE PROFILE
[f5admin@LB02:Active](tmsh.ltm)# edit profile client-ssl www.mysite.com
    ca-file EntrustCertificationAuthority-L1C.crt
    cert www.mysite.com.crt
    defaults-from clientssl
    key www.mysite.com.key

CREATE/MODIFY HTTP PROFILE
[f5admin@LB02:Active](tmsh.ltm)# edit profile http http_x-forwarded-for
    defaults-from http
    insert-xforwarded-for enabled

CREATE/MODIFY SPECIAL RULE
(PER PARTITION. BETTER PLACE IT IN COMMON)
[f5admin@LB02:Active](tmsh.ltm)# edit rule https-offloaded-header_part1
    when HTTP_REQUEST {
        HTTP::header insert "X-Forwarded-Proto" "https"
    }

CREATE/MODIFY POOL
[f5admin@LB02:Active](tmsh.ltm)# edit pool vip_205.217.104.36_80-443-10700
    members replace-all-with {
        10.89.117.7:10700 {
            session monitor-enabled
        }
        10.89.117.8:10700 {
            session monitor-enabled
        }
    }
    monitor test-index

CREATE/MODIFY VIP (regular HTTP and HTTPS)
[f5admin@LB02:Active](tmsh.ltm)# edit virtual vip_205.217.104.36_80
    destination 205.217.104.36:80
    ip-protocol tcp
    mask 255.255.255.255
    pool vip_205.217.104.36_80-443-10700
    profiles replace-all-with {
      http_x-forwarded-for {}
      oneconnect {}
      tcp {}
    }
    snat automap

[f5admin@LB02:Active](tmsh.ltm)# edit virtual vip_205.217.104.36_443
    destination 205.217.104.36:443
    ip-protocol tcp
    mask 255.255.255.255
    pool vip_205.217.104.36_80-443-10700
    profiles replace-all-with {
        http { }
        tcp { }
        www.mysite.com {
            context clientside
        }
    }
    rules {
        https-offloaded-header_part1
    }
    snat automap

ENABLE/DISABLE
f5admin@LB01(Active)(tmos)# modify /ltm virtual vip_205.217.104.31_80 disabled/enabled

DELETE
f5admin@LB01(Active)(tmos)# delete pool vip_205.217.105.37_80-443-10712

IRULES
ltm rule redirect-http-to-https {
    when HTTP_REQUEST {
        # Redirect all traffic to HTTPS
        HTTP::redirect "https://[HTTP::host][HTTP::uri]"
    }
}
```


## HTTP Basic Auth iRule
F5 iRule for basich HTTP authentication digest. This is really not recommended, but it's a good example of how iRules are crafted and used..

- Create the rule
```
# edit rule http-auth
    when HTTP_REQUEST {

        # Skip rule if URL contain action=hipbot
        set uri [string tolower [HTTP::uri]]
        if { not ($uri contains action=hipbot) } {

            # Get Akamai True-Client-IP if available
            if {[HTTP::header exists True-Client-IP]} {
                set ip [HTTP::header value True-Client-IP]
            } else {
                set ip [IP::client_addr]
            }

            # Force HTTP Authentication unless client IP is from the approved list
            if { ( [class match $ip equals mysite-internal-ip] ) } {
                return
                # DEBUG - HTTP::respond 200 content Good <BR> IP = $ip <BR>
            } else {
                set vip [virtual name]
                set username [HTTP::username]
                binary scan [md5 [HTTP::password]] H* password
                if { [class lookup $username authorized_users] equals $password } {
                    log local0. $vip - Authorizing access to user $username
                    # Insert iRule-based application code here if necessary
                } else {
                    if { [string length [HTTP::password]] != 0 } {
                        log local0. $vip - Authorizing access to user $username
                    }
                    HTTP::respond 401 WWW-Authenticate Basic realm=\Secured Area\
                }
            }
        }
    }  
```

- Add http-auth to 80 & 443 virtuals:
```
rules {
    http-auth
    https-offloaded-header
}
```

- Edit user/pass
```
edit /ltm data-group authorized_users
# md5 hash the password with shell command:
    myuser1:butterfly1925
    # echo -n butterfly1925 | md5sum
    e4260b646531b134280fa1283c8cd96f

# Add hash as 'data' item to respective user
modify data-group authorized_users {
    records replace-all-with {
        myuser1 {
            data e4260b646531b134280fa1283c8cd96f
        }
    }
    type string
}
```
