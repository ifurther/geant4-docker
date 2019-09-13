ARG IMAGE_FROM=10.5.1-onlydata

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <geant4ro.ot@gmail.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ENV G4Version="10.05.p01"
ENV shortG4version="10.5.1"
#RUN export shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'`

#RUN export G4DIR=$(pwd)

ENV G4WKDIR=/app
ENV G4DIR= /app/geant4.${shortG4version}-install
WORKDIR /app

RUN echo "G4DIR is: ${G4DIR}"

RUN bash -c 'if [ ! -e ${G4WKDIR}/g4${shortG4version}mpi-build ]; then mkdir ${G4WKDIR}/g4${shortG4version}mpi-build; fi'

RUN source $G4DIR/geant4.${shortG4version}-install/bin/geant4.sh &&\
cd ${G4WKDIR}/g4${shortG4version}mpi-build && \
cmake -DCMAKE_INSTALL_PREFIX=${G4DIR}/geant4.${shortG4version}-install \
 ${G4DIR}/geant4.${G4Version}/share/examples/extended/parallel/MPI/source &&\
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install 

RUN ls $G4DIR/geant4.${shortG4version}-install
