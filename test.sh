#!/bin/bash

echo $INPUT_PUBLISH


if  [ "$INPUT_PUBLISH" == "true" ]
then
	PUBLISH=true
	echo "Publishing: "$PUBLISH""
fi
