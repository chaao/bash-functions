#!/bin/bash

# default
PART="patch"

#get parameters
while getopts p: flag
do
  case "${flag}" in
    p) PART=${OPTARG};;
  esac
done

#get highest tag number, and add 1.0.0 if doesn't exist
CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [[ $CURRENT_VERSION == '' ]]
then
  CURRENT_VERSION='v0.0.0'
fi
echo "Current Version: $CURRENT_VERSION"


[[ $CURRENT_VERSION =~ ^v?([0-9]+)\.([0-9]+)\.([0-9]+)(-([0-9]+))? ]]
MAJOR="${BASH_REMATCH[1]}"
MINOR="${BASH_REMATCH[2]}"
PATCH="${BASH_REMATCH[3]}"
ALPHA="${BASH_REMATCH[5]}"

if [[ $PART == 'major' ]]
then
  MAJOR=$((MAJOR+1))
  MINOR="0"
  PATCH="0"
  ALPHA=""
elif [[ $PART == 'minor' ]]
then
  MINOR=$((MINOR+1))
  PATCH="0"
  ALPHA=""
elif [[ $PART == 'patch' ]]
then
  PATCH=$((PATCH+1))
  ALPHA=""
elif [[ $PART == 'alpha' ]]
then
  ALPHA="-$((ALPHA+1))"
else
  echo "No version type (https://semver.org/) or incorrect type specified, try: -p [major, minor, patch, alpha]"
  exit 1
fi



#create new tag
NEW_TAG="v$MAJOR.$MINOR.$PATCH$ALPHA"
echo "($PART) updating $CURRENT_VERSION to $NEW_TAG"

#get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

#only tag if no tag already
if [ -z "$NEEDS_TAG" ]; then
  git tag $NEW_TAG -m "$(git log --graph --topo-order --date=iso8601-strict --abbrev-commit --decorate --boundary --pretty=format:'%ad %h -%d %s [%cn]'  ...$CURRENT_VERSION)"
  git push origin $NEW_TAG
  echo "Tagged with $NEW_TAG"
else
  echo "Already a tag on this commit"
fi

exit 0

