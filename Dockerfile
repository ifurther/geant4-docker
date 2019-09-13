ARG IMAGE_FROM=10.5.1

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <geant4ro.ot@gmail.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ENV G4Version="10.05.p01"
ENV shortG4version="10.5.1"
#RUN export shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'`

#RUN export G4WKDIR=$(pwd)
RUN apt-get update &&\
apt-get install -y openmpi-bin openmpi-doc libopenmpi-dev &&\
apt-get clean all

RUN bash -c 'if [ ! -e /app ] ; then mkdir /app; fi'
ENV G4WKDIR=/app
ENV G4DIR=/app/geant4.${shortG4version}-install

WORKDIR /app

RUN echo "G4WKDIR is: ${G4WKDIR}"

#RUN bash -c 'mkdir -p ${G4WKDIR}/geant4.${shortG4version}-install/share/data/Geant4-${shortG4version}'
#ADD Geant4-${shortG4version}/*.tar.gz ${G4WKDIR}/geant4.${shortG4version}-install/share/Geant4-${shortG4version}/data/
#ADD geant4.${G4Version}.tar.gz .
#RUN if [ ! -e geant4.${G4Version} ] ; then wget http://geant4-data.web.cern.ch/geant4-data/releases/geant4.${G4Version}.tar.gz; \
#tar zxvf geant4.${G4Version}.tar.gz -C ${G4WKDIR}; \
#rm -rf geant4.${G4Version}.tar.gz; fi


RUN bash -c 'if [ ! -e ${G4WKDIR}/g4${shortG4version}mpi-build ]; then mkdir ${G4WKDIR}/g4${shortG4version}mpi-build; fi'


RUN source $G4DIR/bin/geant4.sh &&\
RUN cd ${G4WKDIR}/g4${shortG4version}mpi-build && \
cmake -DCMAKE_INSTALL_PREFIX=${G4DIR} \
 ${G4DIR}/share/examples/extended/parallel/MPI/source &&\
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install 

RUN ls $G4WKDIR/geant4.${shortG4version}-install
