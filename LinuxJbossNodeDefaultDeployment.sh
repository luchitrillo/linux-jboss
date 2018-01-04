#!/bin/bash

#GLOBAL-VARIABLES
NEXUS="XXX"
NEXUSUSER="XXX"
NEXUSPASS="XXX"
ARTIFACT="XXX"
DESTINY="XXX"
SYNC="XXX"
RESTART="XXX"
IP="###.###.###.###"
SERVER="XXX"


#CHECK-JBOSS-USER
if [ $(whoami) != "jboss" ]
then
    echo "";"[ Sólo el usuario 'jboss' puede correr el script ]"; echo "";
    exit
fi

#WGET-ARTIFACT
wget --directory-prefix=/usr/local/Implementaciones/PreProduccion --user ${NEXUSUSER} --password ${NEXUSPASS} ${NEXUS}
echo ""; echo "[ Artefacto '${ARTIFACT}' obtenido desde el repositorio]"; echo "";

#REPLACE-ARTIFACT
mv /usr/local/Implementaciones/PreProduccion/${ARTIFACT} ${DESTINY}
echo ""; echo "[ Artefacto '${ARTIFACT}' reemplazado y listo para sincronizar]"; echo "";

#SYNC-ARTIFACT
echo ""; echo "[ Artefacto '${ARTIFACT}' en proceso de sincronización ]"; echo "";
${SYNC}
echo ""; echo "[ Artefacto '${ARTIFACT}' sincronizado con el servidor '${SERVER}']"; echo "";

#RESTART-NODES
echo ""; echo "[ Reiniciando nodos contenedores del artefacto '${ARTIFACT}' en el servidor '${SERVER}']"; echo "";
ssh jboss@${IP} /usr/local/jboss/bin/${RESTART}
echo ""; echo "[ Despliegue finalizado ]"; echo "";
