#!/bin/bash

## Input parameters START
# Read the YAML file
cd ..
file="action.yml"
cd action
# Use yq to extract the values
tag_type=$(yq e '.inputs.tag-type' $file)
version_value=$(yq e '.inputs.version-value' $file)

## Input parameters END

## major, minor, latest tag get START
if [[ $version_value == "0-0" ]]; then
  # Get the current year
  year=$(date +%Y)
  # Get the current month number
  month=$(date +%m)
  # Calculate the quarter
  if (( month <= 3 )); then
    quarter=1
  elif (( month <= 6 )); then
    quarter=2
  elif (( month <= 9 )); then
    quarter=3
  else
    quarter=4
  fi
else
  echo "version_value: $version_value"
  IFS='-' read -ra ADDR <<< "$version_value"
  year=${ADDR[0]}
  quarter=${ADDR[1]}
fi

## Calculation START
MAJOR=$year
MINOR=$quarter

## Calculation END

# Get all tags
git fetch --all --prune --tags
if [[ $tag_type == "prod" ]]; then
  ## prod tag START
  VERSION=$(git tag --sort=-committerdate | grep "m" | head -1)
  PATCH=0
  NEW_TAG=m$MAJOR.$MINOR.$PATCH
  ## prod tag END
elif [[ $tag_type == "develop" ]]; then
  ## develop tag START
  VERSION=$(git tag --sort=-committerdate | grep "d" | head -1)
  IFS='.' read -ra ADDR <<< "$VERSION"
  t1=${ADDR[2]}
  PATCH=$((t1+1))
  NEW_TAG=d$MAJOR.$MINOR.$PATCH
  ## develop tag END
elif [[ $tag_type == hotfix* ]]; then
  ## hotfix tag START
  IFS='-' read -ra ADDR <<< "$tag_type"
  t1=${ADDR[1]}
  t2=${ADDR[2]}
  VERSION=$(git tag --sort=-committerdate | grep -E "h${t1}-${t2}.*" | head -1)
  if [[ "h${t1}-${t2}" == "$VERSION" ]]; then
    PATCH=1
  else
    IFS='.' read -ra CBR <<< "$VERSION"
    t3=${CBR[3]}
    PATCH=$((t3+1))
  fi
  NEW_TAG=h${t1}-${t2}.${t3}
  ## hotfix tag END
elif [[ $tag_type == spfix* ]]; then
  ## spfix tag START
  IFS='-' read -ra ADDR <<< "$tag_type"
  t1=${ADDR[1]}
  t2=${ADDR[2]}
  VERSION=$(git tag --sort=-committerdate | grep -E "s${t1}-${t2}.*" | head -1)
  if [[ "s${t1}-${t2}" == "$VERSION" ]]; then
    PATCH=001
  else
    IFS='.' read -ra CBR <<< "$VERSION"
    t3=${CBR[3]}
    PATCH=$((t3+1))
  fi
  NEW_TAG=s${t1}-${t2}.${t3}
  ## spfix tag END
else
  echo "Wrong tag_type: $tag_type"
  exit 1
fi

## major, minor, latest tag get END

echo ::set-output name=new-version::$NEW_TAG
exit 0