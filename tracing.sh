package: Tracing
version: "%(tag_basename)s"
tag: v0.1.0
requires:
  - opentelemetry-cpp
  - "GCC-Toolchain:(?!osx)"
license: GPL-3.0
build_requires:
  - CMake
  - alibuild-recipe-tools
  - ninja
source: https://github.com/AliceO2Group/Tracing
incremental_recipe: |
  cmake --build . -- ${JOBS:+-j$JOBS} install
  mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
---
#!/bin/bash -ex

cmake $SOURCEDIR                                                        \
  -G Ninja                                                              \
  -DCMAKE_INSTALL_PREFIX=$INSTALLROOT                                   \
  ${CMAKE_BUILD_TYPE:+-DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE}             \
  ${CXXSTD:+-DCMAKE_CXX_STANDARD=$CXXSTD}                              \
  ${OPENTELEMETRY_CPP_REVISION:+-Dopentelemetry-cpp_DIR=$OPENTELEMETRY_CPP_ROOT/lib/cmake/opentelemetry-cpp} \
  ${OPENTELEMETRY_CPP_REVISION:--DO2_TRACING_WITH_OTEL=OFF}             \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

cp ${BUILDDIR}/compile_commands.json ${INSTALLROOT}

cmake --build . -- ${JOBS+-j $JOBS} install

# Modulefile
mkdir -p etc/modulefiles
alibuild-generate-module --bin --lib --root > etc/modulefiles/$PKGNAME
mkdir -p $INSTALLROOT/etc/modulefiles && rsync -a --delete etc/modulefiles/ $INSTALLROOT/etc/modulefiles
