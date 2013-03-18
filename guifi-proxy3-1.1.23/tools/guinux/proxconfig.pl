#!/usr/bin/perl
#
# set the proxy configuration
#

$oldfile = "/etc/guifi-proxy3/config.sh.guinux";
$newfile = "/etc/guifi-proxy3/config.sh";
$oldid = "%PROXId%";
$oldurl = "%PROXUrl%";
$oldldap_main= "%LDAP_MAIN%";
$oldldap_backup= "%LDAP_BACKUP%";
$oldrealm= "%REALM%";
$oldmanager= "%MANAGER%";
$oldlanguage= "%LANGUAGE%";
$oldcache_size= "%CACHE_SIZE%";
$oldcache_mem= "%CACHE_MEM%";
$defurl = "http://guifi.net";
$defid = "2624";
$defldap_main= "ldap.guifi.net";
$defldap_backup= "ldap2.guifi.net";
$defrealm = "Guifi-server Squid proxy-caching web server";
$defmanager = "webmaster\@localhost";
$deflanguage = "Catalan";
$defcache_size = "10240";
$defcache_mem = "100";

print "Without ending backslash, Enter the url where the data is. [$defurl]";
$newurl = <STDIN>;
chomp($newurl);
if ($newurl eq "") { $newurl=$defurl; }

print "Enter the number of the Proxy Service Id [$defid]: ";
$newid = <STDIN>;
chomp($newid);
if ($newid eq "") { $newid=$defid; }

print "Enter the main ldap server [$defldap_main]: ";
$newldap_main = <STDIN>;
chomp($newldap_main);
if ($newldap_main eq "") { $newldap_main=$defldap_main; }

print "Enter the backup ldap server [$defldap_backup]: ";
$newldap_backup = <STDIN>;
chomp($newldap_backup);
if ($newldap_backup eq "") { $newldap_backup=$defldap_backup; }

print "Enter a Proxy Name/Realm[$defrealm]: ";
$newrealm = <STDIN>;
chomp($newrealm);
if ($newrealm eq "") { $newrealm=$defrealm; }

print "Enter e-mail address from administrator[$defmanager]: ";
$newmanager = <STDIN>;
chomp($newmanager);
if ($newmanager eq "") { $newmanager=$defmanager; }

print "Enter the default show errors language [$deflanguage]: ";
$newlanguage = <STDIN>;
chomp($newlanguage);
if ($newlanguage eq "") { $newlanguage=$deflanguage; }

print "Enter the default cache size in MB ( Megabytes ) [$defcache_size]: ";
$newcache_size = <STDIN>;
chomp($newcache_size);
if ($newcache_size eq "") { $newcache_size=$defcache_size; }

print "Enter the default cache memory in MB ( MegaBytes) [$defcache_mem]: ";
$newcache_mem = <STDIN>;
chomp($newcache_mem);
if ($newcache_mem eq "") { $newcache_mem=$defcache_mem; }

open(OF, $oldfile) or die "Can't open $oldfile : $!";
open(NF, ">$newfile") or die "Can't open $newfile : $!";

# read in each line of the file
while ($line = <OF>) {
    $line =~ s/$oldurl/$newurl/;
    $line =~ s/$oldid/$newid/;
    $line =~ s/$oldldap_main/$newldap_main/;
    $line =~ s/$oldldap_backup/$newldap_backup/;
    $line =~ s/$oldrealm/$newrealm/;
    $line =~ s/$oldmanager/$newmanager/;
    $line =~ s/$oldlanguage/$newlanguage/;
    $line =~ s/$oldcache_size/$newcache_size/;
    $line =~ s/$oldcache_mem/$newcache_mem/;
    print NF $line;
}

close(OF);
close(NF);
print "Please wait..\n";
`/usr/share/guifi-proxy3/guifi-proxy3.sh >> /var/log/guifi-proxy3/guifi-proxy3.log 2>&1;`;
print "Successful: New Proxy Server Url ($newurl) and Id ($newid) has been set\n";
print "Done\n. Press <Enter> to finalize.";
$end = <STDIN>;


