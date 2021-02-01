# Instructions


## Drivers
The biggest requirement in the host is to have the Nvidia drivers installed. When I installed 20.04 and checked the use of propietary drivers at installation time, I got them (v 450 I think). However, I needed to change to another version. That isn't easy:
- The graphical interface throws me an error.
- Installing via apt makes me end up with no driver loaded.

In the end, what worked to have the 440 version installed and loaded was:

    sudo apt install linux-headers-$(uname -r)
    sudo apt install nvidia-driver-440d

Found [here](https://forums.developer.nvidia.com/t/nvidia-driver-is-not-loaded-ubuntu-18-10/70495/60)


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
 --volume ~/dlib/examples/:/container/dir \
 --name dl-container \
 dl
```

##### Run the container

    sudo docker container start --interactive dl-container

##### Run DLib example

    python /root/dlib/python_examples/face_detector.py /root/dlib//examples/faces/\*.jpg
