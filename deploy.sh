#!/bin/bash

# GET ARGUMENTS

getopt --test > /dev/null
if [[ $? != 4 ]]; then
    echo "I’m sorry, `getopt --test` failed in this environment."
    exit 1
fi

SHORT=a:p:h
LONG=app:,port:,help

# -temporarily store output to be able to check for errors
# -activate advanced mode getopt quoting
# -pass arguments via   -- "$@"   to separate them correctly
PARSED=`getopt --options $SHORT --longoptions $LONG --name "$0" -- "$@"`
if [[ $? != 0 ]]; then
    #  then getopt has complained about wrong arguments to stdout
    exit 2
fi
# use eval with "$PARSED" to properly handle the quoting
eval set -- "$PARSED"

# now enjoy the options in order and nicely split until we see --
while true; do
    case "$1" in
        -a|--app)
            APP="$2"
            shift 2
            ;;
	    -p|--port)
	        PORT="$2"
	        shift 2
	        ;;
		-h|--help)
			HELP=true
		    shift
		    ;;
        --)
            shift
            break
            ;;
        *)
            echo "Error"
            exit 3
            ;;
    esac
done

# VALIDATE ARGUMENTS

if [[ $HELP ]]; then
	echo "Deploy a node app using nginx and systemd (i.e. connect a node app running on a local port to a domain and handle app relaunch on system restart and crash).
	
	Usage: ./deploy.sh -a /path/to/app -p PORT
	
	-a, --app: path to your node app dir; dir name should be the domain and tld: domain.tld; dir should contain an index.js; files are not supported;
	-p, --port: the port the app will be running on;
	
	Notes:
	node must be installed and available at path: /usr/bin/node
	nginx must be installed and the nginx service must be enabled and started:
	systemctl enable nginx
	systemctl start nginx
	"
	exit 0
fi

if [ -z ${APP+x} ]; then
	echo "Node app path not set!
	
	Usage: ./deploy.sh -a /path/to/app -p PORT
	
	-a, --app: path to your node app dir; dir name should be the domain and tld: domain.tld; dir should contain an index.js; files are not supported;
	-p, --port: the port the app will be running on;
	"
	exit 1
fi

if [ -z ${PORT+x} ]; then
	echo "Port not set!
	
	Usage: ./deploy.sh -a /path/to/app -p PORT
	
	-a, --app: path to your node app dir; dir name should be the domain and tld: domain.tld; dir should contain an index.js; files are not supported;
	-p, --port: the port the app will be running on;
	"
	exit 1
fi

# NAME :)

NAME=$(basename $APP)

# NGINX CONFIGURATION

echo "Configuring nginx for: $NAME"

NGINX_CONF="server {
    listen 80;

    server_name $NAME www.$NAME;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
"

NGINX_CONF_FILE="/etc/nginx/conf.d/$NAME.conf"

[ -e "$NGINX_CONF_FILE" ] || touch "$NGINX_CONF_FILE"

echo "$NGINX_CONF" > "$NGINX_CONF_FILE"

echo $(nginx -s reload)

# SYSTEMD CONFIGURATION

echo "Installing service for: $NAME"

SERVICE="[Unit]
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

SERVICE_FILE="/etc/systemd/system/$NAME.service"

[ -e "$SERVICE_FILE" ] || touch "$SERVICE_FILE"

echo "$SERVICE" > "$SERVICE_FILE"

echo $(systemctl enable "$NAME.service")

echo $(systemctl start "$NAME.service")

# DONE!

echo "Done!"
