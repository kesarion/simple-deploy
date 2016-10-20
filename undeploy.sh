#!/bin/bash

# stopping, disabling and removing service configuration; removing nginx configuration and reloading

for APP in "$@"
do
	NAME=$(basename $APP)
	
	echo "Undeploying $NAME"

	echo $(systemctl stop "$NAME.service")
	echo $(systemctl disable "$NAME.service")
	echo $(rm -rf "/etc/systemd/system/$NAME.service")
	echo $(rm -rf "/etc/nginx/conf.d/$NAME.conf")
	echo $(nginx -s reload)
done

echo "Done!"
