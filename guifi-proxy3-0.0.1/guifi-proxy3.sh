#!/bin/sh

#--- DEFAULT CONFIG ---
node=2619; # overwrite by config file
base_url='http://www.guifi.net'
passwd_dir='/etc/guifi-proxy3/'
passwd=${passwd_dir}'passwd'
passwd_md5=${passwd_dir}'passwd.md5'
tmp='/tmp/passwd'
tmp_md5='/tmp/passwd.md5'
tmp_web_md5='/tmp/passwd_web_md5.txt'
secs=$(expr $node % 160)
# Enable for Debian/Ubuntu 
reload='/etc/init.d/squid3 reload'
# Enable for Fedora/RedHat
#reload='service squid reload'
#--- END DEFAULT CONFIG ---

#--- LOAD CONFIG FILE ---
config='/etc/guifi-proxy3/config.sh'

if [ -f $config ]
  then
  . $config
fi
#--- END LOAD CONFIG FILE ---

# delay
sleep $secs

# Check if download passwd file is needed
# Download md5 checksum
wget $base_url/guifi/export/$node/federated_md5 -O $tmp_web_md5
# Calc md5sum of $passwd
touch $passwd
md5sum $passwd > $passwd_md5

# Compare checksums
hash_web=`cut -d" " -f1 $tmp_web_md5`
hash_passwd=`cut -d" " -f1 $passwd_md5`
#echo "md5=$hash_web="
#echo "md5=$hash_passwd="

if [ $hash_web != $hash_passwd ]; then
  echo "[`date -R`] - Different Hash, New Passwd File";
  wget $base_url/guifi/export/$node/federated -O $tmp
  md5sum $tmp > $tmp_md5
  hash_tmp=`cut -d" " -f1 $tmp_md5`  
  if [ $hash_web = $hash_tmp ]; then
    echo "[`date -R`] - Download OK, copying Passwd file to $passwd";
    cp $tmp $passwd
    rm $tmp
    rm $tmp_md5
    rm $tmp_web_md5
    $reload
  fi;  
fi;

exit 0;

