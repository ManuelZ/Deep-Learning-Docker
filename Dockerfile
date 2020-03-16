FROM tensorflow/tensorflow:2.0.1-gpu-py3

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y \
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
    libopenblas-dev \
    liblapack-dev \
    software-properties-common \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

# Dlib dependencies on cuda packages
RUN apt-get install -y \ 
    libcudnn7-dev \
    libcublas-dev \
    cuda-cusolver-dev-10-0 \
    cuda-curand-dev-10-0 \
    && apt-get clean && rm -rf /tmp/* /var/tmp/*

RUN ln -s /usr/local/cuda-10.0/lib64/libcublas.so.10.0 /usr/local/cuda-10.0/lib64/libcublas.so
RUN ln -s /usr/local/cuda-10.0/lib64/libcurand.so.10.0 /usr/local/cuda-10.0/lib64/libcurand.so
RUN ln -s /usr/local/cuda-10.0/lib64/libcusolver.so.10.0 /usr/local/cuda-10.0/lib64/libcusolver.so

RUN cd ~ && \
    git clone -b "v19.19" --single-branch https://github.com/davisking/dlib.git && \
    cd dlib && \
    mkdir build && \
    cd build && \
    cmake .. -DDLIB_USE_CUDA=1 -DUSE_AVX_INSTRUCTIONS=1 -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu && \
    cmake --build -j$(nproc) . 

RUN cd ~/dlib && \
    python setup.py install USE_AVX_INSTRUCTIONS DLIB_USE_CUDA

RUN pip3 install face_recognition imutils
