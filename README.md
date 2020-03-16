# Instructions


##### Build image

    sudo docker image build -t dl .


##### Create a new container with GUI cappabilities and GPU and mapping of a directory based on an existent image

```
sudo docker create \
 --gpus all \
 -it \
 --env DISPLAY=$DISPLAY \
 --volume $XAUTHORITY:/root/.Xauthority \
 --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
 --name dl-container \
 dl
```