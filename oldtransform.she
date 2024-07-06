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


for dir in $(find $folder -mindepth 2 -maxdepth 2 -type d -name "deployment"); do
  parent_dir=$(dirname "$dir")
  parent_dir_name=$(basename "$parent_dir")
  echo "Directory: $dir"
  echo "Parent Directory: $parent_dir"
  echo copying deployment folder to chart folder
  echo
  mkdir -p "$parent_dir"/chart
  cp -r "$dir"/* "$parent_dir"/chart
  

  echo adding .helmignore file and Chart.yaml for every env after replacing PLACEHOLDER
for envdir in $(find "$parent_dir"/chart -mindepth 1 -maxdepth 1 -type d ); do
  echo environment is $envdir
  echo moving template files

  cp helmignore.tmpl "$envdir"/.helmignore
  sed -e "s/PLACEHOLDER/${parent_dir_name}/g" Chart.tmpl >  "$envdir"/Chart.yaml
  mkdir -p "$envdir"/templates
  mv "$envdir"/deployment.yaml "$envdir"/templates
  mv "$envdir"/service.yaml "$envdir"/templates
done
   echo
   echo 

done

