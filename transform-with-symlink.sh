#!/bin/bash

# Check if a folder argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

# Assign the first argument to a variable
folder="$1"

# Check if the provided argument is a valid directory
if [ ! -d "$folder" ]; then
  echo "Error: $folder is not a valid directory"
  exit 1
fi

CWD=$(pwd)
echo current folder is $CWD

#dir=mbe/test-new-ms/deployment
for dir in $(find $folder -mindepth 2 -maxdepth 2 -type d -name "deployment"); do
  parent_dir=$(dirname "$dir")
  parent_dir_name=$(basename "$parent_dir")
  echo "Directory: $dir"
  echo "Parent Directory: $parent_dir"
  echo
  echo making "$parent_dir"/chart
  mkdir -p "$parent_dir"/chart
  

#envdir=mbe/test-new-ms/deployment/uat
for envdir in $(find "$parent_dir"/deployment -mindepth 1 -maxdepth 1 -type d ); do

  echo environment is $envdir
   env=$(basename "$envdir")
echo -----------------
  echo env is $env
echo ----------------------------
  echo making "$parent_dir"/chart/$env
  mkdir -p "$parent_dir"/chart/$env
  echo adding .helmignore file and Chart.yaml for every env after replacing PLACEHOLDER
  cp helmignore.tmpl "$parent_dir"/chart/$env/.helmignore
  sed -e "s/PLACEHOLDER/${parent_dir_name}/g" Chart.tmpl >  "$parent_dir"/chart/$env/Chart.yaml

  cd "$parent_dir"/chart/$env
pwd
echo symlinking values.yaml
  rm -rf values.yaml
  ln -s ../../deployment/$env/values.yaml values.yaml
  ls -lrt values.yaml

  mkdir -p templates
   cd templates
pwd
echo symlinking template files
ls -ltr
   rm -rf deployment.yaml
   rm -rf service.yaml
   ln -s ../../../deployment/$env/deployment.yaml deployment.yaml
   ln -s ../../../deployment/$env/service.yaml service.yaml
ls -ltr 

cd $CWD
pwd

done
   echo
   echo 

done

