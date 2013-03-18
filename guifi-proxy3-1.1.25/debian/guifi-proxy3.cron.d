#
# Regular cron jobs for the guifi-proxy3 package
#
0,30 * * * *	root	/usr/share/guifi-proxy3/guifi-proxy3.sh >> /var/log/guifi-proxy3/guifi-proxy3.log 2>&1;
05 4 * * 1	root	/usr/share/guifi-proxy3/squid_cache >> /var/log/squid3/squid_cache.log 2>&1;
