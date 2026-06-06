#!/bin/sh
cd /data
echo eula=true > eula.txt
java -Xmx4G -Xms4G -jar /opt/minecraft/minecraft_server.jar nogui
