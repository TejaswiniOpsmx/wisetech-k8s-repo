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
  echo symlinking deployment folder to chart folder
  echo
  mkdir -p "$parent_dir"/linkchart
  

  echo adding .helmignore file and Chart.yaml for every env after replacing PLACEHOLDER

#envdir=mbe/test-new-ms/deployment/uat
for envdir in $(find "$parent_dir"/deployment -mindepth 1 -maxdepth 1 -type d ); do

  echo environment is $envdir
   env=$(basename "$envdir")
echo -----------------
  echo env is $env
echo ----------------------------
  echo linking values files
  mkdir -p "$parent_dir"/linkchart/$env
  cp helmignore.tmpl "$parent_dir"/linkchart/$env/.helmignore
  sed -e "s/PLACEHOLDER/${parent_dir_name}/g" Chart.tmpl >  "$parent_dir"/linkchart/$env/Chart.yaml


  cd "$parent_dir"/linkchart/$env
  rm -rf values.yaml
  ln -s ../../deployment/$env/values.yaml values.yaml
  ls -lrt values.yaml

  mkdir -p "$parent_dir"/linkchart/$env/templates
  #mv "$envdir"/deployment.yaml "$envdir"/templates
  #mv "$envdir"/service.yaml "$envdir"/templates

   cd templates
echo where am i
echo $parent_dir   $env     $CWD
pwd
echo where am i
ls -ltr
   rm -rf deployment.yaml
   rm -rf service.yaml
   ln -s ../../../deployment/$env/deployment.yaml deployment.yaml
   ln -s ../../../deployment/$env/service.yaml service.yaml
ls -ltr 

cd $CWD

done
   echo
   echo 

done

