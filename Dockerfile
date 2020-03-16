# Modified from:
# https://hub.docker.com/r/webforgelabs/dlib/dockerfile
# and 
# https://www.pyimagesearch.com/2018/06/18/face-recognition-with-opencv-python-and-deep-learning/

FROM tensorflow/tensorflow:2.0.1-gpu-py3

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    build-essential \
    cmake \
    unzip \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libatlas-base-dev \
    gfortran \
    git \
    curl \
    graphicsmagick \
    libgraphicsmagick1-dev \
    libgtk2.0-dev \
    liblapack-dev \
    software-properties-common \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

RUN cd ~ && \
    git clone -b "v19.9" --single-branch https://github.com/davisking/dlib.git && \
    cd dlib && \
    mkdir build && \
    cd build && \
    cmake .. -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1 && \
    cmake --build . && \
    cd .. && \
    python setup.py install --yes USE_AVX_INSTRUCTIONS --yes DLIB_USE_CUDA

RUN pip3 install face_recognition imutils
