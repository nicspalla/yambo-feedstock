#!/bin/bash

export CPP="${CC} -E -P"
export FPP="${FC} -E -P -cpp"
./configure \
    --enable-mpi --enable-open-mp \
    --with-fft-path="${PREFIX}" \
    --with-hdf5-path="${PREFIX}" \
    --with-netcdf-path="${PREFIX}" \
    --with-netcdff-path="${PREFIX}" \
    --enable-hdf5-par-io \
    --with-libxc-path="${PREFIX}" \
    --with-scalapack-libs="${PREFIX}/lib/libscalapack.so" \
    --with-blacs-libs="${PREFIX}/lib/libscalapack.so" \
    --with-blas-libs="${PREFIX}/lib/libblas.so" \
    --with-lapack-libs="${PREFIX}/lib/liblapack.so" \
    --enable-par-linalg \
    --with-slepc-path="${PREFIX}" \
    --with-petsc-path="${PREFIX}" \
    --enable-slepc-linalg 

make -j$CPU_COUNT all

mkdir -p ${PREFIX}/bin
cp -r bin/* ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
cp -r lib/external/*/*/lib/*.* ${PREFIX}/lib
