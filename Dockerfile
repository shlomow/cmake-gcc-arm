FROM ubuntu:18.04

LABEL maintainer="Shlomi Vaknin"

ENV SEGGER_VERSION="652c"
ENV SEGGER_POST_PARAMS="accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software"
ENV SEGGER_FILE="JLink_Linux_V${SEGGER_VERSION}_x86_64.deb"
ENV SEGGER_URL="https://www.segger.com/downloads/jlink/${SEGGER_FILE}"

ENV GCC_ARM_BASE_FILE="gcc-arm-none-eabi-8-2019-q3-update"
ENV GCC_ARM_FILE="${GCC_ARM_BASE_FILE}-linux.tar.bz2"
ENV GCC_ARM_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2019q3/RC1.1/${GCC_ARM_FILE}"

ENV CMAKE_VERSION="3.15.4"
ENV CMAKE_FILE="cmake-${CMAKE_VERSION}-Linux-x86_64.sh"
ENV CMAKE_URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${CMAKE_FILE}"

RUN apt-get update

# install ninja and make generators for cmake
RUN apt-get install -y \
    ninja-build \
    make \
    wget \
&&  apt-get clean

# install cmake
RUN wget ${CMAKE_URL} \
&&  chmod u+x ${CMAKE_FILE} \
&&  ./${CMAKE_FILE} --skip-license --prefix=/usr/local \
&&  rm ${CMAKE_FILE}

# install segger tools
RUN wget --post-data=${SEGGER_POST_PARAMS} ${SEGGER_URL} \
&&  dpkg -i ${SEGGER_FILE} \
&&  rm ${SEGGER_FILE}

# install arm-none-eabi-gcc
RUN wget ${GCC_ARM_URL} \
&&  cd /opt \
&&  tar xjf /${GCC_ARM_FILE} \
&&  cd ${GCC_ARM_BASE_FILE}/bin \
&&  for f in *; \
        do ln -s `pwd`/$f /usr/bin/$f; \
    done \
&&  rm /${GCC_ARM_FILE}

# expose the usb subsystem in order to flash the device
VOLUME /dev/bus/usb:/dev/bus/usb