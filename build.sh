#!/usr/bin/env bash
# Run this script from Cygwin that can be installed using the following command:
#   setup-x86_64.exe --quiet-mode --site http://mirrors.kernel.org/sourceware/cygwin/ --packages autobuild,autoconf,automake,cmake,gcc-g++,gettext,gettext-devel,libtool,make,zip

set -o xtrace -o errexit -o nounset -o pipefail

readonly currentScriptDir=`dirname "$(realpath -s "${BASH_SOURCE[0]}")"`
readonly buildDir="${currentScriptDir}/build"
readonly publishDir="${buildDir}/publish"

# Ensure that only Cygwin binaries are used
export PATH=/usr/bin:$(cygpath ${SYSTEMROOT})/system32

# Create build directory
rm -rf "${buildDir}"
mkdir "${buildDir}"
mkdir "${publishDir}"

# Build fswatch
git clone --branch 1.18.3 --depth 1 https://github.com/emcrisostomo/fswatch.git "${buildDir}/fswatch"
( cd "${buildDir}/fswatch"
./autogen.sh
CXXFLAGS="-std=gnu++17 -D_XOPEN_SOURCE=700 -static -static-libgcc -static-libstdc++ -O3" ./configure
make -j `nproc`
)

# Copy fswatch binary and Cygwin dlls to the publish directory
cp "${buildDir}/fswatch/fswatch/src/fswatch.exe" /bin/{cygwin1.dll,cygiconv-2.dll,cygintl-8.dll} "${publishDir}"

# Create a zip archive of the publish directory
zip -9 --junk-paths "${publishDir}/fswatch-cygwin-x64.zip" "${publishDir}"/*
