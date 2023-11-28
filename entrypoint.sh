#!/bin/bash -l

# output the environment for debugging
#set

# activate the python virtualenv which is where we have our python dependencies installed
source /.virtualenvs/techdocs/bin/activate

cd /github/workspace

CATALOG_FILE=$(find . -type f -name catalog-info.yaml -o -type f -name catalog-info.yml)

# read the entity name and kind from the catalog-info file so we don't need to have these as inputs or vars.
ENTITY_NAME=$(cat "$CATALOG_FILE" | yq -r .metadata.name)
ENTITY_KIND=$(cat "$CATALOG_FILE" | yq -r .kind)

# map the local variables from the inputs provided by the Action
ENTITY_NAMESPACE="$INPUT_ENTITY_NAMESPACE"
TECHDOCS_S3_BUCKET_NAME="$INPUT_BUCKET_NAME"
TECHDOCS_S3_DEV_ROOT_PATH="$INPUT_S3_DEV_ROOT_PATH"
AWS_ENDPOINT="$INPUT_S3_ENDPOINT"
AWS_ACCESS_KEY_ID="$INPUT_S3_ACCESS_KEY_ID"
AWS_SECRET_ACCESS_KEY="$INPUT_S3_SECRET_ACCESS_KEY_ID"
AWS_REGION="$INPUT_S3_REGION"

echo "Building TechDocs from Markdown for entity '$ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME'"
techdocs-cli build --verbose --no-docker

if [ "$INPUT_PUBLISH" == "true" ]
then
	echo "Publishing TechDocs to DevHub..."
	echo "Bucket (secret): $TECHDOCS_S3_BUCKET_NAME"
	echo "Dev root path(var): $TECHDOCS_S3_DEV_ROOT_PATH"
	techdocs-cli publish --publisher-type awsS3 \
                --storage-name $TECHDOCS_S3_BUCKET_NAME \
                --entity $ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME \
                --awsEndpoint $AWS_ENDPOINT \
                --awsS3ForcePathStyle true \
                --awsBucketRootPath $TECHDOCS_S3_DEV_ROOT_PATH
fi


