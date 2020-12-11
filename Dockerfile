FROM tensorflow/tensorflow:2.3.1-gpu

# Notes
#
# - In the host machine there are only 2 dependencies: the GPU driver and 
#   nvidia-docker
#   https://www.tensorflow.org/install/docker#tensorflow_docker_requirements
#
# - The tensorflow image already comes with the Nvidia package repositories
#    added: https://www.tensorflow.org/install/gpu#ubuntu_1804_cuda_101
#
# - The documentation explicitely mentions the tested build configurations
#   that work for each version of Tensorflow. Specifically I'm referring to the
#   Cuda version. For Tensorflow 2.3, Cuda 10.1 and cuDNN 7.6 are specified.
#   So take care when installing development packages below.
#   https://www.tensorflow.org/install/source#tested_build_configurations

RUN apt-get update

#
# Install Common utilities
#
RUN apt-get install -y \
    build-essential \
    cmake \
    unzip \
    pkg-config \
    git \
    curl \
    wget

#
# Install OpenCV dependencies 
#
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

# Note:
# The following is a conjeture of mine.
# Some packages like libcudnn and libcublas depend on an specific Cuda version, in my case
# I'm using Cuda 10.1, so I should install the right specific packages.
#
# The cuDNN version recommended for Tensorflow2.3 is libcudnn 7.6
# libcudnn7 is already installed but I also need libcudnn7-dev
# The latest libcudnn7 version found in https://developer.nvidia.com/rdp/cudnn-archive 
# is libcudnn 7.6.5
# The command `apt-cache madison libcudnn7-dev` lists the specific versions that are available
# I have selected the latest libcudnn 7.6.5 version available  and I am hardcoding it here below
RUN apt-get install -y \
#    libcudnn7=7.6.5.32-1+cuda10.1 \
     libcudnn7-dev \
#    libcudnn7-dev=7.6.5.32-1+cuda10.1 \
    libcublas-dev=10.1.0.105-1 \
#    libcublas10 is in version 10.2, do i need to pass it to version 10.1?
     cuda-cufft-dev-10-1 \
     cuda-npp-dev-10-1 \
     cuda-cusolver-dev-10-1 \
     cuda-curand-dev-10-1

#
# OPENCV INSTALLATION
#
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

RUN cd ~/opencv/build && \
    make -j4 && \
    make install && \
    ldconfig
    
RUN cd ~ && \
    git clone -b "v19.21" --single-branch https://github.com/davisking/dlib.git

RUN cd ~/dlib && \
    python setup.py install

#RUN apt-get install -y \ 
#    libopenblas-dev \
#    liblapack-dev \
#    libcublas-dev \
#    cuda-cusolver-dev-10-0 \
#    cuda-curand-dev-10-0 \
#    cuda-cufft-dev-10-0 \
#    cuda-npp-dev-10-0 \
#    liblapacke-dev
#RUN ln -s /usr/local/cuda-10.0/lib64/libcublas.so.10.0 /usr/local/cuda-10.0/lib64/libcublas.so


# RUN pip3 install face_recognition imutils

# RUN apt-get clean && rm -rf /tmp/* /var/tmp/*
