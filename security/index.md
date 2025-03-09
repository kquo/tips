# Security
Security tips.

## Storing Passwords
To store passwords use `bcript` -- don't use MD5. The key point is that *bcrypt* is like MD5 and other hash checksum tools, **but very, very slow**. And this a phenomenal deterence to brute force attacks.

- <https://codahale.com/how-to-safely-store-a-password/>
- <https://pypi.org/project/py-bcrypt/>


## pfSense Let's Encrypt Certs
To set up pfSense to use Let's Encrypt certificates (acme), just follow existing references.

**References:**
- <https://www.contradodigital.com/2021/02/15/how-to-setup-lets-encrypt-on-pfsense/>
- <https://gainanov.pro/eng-blog/linux/installing-lets-encrypt-pfsense/>
- <https://www.danielcolomb.com/2019/08/29/creating-wildcard-certificates-on-pfsense-with-lets-encrypt/>


## Let's Encrypt SSL Certificates
Follow below steps to install and configure Certbot, and to issue and renew [Let's Encrypt](https://letsencrypt.org/) SSL certificates.

These steps are based on [this Digital Ocean article](https://www.digitalocean.com/community/tutorials/how-to-acquire-a-let-s-encrypt-certificate-using-dns-validation-with-certbot-dns-digitalocean-on-ubuntu-20-04).

- Install Certbot on Ubuntu 20.04 box:
```
sudo apt update
sudo apt install certbot
certbot --version
certbot 0.40.0      # Output
```

- Configure Certbot
```
sudo apt install python3-certbot-dns-digitalocean
mkdir acme ; cd acme
touch certbot-creds.ini
chmod go-rwx certbot-creds.ini
vi certbot-creds.ini # Add Digital Ocean Access token in one line
# dns_digitalocean_token = your_digitalocean_access_token
```

- Issue a regular SSL certificate 

```
sudo certbot certonly --dns-digitalocean --dns-digitalocean-credentials certbot-creds.ini -d your_domain \
-d subdomain.your_domain # Optionally use: --dns-digitalocean-propagation-seconds 30

Cert and key will be placed at:
/etc/letsencrypt/live/your_domain/fullchain.pem
/etc/letsencrypt/live/your_domain/privkey.pem
```
You can now take above pair and use it wherever needed, not just within the Ubuntu server itself. 

- Issue a wildcard certificate
```
sudo certbot certonly --dns-digitalocean --dns-digitalocean-credentials certbot-creds.ini -d \*.your_domain
```

- Renew an existing certificate 

```
sudo systemctl status certbot.timer  # To check that the automatic renew schedule is running
                                     # If it's running, you should be able to check for latest certs at:
/etc/letsencrypt/live/your_domain/fullchain.pem
/etc/letsencrypt/live/your_domain/privkey.pem

sudo certbot renew                   # To do manually
sudo certbot renew --dry-run         # For testing
```

## ED25519 SSH Key
The Ed25519 key type is the latest, and according to most security experts, the best option. To generate a key run:

```
ssh-keygen -o -a 200 -t ed25519 -f ~/.ssh/id_ed25519 -C "john@example.com"

ssh-keygen
	-t ed25519 - for greatest security (bits are a fixed size and -b flag will be ignored)
	-a 500 rounds (should be no smaller than 64, result in slower passphrase verification and \
           increased resistance to brute-force password cracking)
	-C "First.Last@somewhere.com" comment..
	-o Saves key in new ED25519 format rather than more compatible PEM Format. New format \
           increases resistance to brute-force password cracking but not support by OpenSSH prior to 6.5
```


## pfSense FreeBSD Firewall
- Download it 

```
curl -LO https://sgpfiles.pfsense.org/mirror/downloads/pfSense-CE-2.4.4-RELEASE-p3-amd64.iso.gz
curl -LO https://sgpfiles.pfsense.org/mirror/downloads/pfSense-CE-2.4.4-RELEASE-p3-amd64.iso.gz.sha256
shasum -a 256 pfSense-CE-2.4.4-RELEASE-p3-amd64.iso.gz
a4bac4b9cde96b1775141666f92b40992437303520a1bad2f2b8e7f50f775834  pfSense-CE-2.4.4-RELEASE-p3-amd64.iso.gz
gunzip pfSense-CE-2.4.4-RELEASE-p3-amd64.iso.gz
```

- Install however you like
```
VirtualBox
  bri 080027AE2F12
  int 08002772A7B0
```

- Confirm by checking <http://10.10.10.80:444/>


## pfSense Disk Addition
Add another disk to pfSense appliance.
```
camcontrol devlist [geom disk list]       # Show disks
gpart show                                # Show partitions
gpart destroy -F da0                      # Destroy existing content on disk da0 
gpart create -s gpt da0                   # Create a new GPT parition scheme
gpart add -t freebsd-zfs -l hddext da0    # Create new ZFS partition
echo 'aesni_load="YES"' >> /boot/loader.conf   # Enable AES accelerator
geli init -l 256 /dev/gpt/hddext               # Set up encryption [Enter new passphrase]
true >> /dev/da0                               # To sync with device (unplug/replugging also works)
geli attach /dev/gpt/hddext                    # Attach the provider [Enter passphrase]
geli status                                    # Should show ACTIVE
zpool create hddext /dev/gpt/hddext.eli        # Set up ZFS pool
zpool destroy hddext                           # If you need to recreate
zpool list | zpool status | zfs list hddext    # To confirm
ls -ltra /                                     # Disk should be mounted at /hddext
To reattach after reboot:
  geli attach /dev/gpt/hddext
  zfs mount -a
  zfs get mounted hddext
  zpool list
  zpool status
  cd /hddext
  ls -l
```


## pfSense Speed Tuning
To speed things up, maybe use `sysctl net.isr.dispatch=deferred`? [Need sources]


## pfSense Serial Connnection From macOS
- Download and install Prolific Serial USB extension for macOS
  - <https://prolificusa.com/product/pl2303gc-usb-full-uart-bridge-controller-gpio/>
- After you will see this device = `/dev/tty.usbserial-CSBFj19B616`
- Connect with screen at 115200

  - `screen /dev/tty.usbserial-CSBFj19B616 115200`
  - `Press Ctrl-A, Ctrl-\ to quit`


## Memorable Password Generation
To generate 4-word phrase memorable password use [pgen](https://github.com/git719/pgen):

```
$ pgen
stylus-unable-manmade-hatching
```

You can use `pgen 6` to generate 6-word prhases, and so on.

To check entropy of these passwords use GRC's Interactive Brute Force Password "Search Space" Calculator: <https://www.grc.com/haystack.htm>


## OpenSSL Commands
- Functions to list SAN SSL certs and expiry. Use in `.bashrc` or put in a dedicated bash script: 

```
certls() {
  [[ -z $1 ]] && echo "Usage: certls example.com:443" && return
  # NEED -CApath /usr/local/etc/openssl/cert.pem for MACOS
  echo -n | openssl s_client -CApath /usr/local/etc/openssl/cert.pem -connect $1 2>/dev/null | \
  openssl x509 -noout -text | grep DNS: | tr ',' '\n' | awk '{print $1}' | sed 's;DNS:;;'
}

certexp() {
  [[ -z $1 ]] && echo "Usage: certls example.com:443" && return
  echo -n | openssl s_client -connect $1 2>/dev/null | openssl x509 -noout -dates | tr '\n' ' '
  echo
}
```

**Commands:** 

```
VERIFY CRL AGAINST CA
openssl crl -in /var/lib/puppet/ssl/ca/ca_crl.pem -CAfile /var/lib/puppet/ssl/ca/ca_crt.pem
openssl crl -in /var/lib/puppet/ssl/crl.pem -CAfile /var/lib/puppet/ssl/ca/ca_crt.pem
openssl crl -in /var/lib/puppet/ssl/crl.pem -noout -text | grep -A2 Issuer
openssl crl -in /var/lib/puppet/ssl/ca/ca_crl.pem -noout -text | grep -A2 Issuer

SSL/TLS CERT TROUBLESHOOTING
openssl x509 -noout -modulus -in /config/ssl/ssl.crt/issues.mydomain.com.crt | openssl md5
openssl rsa -noout -modulus -in /config/ssl/ssl.key/issues.mydomain.com.key | openssl md5
openssl req -noout -modulus -in /config/ssl/ssl.csr/issues.mydomain.com.csr | openssl md5

CONVERT CER TO PEM
openssl x509 -inform DER -in cert.cer -out cert.pem

SHOW CERT CONTENT
openssl x509 -text -noout -in certificate.crt 
openssl x509 -text -noout -in /var/lib/puppet/ssl/ca/ca_crt.pem | grep -A3 "Valid"
        Validity
            Not Before: Dec  5 23:45:07 2014 GMT
            Not After : Dec  5 23:45:07 2019 GMT
        Subject: CN=Puppet CA: puppet.mydomain.com

CHECK A CSR
openssl req -noout -verify  -in this.csr
openssl req -noout -text    -in this.csr
openssl req -noout -subject -in this.csr
openssl req -noout -pubkey  -in this.csr

CHECK A PRIVATE KEY
openssl rsa -in privateKey.key -check
```


## Test Cert Against CA
```
echo -n | openssl s_client -connect ldap.mydomain.com:636 -CAfile ad-ca-root.crt -showcerts -state
echo -n | openssl s_client -connect puppet.mydomain.com:8140 -prexit
```


## Generate Self-Signed Cert Bash Script
This script should be placed in a code repo and just referenced here as an example 

```
#!/bin/bash
# gencert
# Generate a standard 10 year self-signed SSL cert. Also creates a CSR that can
# be used to purchase a proper cert from CAs such as Entrust, Verisign, etc.

FQDN=$1
[[ -z "$FQDN" ]] && printf "Usage: $0 <common-name>\n" && exit 0

# Required company cert info
COUNTRY="US"
STATE="NY"
LOC="New York"
ORG="My Org"
UNIT="My Unit"
printf "\nCOUNTRY=$COUNTY   STATE=$STATE   LOC=$LOC   ORG=$ORG   UNIT=$UNIT   DOMAIN=${FQDN}\n\n"

MSG="Proceed to create 1) a private key, 2) a 10-year self-signed cert, and 3) a CSR for domain '$FQDN'? Y/N "
read -p "$MSG" -n 1 && [[ ! $REPLY =~ ^[Yy]$ ]] && printf "\nAborted.\n" && exit 1

printf "\nGenerating private key, self-signed cert, and CSR ...\n\n"

openssl req -nodes -newkey rsa:2048 -keyout ${FQDN}.key -out ${FQDN}.csr -subj \
"/C=${COUNTRY}/ST=${STATE}/L=${LOC}/O=${ORG}/OU=${UNIT}/CN=${FQDN}"

openssl x509 -req -days 3650 -in ${FQDN}.csr -signkey ${FQDN}.key -out ${FQDN}.crt

printf "\n1) Now you can use below self-signed cert + private key,\n2) Or use below CSR to \
acquire a cert from a proper CA like Entrust, Verisign\n\n"

printf "\n${FQDN}.crt\n${FQDN}.key\n${FQDN}.csr\n\n"

exit 0
```


## Hashicorp Vault
Hashicorp Vault is as secret sharing and management tool:

- <https://www.vaultproject.io/>
- <https://github.com/hashicorp/vault>

- The vault binary can serve as both client and server


## Vault Common Commands
```
export VAULT_ADDR=https://vault.mydomain.com
vault kv get myfolder/mykey
vault kv list myfolder/mysubfolder/
```


## Vault Login
```
vault auth -method=ldap -address=https://vault.mydomain.com:443 username=user1
  Password (will be hidden):
  Successfully authenticated!
  token: 18ae280b-26d4-4776-46ee-f15fe2d14bfd
  token_duration: 2591999
  token_policies: [default unseal-user1]

vault read -address=https://vault.mydomain.com:443 /secret/unsealKey/user1
  Key             Value
  lease_duration  2592000
  value           9abaab6e3e8031cd09e3f172cbf87b0472e1e6efb58fcf82637d3d164aa4aa1c04

Created/provided public PGP key user1.key for Vault unsealing
  https://chiefy.github.io/using-pgp-keys-with-hashicorp-s-vault/
  gpg --export 6554E819 | base64 > user1.key
```


## Unseal Hashicorp Vault
```
cat input3.txt | xxd -r -p | gpg --decrypt   [OLD]
echo <keyvalue> | base64 -D > output.gpg     [NEW]
gpg --decrypt output.gpg
vault unseal -address=https://${INSTANCEID}.vault.mydomain.com:8200
```


## Vault Rekeying Effort
```
Find leader
  curl https://vault.mydomain.com/v1/sys/leader

1st Command
  vault rekey -address=https://i-02e60a85.vault.mydomain.com8200/ -key-shares=9 -key-threshold=2 \
-pgp-keys=user1.key,user2.key,user3.key,user4.key

2nd Command
  Just 1st 3 args from 1st command
```


## Access to Vault and Token for ServiceAppX
```
  Checkout vaul-policies repo

  Create policy file
    cat prod/myapp/myapp-notification-service.policy
    path "secret/myapp/mayapp-notification-service/*" {
      policy = "read"
    }

  Pushed to Vault via this Jenkins job: http://jenkins.mydomain.com/job/vault-sync-policies/
    Using my own Vault auth token

  Create app tokens
    vault token create -policy="lab_multi-tenant_prod" -orphan
```


## Vault Server Monitoring
- Reference <https://www.vaultproject.io/api/system/health.html> 

```
  Set up your config manager so each Vault instance runs Datadog check locally

    classes:
      - 'datadog_agent::integrations::http_check'
    datadog_agent::integrations::http_check::instances:
      - check-http-vault:
        sitename: 'check-http-quizpoll-admin'
        url: 'http://localhost:10540/'
        threshold: 5
        window: 3
        disable_ssl_validation: true
        http_response_status_code: '(200|429)'

  Using Managed Network monitor check on the 2 Vault instances
    curl https://instance-a.mydomain.com:8200/v1/sys/health   200  ACTIVE
    curl https://instance-b.mydomain.com:8200/v1/sys/health   429  STANDBY

  Unclear how to best monitor VIP/ELB
    curl https://vault.mydomain.com/v1/sys/health             200  OK
```


## Modern Web Authentication
Short summary of modern web application authentication using an indentity provider (IdP).

1. A "Trust Relationship" between the web app and the IdP must be set up before hand

2. When user attempts to access web app
   web app does a "redirect binding" to get a token from the IdP

3. Then the IdP does a "POST binding" to send the token to the web app
   NOTE: Step 2 and 3 are done via the user's browser session

4. The web app sends the user browser a cookie to maintain the session

**NOTES**
- Single Sign-On (SSO): When the IdP sends the user a cookie

- Multiple IdPs (Federation): Home Realm Discovery


## JSON Web Token
JSON Web Token (JWT) are an open, industry standard RFC7519 method for representing claims securely between two parties.

- See <https://jwt.io/>

- **IMPORTANT**: If you want to inspect an actual token, it is best to avoid using an online decoder. Instead, use a local tool like `pyjwt`, which can be installed with `pip install pyjwt`

- The Azure CLI tool is an example of an applications that uses JWT tokens. After doing `az login`, you can take a look at acquired token by checking the content of file `$HOME/.azure/accessToken.json`. You can even re-use that token within a python script utility, using someting like: 

```bash
az_token_file = os.environ['HOME'] + "/.azure/accessToken.json"
try:
    if os.path.exists(az_token_file) and os.path.getsize(az_token_file) > 0:
        with open (az_token_file) as f:
            tokens = json.load(f)
            for t in tokens:
                if t['_authority'].find(tenant) > 0
                    token = t
                    break
except Exception as e:
    pass
```

## ZIP Password Protection
```
zip -e  archive.zip <list_of_files>        # Files in current directory
zip -er archive.zip <directory> <file_n>   # Directory and files
```

