#!/bin/bash -l

# output the environment for debugging
set

ACTION=$1
# read the entity name and kind from the catalog-info file
ENTITY_NAME=$(cat $(find . -name catalog-info.y*) | yq -r .metadata.name)
ENTITY_KIND=$(cat $(find . -name catalog-info.y*) | yq -r .kind)

source /.virtualenvs/techdocs/bin/activate
cd /github/workspace

if [ $ACTION == "build" ]
then
	echo "Building TechDocs from Markdown for entity '$ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME'"
	techdocs-cli build --verbose --no-docker
elif [ $ACTION == "publish" ]
then
	echo "Publishing TechDocs to DevHub..."
	echo "Bucket (secret): $TECHDOCS_S3_BUCKET_NAME"
	echo "Dev root path(var): $TECHDOCS_S3_DEV_ROOT_PATH"
#	techdocs-cli publish --publisher-type awsS3 \
#                --storage-name $TECHDOCS_S3_BUCKET_NAME \
#                --entity $ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME \
#                --awsEndpoint $AWS_ENDPOINT \
#                --awsS3ForcePathStyle true \
#                --awsBucketRootPath $TECHDOCS_S3_DEV_ROOT_PATH
fi


