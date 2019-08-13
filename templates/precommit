#!/bin/bash

mvn clean install

if [ "$?" -ne 0 ]
    then
    printf "\nEncountered error while building project. Terminating..."
    exit 1
fi
