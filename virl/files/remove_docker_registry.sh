#!/bin/sh
stop_image() {
    IMAGE_NAME=$1
    CONTAINER_IDS=`docker ps -a | grep "$IMAGE_NAME" | awk '{ print $1 }'`
    if [ -n "$CONTAINER_IDS" ]; then
        for CONTAINER_ID in $CONTAINER_IDS; do
            docker stop $CONTAINER_ID || true
            docker rm $CONTAINER_ID
        done
    fi
    docker rmi $IMAGE_NAME
}

# remove registry:TAG images
RUNNING_REGISTRY=`docker ps -a | egrep -o 'registry:[^ ]+'`
if [ -n "$RUNNING_REGISTRY" ]; then
    for IMAGE_NAME in $RUNNING_REGISTRY; do
        stop_image $IMAGE_NAME
    done
fi
# remove everything on our IP:PORT
RUNNING_REGISTRY=`docker ps | grep "$REGISTRY_IP:$REGISTRY_PORT->5000/tcp" | awk '{ printf("%s:%s", $1, $2) }'`
if [ -n "$RUNNING_REGISTRY" ]; then
    for IMAGE_NAME in $RUNNING_REGISTRY; do
        stop_image $IMAGE_NAME
    done
fi
# remove everything with our image ID
REGISTRY_NAMES=`docker images | grep $REGISTRY_ID | awk '{ printf("%s:%s\n", $1, $2) }'`
if [ -n "$REGISTRY_NAMES" ]; then
    for IMAGE_NAME in $REGISTRY_NAMES; do
        stop_image $IMAGE_NAME
    done
fi
