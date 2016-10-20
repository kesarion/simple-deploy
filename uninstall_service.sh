#!/bin/bash

#!/bin/bash

# stopping, disabling and removing service configuration

for APP in "$@"
do
	NAME=$(basename $APP)

	echo "Uninstalling $NAME"

	echo $(systemctl stop "$NAME.service")
	echo $(systemctl disable "$NAME.service")
	echo $(rm -rf "/etc/systemd/system/$NAME.service")
done

echo "Done!"
