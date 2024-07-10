#!/bin/bash

# Check if the required argument is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path-to-yaml-file>, the yaml file should be a values.yaml from a mainchart"
  exit 1
fi

# Input YAML file
input_file=$1

# Check if the input file exists
if [ ! -f "$input_file" ]; then
  echo "File not found: $input_file"
  exit 1
fi

# Create a temporary YAML file
tmpfile=$(mktemp /tmp/apps.XXXXXX.yaml)

# Read app names from the YAML file
apps=($(yq eval '. | keys | .[]' "$input_file" | grep -v 'revision' | grep -v 'metadata' | grep -v 'annotations' | grep -v 'notifications' | grep -v 'image_list' | grep -v 'argocd-image-updater'))

# Construct the image list annotation
image_list="argocd-image-updater.argoproj.io/image-list: "
for app in "${apps[@]}"; do
  echo working on app $app
  repository=$(yq eval ".${app}.image.repository" "$input_file")
  image_list+="$app=$repository,"
done
image_list=${image_list%,}  # Remove the trailing comma

# Add the constructed image list annotation to the YAML file
yq eval --inplace ".metadata.annotations[\"argocd-image-updater.argoproj.io/image-list\"] = \"$image_list\"" "$tmpfile"

# Add entries for each app
for app in "${apps[@]}"; do
 # image_name=$(yq eval ".${app}.image.repository" "$input_file")
 # image_tag=$(yq eval ".${app}.image.tag" "$input_file")

  yq eval --inplace ".metadata.annotations += {
    \"argocd-image-updater.argoproj.io/$app.allow-tags\": \"regexp:^{{ .Values.branch }}\",
    \"argocd-image-updater.argoproj.io/$app.update-strategy\": \"latest\",
    \"argocd-image-updater.argoproj.io/$app.helm.image-name\": \"$app.image.name\",
    \"argocd-image-updater.argoproj.io/$app.ignore-tags\": \"*\",
    \"argocd-image-updater.argoproj.io/$app.ignore-tags\": \"somethingorother\",
    \"argocd-image-updater.argoproj.io/$app.helm.image-tag\": \"$app.image.tag\"
  }" "$tmpfile"
done

# Initialize the YAML file with annotations using yq
  yq eval --inplace ".metadata.annotations += {
   \"argocd-image-updater.argoproj.io/write-back-method\": \"git:secret:argocd/git-creds\" ,
   \"argocd-image-updater.argoproj.io/git-branch\": \"master\" ,
   \"notifications.argoproj.io/subscribe.on-deployed.github\": \"mainchart-qa-on-deployed\"
  }" "$tmpfile"

cat $tmpfile
pwd
cp $tmpfile ./$appname-annotations.yaml
rm $tmpfile

#mv "$tmpfile"  
#echo "YAML file created: annotations.yaml in folder: $top_folder"

#argocd-image-updater.argoproj.io/<image_name>.ignore-tags: "*"
