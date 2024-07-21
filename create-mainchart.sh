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
# Check if yq is installed
if ! command -v yq &> /dev/null; then
  echo "yq is not installed. Please install yq to use this script."
  echo brew install yq   # for macOS using Homebrew
  echo sudo apt-get install yq  # for Ubuntu
  exit 1
fi
#to make the script idempotent
rm -rf "$folder"-mainchart
mkdir -p "$folder"-mainchart
cd "$folder"-mainchart

environments=("dev" "qa" "perf" "uat" "prod")

    for env in "${environments[@]}"; do
        echo "Processing environment: $env"
        helm create "$env"  
        rm -rf "$env"/templates/*  
        sed -e "s/PLACEHOLDER/${folder}-${env}/g" ../Chart.tmpl >  "$env"/Chart.yaml
        echo > "$env"/values.yaml
        yq e '.revision = "mybranch"'  -i "$env"/values.yaml

          for dir in $(find ../"$folder" -type d -name "chart"); do
            echo "Processing directory: $dir"
            parent_dir=$(dirname "$dir")
            parent_dir_name=$(basename "$parent_dir")
            echo "Parent Directory: $parent_dir"
            echo "Parent Directory Name: $parent_dir_name"

              name=$parent_dir_name
              version='0.1.0'
              repository='file://../'"$dir"/$env
            echo repo is $repository
            yq e ".dependencies += [{\"name\": \"$name\", \"version\": \"$version\", \"repository\": \"$repository\"}]" -i "$env"/Chart.yaml

            TAG=$( yq -r '.image.tag' ../$folder/$parent_dir_name/chart/$env/values.yaml )
            REPOSITORY=$( yq -r '.image.repository' ../$folder/$parent_dir_name/chart/$env/values.yaml )

            yq e ".${name}.image.tag = \"$TAG\"" -i "$env"/values.yaml
            yq e ".${name}.image.repository = \"$REPOSITORY\"" -i "$env"/values.yaml
            echo
            echo
          done
    done