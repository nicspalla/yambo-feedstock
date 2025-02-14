#!/bin/bash

set -xe

export CPP="${CC} -E -P"
export FPP="${FC} -E -P -cpp"

export ORIG_LD="${LD}"


# Build devxlib
# `ld $LDFLAGS` fails
# `gfortran $LDFLAGS` works
unset LD
pushd devxlib
./configure \
    --prefix="${PREFIX}" \
    --with-blas-libs="${PREFIX}/lib/libblas.so" \
    --with-lapack-libs="${PREFIX}/lib/liblapack.so"
make -j"${CPU_COUNT}" install
popd

# Build iotk
pushd iotk

if [[ "${CONDA_BUILD_CROSS_COMPILATION:0}" == "1" ]]; then
    sed -i.bak1 's/ -march=[^ ]*//' configure
    sed -i.bak2 's/ -mcpu=[^ ]*//' configure
    sed -i.bak3 's/ -mtune=[^ ]*//' configure
fi

cp -f ${RECIPE_DIR}/iotk-make.sys ../make.sys
./configure
make -j"${CPU_COUNT}" all
popd

# Build Yambo

export LD="${ORIG_LD}"

if [[ "${CONDA_BUILD_CROSS_COMPILATION:0}" == "1" ]]; then
    sed -i.bak1 's/ -march=[^ ]*//' configure
    sed -i.bak2 's/ -mcpu=[^ ]*//' configure
    sed -i.bak3 's/ -mtune=[^ ]*//' configure
fi

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
    --with-iotk-libdir="iotk/src" \
    --with-iotk-includedir="iotk/include" \
    --enable-par-linalg \
    --with-slepc-path="${PREFIX}" \
    --with-petsc-path="${PREFIX}" \
    --enable-slepc-linalg || (cat config.log && exit 111)

make -j$CPU_COUNT all || (cat log/*.log && exit 222)
#for f in `find ./ -name "*.log"`; do echo "Printing the contents of '$f'"; cat $f; done

ls -la $PREFIX/bin

ls -la $PREFIX/lib

# mkdir -p ${PREFIX}/bin
# cp -r bin/* ${PREFIX}/bin
# mkdir -p ${PREFIX}/lib
# cp -r lib/external/*/*/lib/*.* ${PREFIX}/lib
