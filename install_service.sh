#!/bin/bash

# configure, enable and start node app services; use space separated paths to their respective node app dirs

for APP in "$@"
do
	NAME=$(basename $PROJECT_PATH)
	
	echo "Installing service for $NAME"
	
	SERVICE="
	[Unit]
	Description=node service at path: $APP

	[Service]
	ExecStart=/usr/bin/node $APP
	Restart=always
	RestartSec=10         # Restart service after 10 seconds if nodemon crashes
	StandardOutput=syslog # Output to syslog
	StandardError=syslog  # Same
	SyslogIdentifier=$NAME

	[Install]
	WantedBy=multi-user.target
	"
	
	FILE="/etc/systemd/system/$NAME.service"
	
	[ -e "$FILE" ] || touch "$FILE"
	
	echo "$SERVICE" > "$FILE"
	
	echo $(systemctl enable "$NAME.service")

	echo $(systemctl start "$NAME.service")
done

echo "Done!"
