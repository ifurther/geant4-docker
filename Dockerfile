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

RUN echo  '\n\
#!/bin/bash\n\
set -e \n\
\n\
source $G4DIR/bin/geant4.sh\n\
source $G4DIR/share/Geant4-${shortG4version}/geant4make/geant4make.sh \n\
\n\
exec "$@" \n'\
>$G4WKDIR/entry-point.sh

RUN chmod +x $G4WKDIR/entry-point.sh 

# only for Geant4-10.5.1
RUN sed -i 's/g4ios/G4ios/g'  $G4DIR/share/Geant4-${shortG4version}/examples/extended/parallel/MPI/source/src/G4MPIextraWorker.cc

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

RUN if [ ! -e ${G4WKDIR}/src ];then mkdir ${G4WKDIR}/src;fi

RUN mv geant4.${G4Version} /src

RUN rm -rf g410.5.1mpi-build geant4.10.5.1-build
