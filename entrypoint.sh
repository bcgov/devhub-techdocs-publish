#!/bin/bash -l

# output the environment for debugging
set

# this value determines whether we build or publish @todo consolidate so we don't have to run two steps?
OPERATION=$INPUT_OPERATION

# activate the python virtualenv which is where we have our python dependencies installed
source /.virtualenvs/techdocs/bin/activate

cd /github/workspace

# read the entity name and kind from the catalog-info file so we don't need to have these as inputs or vars.
ENTITY_NAME=$(cat $(find . -name catalog-info.y*) | yq -r .metadata.name)
ENTITY_KIND=$(cat $(find . -name catalog-info.y*) | yq -r .kind)

if [ $OPERATION == "build" ]
then
	echo "Building TechDocs from Markdown for entity '$ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME'"
	techdocs-cli build --verbose --no-docker
elif [ $OPERATION == "publish" ]
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


