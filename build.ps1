#!/usr/bin/env pwsh

function Check {
    Param ([string] $s)
    if ($LASTEXITCODE -ne 0) { 
        Log "Failed: $s"
        throw "Error case -- see failed step"
    }
}

$G4Version=$Args[0]
$shortG4version= $G4Version -replace "p" -replace "\.0","."
Write-Host 'The Geant4 is' $G4Version 
echo ""

Write-Host 'The short ' $shortG4version -NoNewLine

echo ""

docker build `
	--build-arg build_G4Version=$G4Version `
	--build-arg build_shortG4version=$shortG4version `
	-t docker.io/ifurther/geant4:$shortG4version . 