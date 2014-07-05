#!/bin/bash

restart="/usr/sbin/service squid3 restart"
reload="/usr/sbin/service squid3 reload"


if [ "$(pidof squid3)" ]
then
  eval $reload
else
  eval $restart
fi

