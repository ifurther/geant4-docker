Bootstrap: library
From: library/default/centos:7.7

%labels
MAINTAINER Further Lin
Version v10.6.2

%environment
export build_G4Version="10.06.p02"
export build_shortG4version="10.6.2"	
export G4Version=$build_G4Version
export shortG4version=$build_shortG4version
export G4WKDIR=/app

%runscript
echo "This gets run when you run the image!" 
exec /bin/bash /code/rawr.sh "$@"  

%post  
echo "This section happens once after bootstrap to build the image."  
yum install -y epel-release
yum install -y xerces-c-devel qt4 qt4-devel \
               freeglut-devel motif-devel tk-devel \
			   cmake3 libXpm-devel libXmu-devel libXi-devel \
			   libXft-devel libXext-devel environment-modules \
			   expat openmpi-devel openmpi gcc gcc-c++ make
mkdir -p ${G4WKDIR}/geant4.${shortG4version}-install/share/data/Geant4-${shortG4version}
if [ ! -e geant4.${G4Version} ] ; then wget https://geant4-data.web.cern.ch/geant4-data/releases/geant4.${G4Version}.tar.gz; \
tar zxvf geant4.${G4Version}.tar.gz -C ${G4WKDIR}; \
rm -rf geant4.${G4Version}.tar.gz; fi
if [ -e geant4.${shortG4version}-install ] ; then mkdir ${G4WKDIR}/geant4.${shortG4version}-build; else mkdir ${G4DIR}/geant4.${shortG4version}-{build,install}; fi			   
if [ -e geant4.${shortG4version}-install ] ; then mkdir ${G4WKDIR}/geant4.${shortG4version}-build; else mkdir ${G4DIR}/geant4.${shortG4version}-{build,install}; fi

cd ${G4WKDIR}/geant4.${shortG4version}-build && \
cmake -DCMAKE_INSTALL_PREFIX=${G4DIR}/geant4.${shortG4version}-install \
-DGEANT4_USE_OPENGL_X11=ON -DGEANT4_INSTALL_DATA=ON \
-DGEANT4_USE_QT=ON -DGEANT4_USESYSTEM_ZLIB=ON -DGEANT4_USESYSTEM_EXPAT=ON ${G4WKDIR}/geant4.${G4Version} &&\
make -j`grep -c ^processor /proc/cpuinfo` &&\
make install 

rm -rf ${G4WKDIR}/geant4.${shortG4version}-build
mv geant4.${G4Version} /src

echo  -e "\n\
#!/bin/bash\n\
set -e \n\
\n\
source $G4DIR/bin/geant4.sh\n\
source $G4DIR/share/Geant4-$shortG4version/geant4make/geant4make.sh \n\
\n\
exec "$@" \n">$G4WKDIR/entry-point.sh
chmod +x $G4WKDIR/entry-point.sh

%test
ls $G4WKDIR/geant4.${shortG4version}-install
source $G4WKDIR/entry-point.sh