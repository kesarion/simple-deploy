# simple-deploy
Deploy a node app using nginx and systemd (i.e. connect a node app running on a local port to a domain and handle app relaunch on system restart or app crash)

Plus some extra scripts to undeploy and install/uninstall a service (if that's all you need).

# Usage

#### deploy.sh
```
./deploy.sh -a /path/to/app -p PORT

	-a, --app: absolute path to your node app dir; the directory name should be the app's hostname for nginx integration (e.g. domain.com); should contain an index.js; single .js files are not supported, use a dir with index.js inside;
	-p, --port: the port the app will be running on;
```

> Notes
> - the script must be executable `chmod u+x deploy.sh`
> - node must be installed and available at path: `/usr/bin/node`
> - nginx must be installed and the nginx service must be enabled and started:
>
> `systemctl enable nginx`
> &&
> `systemctl start nginx`

#### undeploy.sh
```
./undeploy.sh /path/to/app1 /path/to/app2 /path/to/app3
```

#### install_service.sh
```
./install_service.sh /path/to/app1 /path/to/app2 /path/to/app3
```

#### uninstall_service.sh
```
./uninstall_service.sh /path/to/app1 /path/to/app2 /path/to/app3
```
