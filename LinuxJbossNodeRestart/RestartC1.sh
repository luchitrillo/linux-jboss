#!/bin/bash
#RestartC1.sh

CAMPUS="campus1"
CAMPUS_PATH="/usr/local/jboss/server/${CAMPUS}"
DIRNAME=$(dirname ${0})
SCRIPT_PATH=$(cd ${DIRNAME}; pwd)
PORT="1099"
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
		
		init_message() {
			echo "";echo -n "[ La instancia '${CAMPUS}' se esta iniciando ]";echo "";
		}

		running_message() {
			echo "";echo "[ Ya existe una instancia '${CAMPUS}' corriendo, PID=${PID} ]";echo "";
			#echo "";echo "[ Para detenerla: /usr/local/jboss/bin/stop_${CAMPUS} ]";echo "";
		}

		run() {
			#SSL - HTTPS
			JBOSS_OPTS="${JBOSS_OPTS} -c ${CAMPUS}"
			JBOSS_OPTS="${JBOSS_OPTS} -b 10.168.3.15"
			JBOSS_OPTS="${JBOSS_OPTS} -Djava.awt.headless=true"
			JBOSS_OPTS="${JBOSS_OPTS} -g PPEXAMENESPartition"
			JBOSS_OPTS="${JBOSS_OPTS} -u 239.1.2.9"
			JBOSS_OPTS="${JBOSS_OPTS} -Djgroups.bind_addr=10.5.5.15"
			JBOSS_OPTS="${JBOSS_OPTS} -Djboss.service.binding.set=ports-default"
			JBOSS_OPTS="${JBOSS_OPTS} -Djboss.messaging.ServerPeerID=1"
			#${SCRIPT_PATH}/run.sh ${JBOSS_OPTS} &>> ${SCRIPT_PATH}/${CAMPUS}_init.log &
			${SCRIPT_PATH}/run.sh ${JBOSS_OPTS} &>> ${CAMPUS}_init.log &
			disown
			init_message
		}
		
		sleep 5

		if [ $(whoami) != "jboss" ]
		then
			echo "[ Sólo el usuario jboss puede iniciar la instancia ]"
			exit
		fi

		PID=$(pgrep -f 'jboss.Main -c campus1')
		if [ -z "$PID" ]
		then
			${SCRIPT_PATH}/Limpiar_tmp_work_Nodo1.sh
			source ${SCRIPT_PATH}/common.conf
			JAVA_OPTS="-server -Xms3g -Xmx3g"
			JAVA_OPTS="${JAVA_OPTS} -XX:PermSize=1024m -XX:MaxPermSize=1024m -XX:NewSize=1024m -XX:MaxNewSize=1024m"
			JAVA_OPTS="${JAVA_OPTS} -XX:SurvivorRatio=32 -XX:+UseTLAB -XX:TLABSize=64K -XX:ReservedCodeCacheSize=128m -XX:LargePageSizeInBytes=4m -verbose:gc -Xloggc:logs/gc.log.`date +%Y%m%d%H%M%S`"
			JAVA_OPTS="${JAVA_OPTS} -XX:+UseParNewGC -XX:-UseSpinning -XX:+UseLargePages -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled"
			JAVA_OPTS="${JAVA_OPTS} -XX:+DoEscapeAnalysis -XX:+UseCompressedOops -XX:TargetSurvivorRatio=90 -XX:+ExplicitGCInvokesConcurrent"
			JAVA_OPTS="${JAVA_OPTS} -XX:CMSInitiatingOccupancyFraction=80 -XX:CMSIncrementalSafetyFactor=20 -XX:+UseCMSInitiatingOccupancyOnly"
			JAVA_OPTS="${JAVA_OPTS} -XX:MaxTenuringThreshold=32 -XX:+PrintGCDetails -XX:+PrintGCTimeStamps"
			JAVA_OPTS="${JAVA_OPTS} -Dsun.rmi.dgc.client.gcInterval=1800000 -Dsun.rmi.dgc.server.gcInterval=1800000"
			JAVA_OPTS="${JAVA_OPTS} -Dorg.jboss.resolver.warning=true -Dsun.lang.ClassLoader.allowArraySyntax=true"
			JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.authenticate=false"
			JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
			JAVA_OPTS="${JAVA_OPTS} -Djboss.jgroups.udp.mcast_port=27470 -Djboss.messaging.datachanneludpport=47470"
			JAVA_OPTS="${JAVA_OPTS} -Dorg.apache.tomcat.util.http.Parameters.MAX_COUNT=10000"
			export JAVA_OPTS
			run
		else
			running_message
			exit
		fi

		tailf /usr/local/jboss/server/${CAMPUS}/log/server.log | while read line
		do
			echo $line | grep "Started in"
				if [ "$?" -eq "0" ]; then
				echo "";echo "[ Instancia '${CAMPUS}' iniciada ]";echo "";
				kill -2 -$$
			fi  
		done
	fi  
done
