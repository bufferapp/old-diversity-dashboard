#!/bin/sh
### In rserver.sh (make sure this file is chmod +x):
# `/sbin/setuser xxxx` runs the given command as the user `xxxx`.
# If you omit that part, the command will be run as root.

exec start-stop-daemon --start --quiet --pidfile /var/run/shiny-server.pid --make-pidfile  --exec /usr/bin/shiny-server >>/var/log/shiny-server.log 2>&1
