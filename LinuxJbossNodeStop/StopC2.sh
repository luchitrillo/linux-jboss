#!/bin/bash
#StopC2.sh

CAMPUS="campus2"
PORT="1199"
IP="10.168.3.15"
ADMIN="admin"
PASS=$(grep admin= /usr/local/jboss/server/${CAMPUS}/conf/props/jmx-console-users.properties | cut -d'=' -f 2)

if [ $(whoami) != "jboss" ]
then
    echo "[ Sólo el usuario jboss puede detener la instancia ]"
    exit
fi

echo "";echo "[ Deteniendo instancia '${CAMPUS}' ]";echo "";
/usr/local/jboss/bin/shutdown.sh -s jnp://${IP}:${PORT} -u ${ADMIN} -p ${PASS}

tailf /usr/local/jboss/server/${CAMPUS}/log/server.log | while read line
do
	echo $line | grep "Shutdown complete"
		if [ "$?" -eq "0" ]; then
		echo "";echo "[ Instancia '${CAMPUS}' detenida ]";echo "";
		kill -2 -$$
	fi  
done