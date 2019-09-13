ARG IMAGE_FROM=base

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <geant4ro.ot@gmail.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ENV G4Version="10.05.p01"
ENV shortG4version="10.5.1"
#RUN export shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'`

#RUN export G4DIR=$(pwd)

RUN bash -c 'if [ ! -e /app ] ; then mkdir /app; fi'
ENV G4WKDIR=/app
WORKDIR /app

RUN echo "G4WKDIR is: ${G4WKDIR}"

RUN bash -c 'mkdir -p ${G4WKDIR}/geant4.${shortG4version}-install/share/data/Geant4-${shortG4version}'
#ADD Geant4-${shortG4version}/*.tar.gz ${G4WKDIR}/geant4.${shortG4version}-install/share/Geant4-${shortG4version}/data/
#ADD geant4.${G4Version}.tar.gz .
RUN if [ ! -e geant4.${G4Version} ] ; then wget http://geant4-data.web.cern.ch/geant4-data/releases/geant4.${G4Version}.tar.gz; \
tar zxvf geant4.${G4Version}.tar.gz -C ${G4WKDIR}; \
rm -rf geant4.${G4Version}.tar.gz; fi


RUN bash -c 'if [ -e geant4.${shortG4version}-install ] ; then mkdir ${G4WKDIR}/geant4.${shortG4version}-build; else mkdir ${G4DIR}/geant4.${shortG4version}-{build,install}; fi'

RUN cd ${G4WKDIR}/geant4.${shortG4version}-build && \
cmake -DCMAKE_INSTALL_PREFIX=${G4WKDIR}/geant4.${shortG4version}-install \
-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_INSTALL_DATA=ON \
-DGEANT4_USE_QT=ON -DGEANT4_USESYSTEM_ZLIB=ON -DGEANT4_USESYSTEM_EXPAT=ON ${G4WKDIR}/geant4.${G4Version}

RUN cd ${G4WKDIR}/geant4.${shortG4version}-build && \
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install 

RUN ls $G4WKDIR/geant4.${shortG4version}-install
