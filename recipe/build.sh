#!/bin/bash

set -xe

export CPP="${CC} -E -P"
export FPP="${FC} -E -P -cpp"

# Build devxlib
pushd devxlib
./configure \
    --prefix="${PREFIX}" \
    --enable-openmp \
    --with-blas-libs="${PREFIX}/lib/libblas.so" \
    --with-lapack-libs="${PREFIX}/lib/liblapack.so"
make -j"${CPU_COUNT}" install
popd


./configure \
    --prefix="${PREFIX}" \
    --enable-mpi --enable-open-mp \
    --with-fft-path="${PREFIX}" \
    --with-hdf5-path="${PREFIX}" \
    --with-netcdf-libs="${PREFIX}/lib/libnetcdf.so" \
    --with-netcdff-libs="${PREFIX}/lib/libnetcdff.so" \
    --enable-hdf5-par-io \
    --with-libxc-libdir="${PREFIX}/lib" \
    --with-scalapack-libs="${PREFIX}/lib/libscalapack.so" \
    --with-blacs-libs="${PREFIX}/lib/libscalapack.so" \
    --with-blas-libs="${PREFIX}/lib/libblas.so" \
    --with-lapack-libs="${PREFIX}/lib/liblapack.so" \
    --with-devxlib-path="${PREFIX}" \
    --with-iotk-libs="${PWD}/lib/iotk/iotk/src/libiotk.a" \
    --enable-par-linalg \
    --with-slepc-path="${PREFIX}" \
    --with-petsc-path="${PREFIX}" \
    --enable-slepc-linalg

make -j$CPU_COUNT all || (cat log/*yambo*.log && exit 123)
#for f in `find ./ -name "*.log"`; do echo "Printing the contents of '$f'"; cat $f; done

ls -la $PREFIX/bin

ls -la $PREFIX/lib

# mkdir -p ${PREFIX}/bin
# cp -r bin/* ${PREFIX}/bin
# mkdir -p ${PREFIX}/lib
# cp -r lib/external/*/*/lib/*.* ${PREFIX}/lib
