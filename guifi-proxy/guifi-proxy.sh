#!/bin/sh
#--- CONFIG ---
node=4282;
passwd_dir=/tmp/etc/
passwd=${passwd_dir}passwd
tmp=/tmp/passwd
# Debian/Ubuntu Reload
reload='/etc/init.d/squid reload'
# Fedora/RedHat Reload
#reload='service squid reload'

#--- END CONFIG ---
wget http://www.guifi.net/guifi/export/$node/federated -qO $tmp
touch $passwd

NEW=`diff $passwd $tmp|wc -l`
echo $NEW
OK=`grep Federated $tmp|wc -l`

if [ $OK != "0" ]; then
 if [ $NEW != "0" ]; then
    cp $tmp $passwd_dir
    $reload
    echo "Nou $passwd copiat"
 fi;
fi
