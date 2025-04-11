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
    --with-blas-libs="-L${PREFIX}/lib -lopenblas" \
    --with-lapack-libs="-L${PREFIX}/lib -lopenblas"
make -j"${CPU_COUNT}" install
popd

# # Build iotk
pushd iotk

if [[ "${CONDA_BUILD_CROSS_COMPILATION:0}" == "1" ]]; then
    sed -i.bak1 's/ -march=[^ ]*//' configure
    sed -i.bak2 's/ -mcpu=[^ ]*//' configure
    sed -i.bak3 's/ -mtune=[^ ]*//' configure
fi

cp -f ${RECIPE_DIR}/iotk-make.sys ../make.sys
cp -f ${RECIPE_DIR}/iotk_specials.h include/
./configure
make -j"${CPU_COUNT}" loclib_only
make -j"${CPU_COUNT}" iotk.x
cp src/*.mod include/
popd


ls -la ${SRC_DIR}/iotk/src/libiotk.a

# Build Yambo

# export LD="${ORIG_LD}"

if [[ "${CONDA_BUILD_CROSS_COMPILATION:0}" == "1" ]]; then
    sed -i.bak1 's/ -march=[^ ]*//' configure
    sed -i.bak2 's/ -mcpu=[^ ]*//' configure
    sed -i.bak3 's/ -mtune=[^ ]*//' configure
fi
sed -i.bak 's/\(test -r \$try_netcdff_libdir\/libnetcdff\.so\)/\1 || test -r \$try_netcdff_libdir\/libnetcdff.dylib/' configure
#sed -i.bak 's/N=`grep -c ^processor \/proc\/cpuinfo`/N=1/' sbin/compilation/options.sh

cp -f ${SRC_DIR}/devxlib/config/config.sub config/
cp -f ${SRC_DIR}/devxlib/config/config.guess config/

./configure \
    --prefix="${PREFIX}" \
    --enable-mpi --enable-open-mp \
    --enable-time-profile --enable-memory-profile \
    --with-fft-path="${PREFIX}" \
    --with-hdf5-path="${PREFIX}" \
    --with-netcdf-path="${PREFIX}" \
    --with-netcdff-path="${PREFIX}" \
    --enable-hdf5-par-io \
    --with-libxc-path="${PREFIX}" \
    --with-scalapack-libs="-L${PREFIX}/lib -lscalapack" \
    --with-blacs-libs="-L${PREFIX}/lib -lscalapack" \
    --with-blas-libs="-L${PREFIX}/lib -lopenblas" \
    --with-lapack-libs="-L${PREFIX}/lib -lopenblas" \
    --with-devxlib-path="${PREFIX}" \
    --with-iotk-libs="${SRC_DIR}/iotk/src/libiotk.a" \
    --with-iotk-libdir="${SRC_DIR}/iotk/src" \
    --with-iotk-includedir="${SRC_DIR}/iotk/include" \
    --enable-par-linalg \
    --with-slepc-path="${PREFIX}" \
    --with-petsc-path="${PREFIX}" \
    --enable-slepc-linalg || (cat config.log && exit 111)

make -j"${CPU_COUNT}" all || (cat log/*.log && exit 222)
#for f in `find ./ -name "*.log"`; do echo "Printing the contents of '$f'"; cat $f; done

ls -la $PREFIX/bin

ls -la $PREFIX/lib

# mkdir -p ${PREFIX}/bin
# cp -r bin/* ${PREFIX}/bin
# mkdir -p ${PREFIX}/lib
# cp -r lib/external/*/*/lib/*.* ${PREFIX}/lib
