#!/bin/bash

mvn clean install
mvn checkstyle:checkstyle

read -p "Are you sure you want to commit?[Y/n] " answer
if [ $answer =  "Y" ] || [ $answer = "y" ] || [ $answer = "" ]
then
git commit
else
echo "Fix your errors first then commit."
fi

