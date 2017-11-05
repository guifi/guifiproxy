#!/bin/bash

restart="/usr/sbin/service squid restart"
reload="/usr/sbin/service squid reload"


if [ "$(pidof squid)" ]
then
  eval $reload
else
  eval $restart
fi

