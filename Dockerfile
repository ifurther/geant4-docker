ARG IMAGE_FROM=latest

FROM ubuntu:${IMAGE_FROM}
LABEL maintainer="Further Lin <55025025+ifurther@users.noreply.github.com>"

ENV TZ=Asia/Taipei

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list && \
	apt-get update && apt-get upgrade --yes
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

RUN apt-get update

RUN apt-get install -y libexpat1-dev libgl1-mesa-dev \
libglu1-mesa-dev libxt-dev xorg-dev build-essential \
libxerces-c-dev libxmu-dev expat libfreetype6-dev  \
cmake-curses-gui wget libxext-dev qt5-default \
git dpkg-dev libfftw3-dev libftgl-dev python3-dev \
libexpat-dev zlib1g zlib1g-dev tcl tk libboost-dev

RUN apt-get clean all

#Base Image
