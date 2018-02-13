#!/usr/bin/env bash

service rsyslog restart
service php7.2-fpm restart
service nginx restart
service mysql restart
service cron restart

tail -f /dev/null

exit $?
