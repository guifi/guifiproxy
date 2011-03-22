#
# Regular cron jobs for the guifi-proxy3 package
#
55 *	* * *	root	/usr/share/guifi-proxy/guifi-proxy.sh >> /var/log/guifi-proxy/guifi-proxy.log 2>&1;
