#!/bin/bash

#--- DEFAULT CONFIG ---
node=2619; # overwrite by config file
base_url='http://www.guifi.net'
tmp='/tmp/federation_list'
ldap_main="ldap.guifi.net"
ldap_backup="ldap2.guifi.net"
# Enable for Debian/Ubuntu
restart="/usr/sbin/service squid3 restart"
reload="/usr/sbin/service squid3 reload"
# Enable for Fedora/RedHat
#--- END DEFAULT CONFIG ---

#--- LOAD CONFIG FILE ---
config='/etc/guifi-proxy3/config.sh'

if [ -f $config ]
  then
  . $config
fi
#--- END LOAD CONFIG FILE ---

HEADER="# /etc/squid3/guifi.conf
# This file contains the configurations generated during installation
# The cron daemon, periodically update this configuration for squid. When that happens, this file is deleted and completely regenerates.
# You should not add custom settings in this file, use the file named /etc/squid3/custom.conf for it.
#
# General"

DEFCONF="
# acl
acl to_privada_deny dst 192.168.0.0/16 172.16.0.0/16
acl usuaris_autenticats proxy_auth REQUIRED
http_access deny to_privada_deny
http_access allow usuaris_autenticats

## CACHE CONFIG
hierarchy_stoplist cgi-bin ? gmail yahoo terra hotmail webmail inicia ya hispavista
cache_swap_low 90
cache_swap_high 95
maximum_object_size 20480 KB
# logs
access_log /var/log/squid3/access.log squid
cache_log /var/log/squid3/cache.log
## special config with postinst
cache_mem $cache_mem MB
cache_dir ufs /var/spool/squid3 $cache_size 32 512
auth_param basic realm $realm
cache_mgr $manager
error_directory /usr/share/squid3/errors/$language"

# check if ldap servers are up and running
if (nc -zw2 $ldap_main 636); then
  ldap1="up"
else
  ldap1="down"
fi

if (nc -zw2 $ldap_backup 636); then
  ldap2="up"
else
  ldap2="down"
fi

# set active ldap server
if [ $ldap1 == "up" ]; then
  ldap_server="$ldap_main"
  ldap_KO="false"
else
  echo "LDAP main server: $ldap_main is KO!"
  if [ $ldap2 == "up" ]; then
    ldap_server="$ldap_backup"
    ldap_KO="false"
  else
    echo "LDAP backup server: $ldap_backup is KO!"
    # can't connect to ldap servers! probably networking is down, re check at next cron time.
    ldap_KO="true"
  fi
fi

# check if base_url is up and running
url=$(echo $base_url | sed -e s,'http://',,g)
if (nc -zw2 $url 80); then
  pidserver="up"
  # Get proxy list and federation
  wget --no-cache $base_url/guifi/export/$node/federation -O $tmp -q
else
  pidserver="down"
  # can't get new federation file
  if [ $ldap_KO == "true" ]; then
    echo "LDAP servers: $ldap_main, $ldap_backup and Proxy ID webserver: $base_url are DOWN!! Aborting reload, probably networking is down, re check at next cron time."
    exit
  fi
fi

# Check own federation ( first line )
proxy=$(/bin/sed q "$tmp")
set -- "$proxy"
IFS="-"; declare -a Type=($*)
pid="${Type[0]}"
own="${Type[1]}"
OFS=$IFS

# check allowed federations
IFS='-'
group_allow="$pid"
group_deny="0"
while read p1 p2
do
  if [[ "$own" == "private" ||  "$own" == "out" ]]; then
    echo "$HEADER" > /etc/squid3/guifi.conf
    echo "# Proxy-id: $pid Federation: $own
# Ldap auth
auth_param basic program /usr/lib/squid3/squid_ldap_auth -v 3 -b \"ou=$pid,o=proxyusers,dc=guifi,dc=net\" -H ldaps://$ldap_server/ -f \"uid=%s\" -D \"uid=proxyldap2011,o=proxyusers,dc=guifi,dc=net\" -w \"proxyaproxy2011\"
auth_param basic credentialsttl 2 hours
auth_param basic children 5
" >> /etc/squid3/guifi.conf
    echo "$DEFCONF" >> /etc/squid3/guifi.conf
    exit
  else
    # if own proxy accept federated users create federated proxy-id list.
    if [ "$p1" != "$pid" ] && [[ "$own" == "inout" || "$own" == "in" ]]; then
      if [ "$p2" == "inout" ] || [ "$p2" == "out" ]; then
        group_allow="$group_allow,$p1"
      else
        group_deny="$group_deny,$p1"
      fi
    fi
  fi
OFS=$IFS
done < $tmp

echo "$HEADER" > /etc/squid3/guifi.conf
echo "# Proxy-id: $pid Federation: $own
# Ldap auth
auth_param basic program /usr/lib/squid3/squid_ldap_auth -v 3 -b \"o=proxyusers,dc=guifi,dc=net\" -H ldaps://$ldap_server/ -f \"uid=%s\" -D \"uid=proxyldap2011,o=proxyusers,dc=guifi,dc=net\" -w \"proxyaproxy2011\"
auth_param basic credentialsttl 2 hours
auth_param basic children 5
# Ldap group auth ( group=proxy-id ou=XXXX)
external_acl_type ldap-group %LOGIN /usr/lib/squid3/squid_ldap_group -v 3 -b \"o=proxyusers,dc=guifi,dc=net\" -f (&(\"ou=%g\")(\"uid=%u\")) -h ldaps://$ldap_server/ -D \"uid=proxyldap2011,o=proxyusers,dc=guifi,dc=net\" -w \"proxyaproxy2011\"
" >> /etc/squid3/guifi.conf

IFS=","
COUNT=0
G_COUNT=0
ACCESS="http_access allow AllowFedOut"
ACLS="## Allow users from these proxy-id: (splitted acl's! 40 proxy-id by acl)
acl AllowFedOut$G_COUNT external ldap-group"
for WORD in $group_allow
do
  if [ $COUNT -lt 40 ]; then
    ACLS="$ACLS $WORD"
  else
    ACLS="$ACLS\n$ACCESS$G_COUNT"
    COUNT=0
    let G_COUNT=G_COUNT+1
    ACLS="$ACLS\nacl AllowFedOut$G_COUNT external ldap-group $WORD"
  fi
  let COUNT=COUNT+1
done
ACLS="$ACLS\n$ACCESS$G_COUNT"
echo -e "$ACLS" >> /etc/squid3/guifi.conf
OFS=$IFS

IFS=","
COUNT=0
G_COUNT=0
ACCESS="http_access deny DenyFedOut"
ACLS="
# Deny users from these proxy-id: (splitted acl's! 40 proxy-id by acl)
acl DenyFedOut$G_COUNT external ldap-group"
for WORD in $group_deny
do
  if [ $COUNT -lt 40 ]; then
    ACLS="$ACLS $WORD"
  else
    ACLS="$ACLS\n$ACCESS$G_COUNT"
    COUNT=0
    let G_COUNT=G_COUNT+1
    ACLS="$ACLS\nacl DenyFedOut$G_COUNT external ldap-group $WORD"
  fi
  let COUNT=COUNT+1
done
ACLS="$ACLS\n$ACCESS$G_COUNT"
echo -e "$ACLS" >> /etc/squid3/guifi.conf
OFS=$IFS

echo -e "$DEFCONF" >> /etc/squid3/guifi.conf

if [ -f /tmp/guifi-proxy3.crontrol ]
then
	eval $restart
else
        eval $reload
fi

