#
# Regular cron jobs for the guifi-proxy3 package
#
0 4	* * *	root	[ -x /usr/bin/guifi-proxy3_maintenance ] && /usr/bin/guifi-proxy3_maintenance
