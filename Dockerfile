FROM ubuntu:16.04

MAINTAINER Vaclav Petras <wenzeslaus@gmail.com>

# system environment
ENV DEBIAN_FRONTEND noninteractive

# GRASS GIS compile dependencies
RUN apt-get update \
    && apt-get install -y --install-recommends \
        autoconf2.13 \
        autotools-dev \
        bison \
        flex \
        g++ \
        gettext \
        libblas-dev \
        libbz2-dev \
        libcairo2-dev \
        libfftw3-dev \
        libfreetype6-dev \
        libgdal-dev \
        libgeos-dev \
        libglu1-mesa-dev \
        libjpeg-dev \
        liblapack-dev \
        liblas-c-dev \
        libncurses5-dev \
        libnetcdf-dev \
        libpng-dev \
        libpq-dev \
        libproj-dev \
        libreadline-dev \
        libsqlite3-dev \
        libtiff-dev \
        libxmu-dev \
        make \
        netcdf-bin \
        proj-bin \
        python \
        python-dev \
        python-numpy \
        python-pil \
        python-ply \
        unixodbc-dev \
        zlib1g-dev \
    && apt-get autoremove \
    && apt-get clean

# other software
RUN apt-get update \
    && apt-get install -y --install-recommends \
        imagemagick \
        p7zip \
        subversion \
    && apt-get autoremove \
    && apt-get clean

# install GRASS GIS
# using a specific revision, otherwise we can't apply the path safely
WORKDIR /usr/local/src
RUN svn checkout -r 69871 https://svn.osgeo.org/grass/grass/trunk grass \
    && cd grass \
    &&  ./configure \
        --enable-largefile=yes \
        --with-nls \
        --with-cxx \
        --with-readline \
        --with-bzlib \
        --with-pthread \
        --with-proj-share=/usr/share/proj \
        --with-geos=/usr/bin/geos-config \
        --with-cairo \
        --with-opengl-libs=/usr/include/GL \
        --with-freetype=yes --with-freetype-includes="/usr/include/freetype2/" \
        --with-sqlite=yes \
        --with-liblas=yes --with-liblas-config=/usr/bin/liblas-config \
    && make && make install && ldconfig
# cannot delete src now, patch will be needed

# enable simple grass command regardless of version number
RUN ln -s /usr/local/bin/grass* /usr/local/bin/grass

# install additional GRASS GIS modules, each as a separate step
RUN grass -c EPSG:4326 /tmp/grasstmploc -e

# no ARG in Docker 1.6.2, only ENV
ENV addons=https://svn.osgeo.org/grass/grass-addons/grass7

WORKDIR /usr/local/src
RUN svn checkout -r 69857 $addons/raster3d/r3.count.categories r3.count.categories \
    && grass /tmp/grasstmploc/PERMANENT --exec \
        g.extension -s r3.count.categories url=r3.count.categories
RUN svn checkout -r 69888 $addons/raster3d/r3.forestfrag r3.forestfrag \
    && grass /tmp/grasstmploc/PERMANENT --exec \
        g.extension -s r3.forestfrag url=r3.forestfrag
RUN svn checkout -r 69887 $addons/raster3d/r3.profile r3.profile \
    && grass /tmp/grasstmploc/PERMANENT --exec \
        g.extension -s r3.profile url=r3.profile
RUN rm -r /tmp/grasstmploc

RUN mkdir /code

# fix for #2992 (https://trac.osgeo.org/grass/ticket/2992)
# removes source code at the end
COPY r3.null.patch /code/
WORKDIR /usr/local/src/grass
RUN patch -p0 < /code/r3.null.patch \
    && cd raster3d/r3.null \
    && make && make install \
    && cd ../../.. && rm -r grass

# create a user
RUN useradd -m -U grass

VOLUME ["/data"]

# add repository files to the image
COPY . /code

# change the owner so that the user can execute
RUN chown -R grass:grass /code

# switch the user
USER grass

WORKDIR /data
