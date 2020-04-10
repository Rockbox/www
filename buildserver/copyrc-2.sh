#!/bin/bash
hash=$1
rcdir=/sites/download.rockbox.org/release-candidate

if [ "a" != "a$hash" ]; then
    if [ ! -d $rcdir ]; then
        mkdir $rcdir
    fi

    
fi

