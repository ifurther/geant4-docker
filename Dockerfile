ARG IMAGE_FROM=10.7.1

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <55025025+ifurther@users.noreply.github.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ARG build_G4Version="10.06.p02"
ARG build_shortG4version="10.6.2"	
ENV G4Version=$build_G4Version
ENV shortG4version=$build_shortG4version
#RUN export shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'`

#RUN export G4WKDIR=$(pwd)
RUN apt-get update &&\
apt-get install -y openmpi-bin openmpi-doc libopenmpi-dev &&\
apt-get clean all

RUN bash -c 'if [ ! -e /app ] ; then mkdir /app; fi'
ENV G4WKDIR=/app
ENV G4DIR=/app/geant4.${shortG4version}-install

WORKDIR /app
ENV SoftwareSRC=/src

RUN echo "G4WKDIR is: ${G4WKDIR}"

RUN bash -c 'if [ ! -e ${G4WKDIR}/g4${shortG4version}mpi-build ]; then mkdir ${G4WKDIR}/g4${shortG4version}mpi-build; fi'


RUN chmod +x $G4WKDIR/entry-point.sh 

# only for Geant4-10.5.1
#RUN sed -i 's/g4ios/G4ios/g'  $G4DIR/share/Geant4-${shortG4version}/examples/extended/parallel/MPI/source/src/G4MPIextraWorker.cc

RUN /bin/bash -c "source $G4WKDIR/entry-point.sh; \
cd ${G4WKDIR}/g4${shortG4version}mpi-build && \
cmake \ 
-DGeant4_DIR=${G4DIR}/lib/Geant4-${shortG4version} \
-DG4mpi_DIR=${G4DIR}/lib/Geant4-${shortG4version} \
-DCMAKE_INSTALL_PREFIX=${G4DIR} \
 ${G4DIR}/share/Geant4-${shortG4version}/examples/extended/parallel/MPI/source &&\
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install "

RUN ls $G4WKDIR/geant4.${shortG4version}-install

RUN rm -rf g4${shortG4version}mpi-build 
