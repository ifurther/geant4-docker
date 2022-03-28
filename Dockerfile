ARG IMAGE_FROM=base

FROM ifurther/geant4:${IMAGE_FROM} AS build-base
LABEL maintainer="Further Lin <55025025+ifurther@users.noreply.github.com>"

RUN sed --in-place --regexp-extended "s/(\/\/)(archive\.ubuntu)/\1tw.\2/" /etc/apt/sources.list 
	
ARG build_G4Version="11.0.p01"
ARG build_shortG4version="10.7.2"	
ENV G4Version=$build_G4Version
ENV shortG4version=$build_shortG4version

SHELL ["/bin/bash", "-c"] 
RUN if [ ! -e /app ] ; then mkdir /app; fi
RUN if [ ! -e /app/src ];then mkdir /app/src;fi
ENV G4WKDIR=/app
ENV G4SRC=/app/src
ENV G4DIR=${G4WKDIR}/geant4.${shortG4version}-install

WORKDIR /app

RUN mkdir /cvmfs

RUN if [ ! -e $G4WKDIR ] ; then mkdir $G4WKDIR; fi
RUN if [ ! -e $G4SRC ];then mkdir $G4SRC;fi

FROM build-base AS build-G4

#RUN export shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'`

#RUN export G4WKDIR=$(pwd)

RUN echo "G4WKDIR is: ${G4WKDIR}"

RUN bash -c 'mkdir -p ${G4DIR}/share/data/Geant4-${shortG4version}'
#ADD Geant4-${shortG4version}/*.tar.gz ${G4WKDIR}/geant4.${shortG4version}-install/share/Geant4-${shortG4version}/data/
#ADD geant4.${G4Version}.tar.gz .
RUN if [ ! -e geant4.${G4Version} ] ; then wget https://geant4-data.web.cern.ch/releases/geant4.${G4Version}.tar.gz; \
tar zxvf geant4.${G4Version}.tar.gz -C ${G4WKDIR}; \
mv geant4.${G4Version}.tar.gz /app/src; fi

RUN ls /app/src


RUN bash -c 'if [ -e geant4.${shortG4version}-install ] ; then mkdir ${G4WKDIR}/geant4.${shortG4version}-build; else mkdir ${G4DIR}/geant4.${shortG4version}-{build,install}; fi'

RUN cd ${G4WKDIR}/geant4.${shortG4version}-build && \
cmake -DCMAKE_INSTALL_PREFIX=${G4WKDIR}/geant4.${shortG4version}-install \
-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_INSTALL_DATA=OFF \
-DGEANT4_USE_GDML=ON \
-DGEANT4_USE_PYTHON=ON \
-DGEANT4_USE_QT=ON -DGEANT4_USE_SYSTEM_ZLIB=ON -DGEANT4_USE_SYSTEM_EXPAT=ON ${G4WKDIR}/geant4.${G4Version} &&\
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install 

RUN ls $G4WKDIR/geant4.${shortG4version}-install

#RUN rm -rf ${G4WKDIR}/geant4.${shortG4version}-build

# final stage
FROM build-base AS G4-app

COPY --from=build-G4 /app/src/geant4.${G4Version}.tar.gz /app/src/
COPY --from=build-G4 ${G4DIR}/ ${G4DIR}/

RUN  bash -c 'echo  -e "#!/bin/bash\n\
set -e\n\
\n\
source $G4DIR/bin/geant4.sh\n\
#source $G4DIR/share/Geant4-$shortG4version/geant4make/geant4make.sh\n\
\n\
exec \"\$@\"\n\
">$G4WKDIR/entry-point.sh'

RUN chmod +x $G4WKDIR/entry-point.sh

ENTRYPOINT ["/app/entry-point.sh"]
