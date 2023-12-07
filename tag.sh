#!/bin/bash -l


usage() {
	echo "usage: tag.sh <tag_name>"
	exit 1
}

exitWithMessage() {
	echo $1

	if [ $# -eq 2 ]
      then
        exit $2
    else
    	exit 1
    fi
}


if [[ `git status --porcelain` ]]; then
	exitWithMessage "There are local changes. Please revert or commit these before running this command."
fi

if [ $# -eq 0 ]
  then
    usage
else
	TAG=$1
fi


read -p "Updating action file to use new Docker tag '${TAG}'. Press any key to continue..."
cat <<< "$(yq -oy '.runs.image |= envsubst' action.yml)" > action.yml

git commit -a -m "Updated action.yml to use a new Docker image with tag '${TAG}'."
#git push

git tag -a -m "adding version tag $TAG" $TAG
git push --follow-tags


