ARG IMAGE_FROM=7

FROM centos:${IMAGE_FROM}
LABEL maintainer="Further Lin <55025025+ifurther@users.noreply.github.com>"

RUN yum update -y && yum install epel-release -y

RUN yum install  -y xerces-c-devel qt4 qt4-devel freeglut-devel \
                motif-devel tk-devel cmake3 libXpm-devel libXmu-devel \
                libXi-devel libXft-devel libXext-devel environment-modules \
                expat openmpi-devel openmpi gcc gcc-c++ make

RUN yum clean all

#Base Image
