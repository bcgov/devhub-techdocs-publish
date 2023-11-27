#!/bin/bash -l


ACTION=$1
echo "Action: $ACTION"

source ~/.virtualenvs/techdocs/bin/activate
cd /src

if [ $ACTION == "build" ]
then
	echo "Building TechDocs from Markdown..."
	techdocs-cli build --verbose --no-docker
elif [ $ACTION == "publish" ]
then
	echo "Publishing TechDocs to DevHub..."
	techdocs-cli publish --verbose --no-docker
fi


