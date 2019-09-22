#!/bin/sh

G4Version=$1 
shortG4version=`echo $G4Version |sed 's/p//g'|sed 's/\.0/./g'```


echo 'The Geant4 is' ${G4Version}


echo 'The short ' $shortG4version


podman build --format docker \
	--build-arg build_G4Version=${G4Version} \
	--build-arg build_shortG4version=$shortG4version  \
	-t docker.io/ifurther/geant4:$shortG4version . 
