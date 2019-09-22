ARG IMAGE_FROM=10.5.1-onlydata

FROM ifurther/geant4:${IMAGE_FROM}
LABEL maintainer="Further Lin <55025025+ifurther@users.noreply.github.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ARG build_G4Version="10.05.p01"
ARG build_shortG4version="10.5.1"	
ENV G4Version=$build_G4Version
ENV shortG4version=$build_shortG4version

#RUN export shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'`

#RUN export G4WKDIR=$(pwd)

SHELL ["/bin/bash", "-c"] 
RUN if [ ! -e /app ] ; then mkdir /app; fi
RUN if [ ! -e /src ];then mkdir /src;fi
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
cmake -DCMAKE_INSTALL_PREFIX=${G4DIR}/geant4.${shortG4version}-install \
-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_INSTALL_DATA=ON \
-DGEANT4_USE_QT=ON -DGEANT4_USESYSTEM_ZLIB=ON -DGEANT4_USESYSTEM_EXPAT=ON ${G4WKDIR}/geant4.${G4Version} &&\
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install 

RUN ls $G4WKDIR/geant4.${shortG4version}-install

RUN  echo  -e "\n\
#!/bin/bash\n\
set -e \n\
\n\
source $G4DIR/bin/geant4.sh\n\
source $G4DIR/share/Geant4-$shortG4version/geant4make/geant4make.sh \n\
\n\
exec "$@" \n">$G4WKDIR/entry-point.sh

RUN chmod +x $G4WKDIR/entry-point.sh

RUN rm -rf ${G4WKDIR}/geant4.${shortG4version}-build

RUN mv geant4.${G4Version} /src

