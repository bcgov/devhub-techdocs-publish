#!/bin/bash -l

echo "Input parameters: $*"

if [[ $* =~ "publish" ]] || [ "$INPUT_PUBLISH" == "true" ]; then
	echo "Content will be published after it is generated."
	PUBLISH=true
fi

if [[ $* =~ "preview" ]]; then
	echo "Previewer will be started for content after it is generated."
	PREVIEW=true
fi

# activate the python virtualenv which is where we have our python dependencies installed
source /.virtualenvs/techdocs/bin/activate

cd /github/workspace
cp /mkpatcher_scripts/* /github/workspace

CATALOG_FILE=$(find . -type f -name catalog-info.yaml -o -type f -name catalog-info.yml)

if [ -z "${CATALOG_FILE}" ]
then
	echo "No catalog-info file found in repo. Cannot continue."
	exit 1
fi

# read the entity name and kind from the catalog-info file so we don't need to have these as inputs or vars.
ENTITY_NAME=$(cat "$CATALOG_FILE" | yq -r .metadata.name)
ENTITY_KIND=$(cat "$CATALOG_FILE" | yq -r .kind)

# map the local variables from the inputs provided by the Action
ENTITY_NAMESPACE="default"
TECHDOCS_S3_BUCKET_NAME="$INPUT_BUCKET_NAME"
TECHDOCS_S3_DEV_ROOT_PATH="dev"
AWS_ENDPOINT="$INPUT_S3_ENDPOINT"
export AWS_ACCESS_KEY_ID="$INPUT_S3_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$INPUT_S3_SECRET_ACCESS_KEY"
export AWS_REGION="$INPUT_S3_REGION"

ENTITY_PATH="$ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME"

echo "Adjusting ownership of repo contents so git metadata can be read by 'git-revision-date-localized' mkdocs plugin..."
chown -R root /github/workspace

echo "Building TechDocs from Markdown for entity '$ENTITY_NAMESPACE/$ENTITY_KIND/$ENTITY_NAME'"
techdocs-cli build --verbose --no-docker

if [ $? -eq 0 ]; then
	echo "Successfully built content. Continuing."
else
	echo "Failed to build content. Abandoning. Please fix errors and try again."
	exit 1
fi


HTMLTEST_CONFIG_FILE=$(find . -type f -name .htmltest.yml -o -type f -name .htmltest.yaml)

if [ -f "${HTMLTEST_CONFIG_FILE}" ]; then
	echo "Using provided htmltest configuration file: '${HTMLTEST_CONFIG_FILE}'."
else
	echo "Using default htmltest configuration file."
	HTMLTEST_CONFIG_FILE="/.htmltest.yml"
fi

/htmltest -c $HTMLTEST_CONFIG_FILE ./site

if [ $? -eq 0 ]; then
	HTMLTEST_SUCCEEDED="true"
else
	HTMLTEST_SUCCEEDED="false"
fi

if [ "$HTMLTEST_SUCCEEDED" == "false" ]; then
	if [ "${INPUT_STRICT_VALIDATION}" == "true" ]; then
		echo "Link validation with 'htmltest' failed. The workflow will be terminated because strict validation is enabled. Please fix errors and try again. Please refer to documentation at https://github.com/bcgov/devhub-techdocs-publish/blob/main/docs/index.md and https://github.com/wjdp/htmltest for assistance fixing errors or configuring htmltest."
		exit 1
	else
		echo "Link validation with 'htmltest' failed. The workflow will continue because strict validation is not enabled. Please refer to documentation at https://github.com/bcgov/devhub-techdocs-publish/blob/main/docs/index.md and https://github.com/wjdp/htmltest for assistance fixing errors or configuring htmltest."
	fi
fi

if [ $PREVIEW ]; then
	techdocs-cli serve --verbose --no-docker
fi

if [ $PUBLISH ]
then
	echo "Publishing TechDocs to DevHub..."

	echo "Bucket : $TECHDOCS_S3_BUCKET_NAME"
	echo "Dev root path(var): $TECHDOCS_S3_DEV_ROOT_PATH"
	echo "Entity path: $ENTITY_PATH"
    echo "Endpoint: $AWS_ENDPOINT"
    echo "Region: $AWS_REGION"

    if [ -z "$AWS_ACCESS_KEY_ID" ]
    then
    	echo "AWS_ACCESS_KEY_ID is NOT set!"
		exit 1
	else
		echo "AWS_ACCESS_KEY_ID is set!"
	fi

	if [ -z "$AWS_SECRET_ACCESS_KEY" ]
	then
		echo "AWS_SECRET_ACCESS_KEY is NOT set!"
		exit 1

	else
		echo "AWS_SECRET_ACCESS_KEY is set!"
	fi

	echo "Publishing TechDocs to DEV..."
	techdocs-cli publish --publisher-type awsS3 \
                --storage-name "$TECHDOCS_S3_BUCKET_NAME" \
                --entity "$ENTITY_PATH" \
                --awsEndpoint "$AWS_ENDPOINT" \
                --awsS3ForcePathStyle true \
                --awsBucketRootPath "$TECHDOCS_S3_DEV_ROOT_PATH"

	# only publish to prod (root) folder of bucket if PRODUCTION input is true
	if [ "$INPUT_PRODUCTION" == "true" ]
	then
		echo "Publishing TechDocs to PROD..."
		techdocs-cli publish --publisher-type awsS3 \
                    --storage-name "$TECHDOCS_S3_BUCKET_NAME" \
                    --entity "$ENTITY_PATH" \
                    --awsEndpoint "$AWS_ENDPOINT" \
                    --awsS3ForcePathStyle true
	else
		echo "Not publishing TechDocs to PROD."
	fi
fi


