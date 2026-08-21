#===================================================================================#
FROM ubuntu:24.04 AS builder

#-------------------------------------------------------#
# Install system packages
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
  build-essential \
  cmake \
  wget \
  git \
  ca-certificates \
  file \
  libeigen3-dev \
  libboost-all-dev \
  zlib1g-dev \
  libbz2-dev \
  liblzma-dev \
  libzstd-dev \
  libstdc++-13-dev \
  libboost-serialization1.83-dev \
  libboost-iostreams1.83-dev \
  && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------#
# Build RDKit from source
ENV RDKIT_VERSION=Release_2025_09_3
WORKDIR /build

RUN wget -q https://github.com/rdkit/rdkit/archive/refs/tags/${RDKIT_VERSION}.tar.gz && \
  tar xzf ${RDKIT_VERSION}.tar.gz && \
  rm ${RDKIT_VERSION}.tar.gz

WORKDIR /build/rdkit-${RDKIT_VERSION}/build

RUN cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DRDK_INSTALL_INTREE=OFF \
  -DCMAKE_INSTALL_PREFIX=/opt/rdkit \
  -DBUILD_SHARED_LIBS=OFF \
  -DRDK_INSTALL_STATIC_LIBS=ON \
  -DRDK_BUILD_PYTHON_WRAPPERS=OFF \
  -DRDK_BUILD_FREETYPE_SUPPORT=OFF \
  && make -j"$(nproc)" && make install

## Debug: List available static libraries
#RUN ls -1 /opt/rdkit/lib/*_static.a

#-------------------------------------------------------#
# Build smiles2pdb
WORKDIR /app
COPY smiles2pdb.cpp .
COPY CMakeLists.txt .

WORKDIR /app/build
RUN cmake .. && make -j"$(nproc)"

#-------------------------------------------------------#
# Verify the binary is fully static
RUN (ldd /app/build/smiles2pdb || true) && \
  file /app/build/smiles2pdb | grep -q "statically linked" && \
  file /app/build/smiles2pdb && \
  ls -lh /app/build/smiles2pdb

# Test the binary by running a simple case
RUN /app/build/smiles2pdb "CCO" /tmp/test.pdb && \
  cat /tmp/test.pdb && \
  echo "Build successful!"

#===================================================================================#
