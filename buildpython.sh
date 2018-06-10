export ARCH=arm-linux-gnueabihf

sudo apt-get install wget python make xz-utils gcc g++ gcc-$ARCH zlib1g-dev libdb4.8 libdb4.8-dev libreadline6-dev libc6-dev-i386 binutils-$ARCH

rm -r pybuild
mkdir -p pybuild
cd pybuild

export BASE_PYTHON_COMPILATION_PATH=`pwd`

# sqlite3
wget http://www.sqlite.org/2017/sqlite-autoconf-3160200.tar.gz
tar xvzf sqlite-autoconf-3160200.tar.gz
cd sqlite-autoconf-3160200/
./configure --host=arm-linux --prefix=$BASE_PYTHON_COMPILATION_PATH CC=$ARCH-gcc
make
make install
cd ..

read -n1 -r -p "Finished with SQLite. Press a key to work on zlib..." key

# zlib
wget http://www.gzip.org/zlib/zlib-1.1.4.tar.gz
tar xvf zlib-1.1.4.tar.gz
cd zlib-1.1.4
CC=$ARCH-gcc \
LDSHARED="$ARCH-gcc -shared -Wl,-soname,libz.so.1" \
./configure --shared --prefix=$BASE_PYTHON_COMPILATION_PATH
make
make install
cd ..

read -n1 -r -p "Finished with zlib. Press a key to work on openssl..." key

wget https://www.openssl.org/source/openssl-1.0.1g.tar.gz
tar -pxzf openssl-1.0.1g.tar.gz
cd openssl-1.0.1g/
wget http://www.linuxfromscratch.org/patches/downloads/openssl/openssl-1.0.1g-fix_parallel_build-1.patch
wget http://www.linuxfromscratch.org/patches/downloads/openssl/openssl-1.0.1g-fix_pod_syntax-1.patch
patch -Np1 -i openssl-1.0.1g-fix_parallel_build-1.patch
patch -Np1 -i openssl-1.0.1g-fix_pod_syntax-1.patch
./Configure linux-x86_64 os/compiler:$ARCH-gcc --prefix=$BASE_PYTHON_COMPILATION_PATH -fPIC
make
make install
cd ..

read -n1 -r -p "Finished with openssl. Press a key to compile python for the host machine..." key

# python dependencies
wget https://www.python.org/ftp/python/2.7.3/Python-2.7.3.tgz -O Python-2.7.3.tgz
tar -xvzf Python-2.7.3.tgz
cd Python-2.7.3

# build for the host system
./configure
make python Parser/pgen
mv python hostpython
mv Parser/pgen Parser/hostpgen
make distclean

read -n1 -r -p "Finished compiling host python. Press a key to patch and configure python for cross-compilation..." key

# patch it up
wget https://gist.githubusercontent.com/bmount/6929380/raw/8ef8e2701e7d5b1b22c5687e93d22f6ef9ca7ec6/Python-2.7.3-xcompile.patch -O Python-2.7.3-xcompile.patch
patch -p1 < Python-2.7.3-xcompile.patch

# configure
CC=$ARCH-gcc \
CXX=$ARCH-g++ \
AR=$ARCH-ar \
RANLIB=$ARCH-ranlib \
PYTHON_XCOMPILE_DEPENDENCIES_PREFIX=$BASE_PYTHON_COMPILATION_PATH \
./configure --host=arm-linux --build=i686-pc-linux-gnu --prefix=$BASE_PYTHON_COMPILATION_PATH/tmp --with-pic=no | tee config.log 2>&1

read -n1 -r -p "Finished configuring python for cross-compilation. Press a key to build..." key

# build
make clean
make HOSTPYTHON=./hostpython \
PYTHON_XCOMPILE_DEPENDENCIES_PREFIX=$BASE_PYTHON_COMPILATION_PATH \
HOSTPGEN=./Parser/hostpgen \
BLDSHARED="$ARCH-gcc -shared" \
HOSTARCH=arm-linux \
BUILDARCH=x86_64-linux-gnu \
CROSS_COMPILE=$ARCH- \
CROSS_COMPILE_TARGET=yes | tee make.log 2>&1

read -n1 -r -p "Finished cross-compiling python. Press a key to install..." key

# "install"
make install HOSTPYTHON=./hostpython \
BLDSHARED="$ARCH-gcc -shared" \
HOSTARCH=arm-linux \
BUILDARCH=x86_64-linux-gnu \
CROSS_COMPILE=$ARCH- \
CROSS_COMPILE_TARGET=yes prefix=$BASE_PYTHON_COMPILATION_PATH/Python-2.7.3/_install | tee install.log 2>&1

read -n1 -r -p "Finished installing python, press any key to bundle it all up!" key

# create a target directory for a minimal version of the installation
cd $BASE_PYTHON_COMPILATION_PATH/Python-2.7.3/
rm -r _install_minimal
mkdir -p _install_minimal/bin
mkdir -p _install_minimal/lib/python2.7
mkdir -p _install_minimal/include

# copy in the python binary file
cd $BASE_PYTHON_COMPILATION_PATH/Python-2.7.3/
cp _install/bin/python2.7 _install_minimal/bin/python

# bundle up the lib files into a zip file, after removing unneeded bits
cd _install/lib/
rm -r python2.7-minimal
cp -r python2.7 python2.7-minimal
cd python2.7-minimal
rm -r site-packages config lib-dynload
rm *.doc *.txt
zip -r -y python27.zip .

# copy in the python library files
cd $BASE_PYTHON_COMPILATION_PATH/Python-2.7.3
cp _install/lib/python2.7-minimal/python27.zip _install_minimal/lib/
cp -r _install/lib/python2.7/config _install_minimal/lib/python2.7/
cp -r _install/lib/python2.7/lib-dynload _install_minimal/lib/python2.7/
cp -r _install/lib/python2.7/site-packages _install_minimal/lib/python2.7/
cp -r _install/include/python2.7 _install_minimal/include/
cd _install_minimal
rm ../../../python.zip
zip -r ../../../python.zip .
cd ../../..
