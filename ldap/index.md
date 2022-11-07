# LDAP
Useful LDAP tips.

## LDAP Search
User `ldapsearch` utility for common searches: 

```
# Show `mapping tree` configs
ldapsearch -h localhost -D "cn=Directory Manager" -y <PasswordFile> -b "cn=mapping tree,cn=config" -LLLo ldif-wrap=no

# Check replication status
ldapsearch -h localhost -D "cn=Directory Manager" -y <PasswordFile> -b "cn=mapping tree,cn=config" -LLLo ldif-wrap=no

# Grab all users
ldapsearch -x -H ldaps://ldap.mydomain.io -D "cn=Directory Manager" -w <Password> -b dc=mydomain,dc=com -LLLo ldif-wrap=no

# Grab all groups
ldapsearch -H ldaps://ldap.mydomain.com -D "mydomain\user1" -b "OU=LabAuthGroup,OU=Groups,OU=MyDomain Users,DC=mydomain,DC=com" -W displayName managedBy member -LLLo ldif-wrap=no'
```

## LDAP Modify
Initialize a replication agreement: 

```
ldapmodify -h localhost -D "cn=Directory Manager" -y pwdfile -v
dn: cn=ReplicationAgreement,cn=replica,cn=dc\=mydomain\,dc\=com,cn=mapping tree,cn=config
changetype: modify
replace: nsds5BeginReplicaRefresh
nsds5BeginReplicaRefresh: start
CTRL-D
```

## Linux SSSD Client
Configure Linux SSSD client to use TLS LDAP: 

```
yum -y install sssd
authconfig --enablesssd --enablesssdauth --ldapserver=ldaps://ldap.mydomain.io --ldapbasedn=dc=mydomain,dc=com --enablerfc2307bis --updateall
vi /etc/sssd/sssd.conf   # and put necessary content (see sample file below)
chmod 600 /etc/sssd/sssd.conf
service sssd restart
# Copy self-signed CA cert from one of the servers to a client:
cp ca.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust
# For SSH access, ensure sssd.conf has 'ssh' as one of the services
  [sssd]
  services = nss, pam, ssh, sudo
# Ensure /etc/ssh/sshd_config has these two directives defined
  AuthorizedKeysCommand /usr/bin/sss_ssh_authorizedkeys
  AuthorizedKeysCommandUser root
# Test
  id userid
  ssh user@client
```

- Sample `/etc/sssd/sssd.conf`: 

```
[sssd]
services = nss, pam, ssh
config_file_version = 2
domains = LDAP

[nss]
filter_users = root,ldap,named,avahi,haldaemon,dbus,radiusd,news,nscd
override_homedir = /tmp

[pam]
reconnection_retries = 3
offline_credentials_expiration = 2
offline_failed_login_attempts = 3
offline_failed_login_delay = 5

[domain/LDAP]
auth_provider = ldap
cache_credentials = true
chpass_provider = ldap
entry_cache_timeout = 600
id_provider = ldap
ldap_chpass_uri = ldaps://ldap.mydomain.vm
ldap_group_member = uniquemember
ldap_id_use_start_tls = false
ldap_network_timeout = 3
ldap_schema = rfc2307bis
ldap_search_base = dc=mydomain,dc=com
ldap_tls_cacertdir = /etc/openldap/cacerts  # ??? Not the default ???
ldap_tls_reqcert = never
ldap_uri = ldaps://ldap.mydomain.vm
```

## LDAP SSH-Key-Based Logon
To setup LDAP SSH-Key-Based logon.
- Extend LDAP schema by adding this file, and restarting: 

```
cat /etc/dirsrv/slapd-ldap1/schema/60sshlpk.ldif
# 60sshlpk.ldif
# ldapPublicKey
#
# LDAP Public Key Patch schema for use with openssh-ldappubkey
#                              useful with PKA-LDAP also
#
# Author: Eric AUGE <eau@phear.org>
#
# Based on the proposal of : Mark Ruijter
#
################################################################################
#
dn: cn=schema
#
################################################################################
#
attributeTypes: (
  1.3.6.1.4.1.24552.500.1.1.1.13
  NAME 'sshPublicKey'
  DESC 'MANDATORY: OpenSSH Public key'
  EQUALITY octetStringMatch
  SYNTAX 1.3.6.1.4.1.1466.115.121.1.40
  )
#
################################################################################
#
objectClasses: (
  1.3.6.1.4.1.24552.500.1.1.2.0
  NAME 'ldapPublicKey'
  SUP top
  AUXILIARY
  DESC 'MANDATORY: OpenSSH LPK objectclass'
  MUST ( sshPublicKey $ uid )
  )
#
################################################################################
#
```

- Then add these attribute entries to each individual account: 

```
objectClass: ldapPublicKey
sshPublicKey: ssh-rsa AAAA....Cn0bw==  # Shortened
```

