# Notes
#
# In the host machine there are few dependencies: 
#   - Docker 
#   - The GPU driver
#   - nvidia-docker
#   https://www.tensorflow.org/install/docker#tensorflow_docker_requirements
#
#
# - The tensorflow image already comes with the Nvidia package repositories
#   added: https://www.tensorflow.org/install/gpu#ubuntu_1804_cuda_101
#
# - The documentation explicitely mentions the tested build configurations
#   that work for each version of Tensorflow. Specifically I'm referring to the
#   Cuda version. For Tensorflow 2.3, Cuda 10.1 and cuDNN 7.6 are specified.
#   https://www.tensorflow.org/install/source#tested_build_configurations
#

FROM tensorflow/tensorflow:2.3.1-gpu

RUN apt-get update

# Install build utilities
RUN apt-get install -y \
    build-essential \
    cmake \
    unzip \
    pkg-config \
    git \
    curl \
    wget

# Install OpenCV dependencies 
# From https://www.pyimagesearch.com/2020/02/03/how-to-use-opencvs-dnn-module-with-nvidia-gpus-cuda-and-cudnn/
RUN apt-get install --no-install-recommends -y \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran \
    python3-dev


# To compile OpenCV and DLib some cuda-related development packages are 
# needed.
#
# - The cuDNN version recommended for Tensorflow2.3 is libcudnn 7.6
# - This Tensorflow2.3 image uses cuda 10.1, libcublas-dev has versions 10.1 
#   and 10.2 . Only the specific version 10.1 allows the OpenCV compilation to
#   continue. The command `apt-cache madison libcublas-dev` lists the specific 
#   available package versions.
RUN apt-get install -y \
     libcudnn7-dev \
     libcublas-dev=10.1.0.105-1 \ 
     cuda-cufft-dev-10-1 \
     cuda-npp-dev-10-1 \
     cuda-cusolver-dev-10-1 \
     cuda-curand-dev-10-1

# The following dependencies may be worth it for OpenCV... or not... idk
# RUN apt-get install -y \ 
#     libopenblas-dev \
#     liblapack-dev \
#     liblapacke-dev

# Download OpenCV
RUN cd ~ && \
    wget -O opencv.zip https://github.com/opencv/opencv/archive/4.5.0.zip  && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.5.0.zip && \
    unzip opencv.zip && \
    unzip opencv_contrib.zip && \
    mv opencv-4.5.0 opencv && \
    mv opencv_contrib-4.5.0 opencv_contrib

# Make sure to change the value of CUDA_ARCH_BIN with the value 
# corresponding to your card found on https://developer.nvidia.com/cuda-gpus
RUN cd ~/opencv && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D INSTALL_C_EXAMPLES=OFF \
          -D OPENCV_ENABLE_NONFREE=ON \
          -D WITH_CUDA=ON \
          -D WITH_CUDNN=ON \
          -D OPENCV_DNN_CUDA=ON \
          -D ENABLE_FAST_MATH=1 \
          -D CUDA_FAST_MATH=1 \
          -D CUDA_ARCH_BIN=6.1 \
          -D WITH_CUBLAS=1 \
          -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
          -D HAVE_opencv_python3=ON \
          -D PYTHON_EXECUTABLE=$(which python3) \
          -D BUILD_EXAMPLES=ON ..

# Compile OpenCV
RUN cd ~/opencv/build && \
    make -j4 && \
    make install && \
    ldconfig

# Download DLib
RUN cd ~ && \
    git clone -b "v19.21" --single-branch https://github.com/davisking/dlib.git

# Compile DLib
RUN cd ~/dlib && \
    python setup.py install

RUN pip3 install face_recognition imutils

RUN apt-get clean && rm -rf /tmp/* /var/tmp/*
