#!/bin/bash

####
# Deploy Userupdater Zip
# explode files to proper path
####

## set our build version ##
export build=$1

## make sure a build is specified
if [ "${build}x" == "x" ]; then
    echo "ERROR - no build specified.  ie: rtb-userupdater-v33.0.0"
    exit 1
fi

## make sure we are on an userupdater server ##
if [ ! -d /var/rsi/rtb/userupdater ]; then
    echo "ERROR - No userupdater directory to install to!"
    exit 1
fi

## make sure our build was copied (puppet!) ##
if [ ! -f /var/rsi/rtb/userupdater/${build}.zip ]; then
    echo "Error - could not find build ${build} to expand"
    exit 1
fi

## make the deploy directory for this build ##
if [ ! -d /var/rsi/rtb/userupdater/${build} ]; then
    mkdir /var/rsi/rtb/userupdater/${build}
fi


## make sure our deploy jar is in the directory and named apollo-userdata.jar
## extract files and exit
cp /var/rsi/rtb/userupdater/${build}.zip /var/rsi/rtb/userupdater/${build}/apollo-rtuserupdater.zip
cd /var/rsi/rtb/userupdater/${build}
unzip apollo-rtuserupdater.zip
chown -R rtuserfeed:rtuserfeed /var/rsi/rtb/userupdater/${build}

exit 0

