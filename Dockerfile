FROM tensorflow/tensorflow:2.0.1-gpu-py3

RUN apt-get update && apt-get upgrade -y

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
RUN apt-get install -y \
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
    libopenblas-dev \
    liblapack-dev \
    python3-dev \
    cuda-cufft-dev-10-0
    
#
# Install Dlib dependencies on cuda packages
#
RUN apt-get install -y \ 
    libcudnn7-dev \
    libcublas-dev \
    cuda-cusolver-dev-10-0 \
    cuda-curand-dev-10-0 

RUN ln -s /usr/local/cuda-10.0/lib64/libcublas.so.10.0 /usr/local/cuda-10.0/lib64/libcublas.so


#
# DLIB INSTALLATION
#
RUN cd ~ && \
    git clone -b "v19.19" --single-branch https://github.com/davisking/dlib.git && \
    cd dlib && \
    mkdir build && \
    cd build && \
    cmake .. -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1 -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu && \
    cmake --build . 

RUN cd ~/dlib && \
    python setup.py install


#
# OPENCV INSTALLATION
#
RUN cd ~ && \
    wget -O opencv.zip https://github.com/opencv/opencv/archive/4.2.0.zip  && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.2.0.zip && \
    unzip opencv.zip && \
    unzip opencv_contrib.zip && \
    mv opencv-4.2.0 opencv && \
    mv opencv_contrib-4.2.0 opencv_contrib

# OpenCV dependency
RUN apt-get install -y \
    libnppc9.1 
    

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

RUN pip3 install face_recognition imutils

RUN apt-get clean && rm -rf /tmp/* /var/tmp/*
