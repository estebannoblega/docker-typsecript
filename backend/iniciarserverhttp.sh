#!/bin/bash

#Defino el nombre del contenedor
CONTAINER="entornodocker-backend-1"

#Inicio el contenedor
docker start $CONTAINER

#Espero que se inicie por las dudas
sleep 2

#Ejecuto el comando para inicar node del proyecto

docker exec -d $CONTAINER npm run dev
