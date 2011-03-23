#
# Regular cron jobs for the guifi-proxy3 package
#
55 *	* * *	root	/usr/share/guifi-proxy3/guifi-proxy3.sh >> /var/log/guifi-proxy3/guifi-proxy3.log 2>&1;
