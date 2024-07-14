#!/bin/bash

# Check if a folder argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <folder>"
  exit 1
fi

# Assign the first argument to a variable
FOLDER="$1"

# Check if the provided argument is a valid directory
if [ ! -d "$FOLDER" ]; then
  echo "Error: $FOLDER is not a valid directory"
  exit 1
fi

CWD=$(pwd)
echo "Current folder is $CWD"

# Process directories
for DEPLOY_DIR in $(find "$FOLDER" -mindepth 2 -maxdepth 2 -type d -name "deployment"); do
  PARENT_DIR=$(dirname "$DEPLOY_DIR")
  PARENT_NAME=$(basename "$PARENT_DIR")

  echo "Directory: $DEPLOY_DIR"
  echo "Parent Directory: $PARENT_DIR"
  echo "Creating $PARENT_DIR/chart"
  mkdir -p "$PARENT_DIR/chart"

  # Process environment directories
  for ENV_DIR in $(find "$DEPLOY_DIR" -mindepth 1 -maxdepth 1 -type d); do
    ENV=$(basename "$ENV_DIR")
    CHART_DIR="$PARENT_DIR/chart/$ENV"

    echo "Environment: $ENV_DIR"
    echo "Creating $CHART_DIR"
    mkdir -p "$CHART_DIR"

    echo "Adding .helmignore and Chart.yaml for $ENV"
    cp helmignore.tmpl "$CHART_DIR/.helmignore"
    sed -e "s/PLACEHOLDER/${PARENT_NAME}/g" Chart.tmpl > "$CHART_DIR/Chart.yaml"

    cd "$CHART_DIR"
    pwd

    echo "Symlinking values.yaml"
    ln -sf "../../deployment/$ENV/values.yaml" values.yaml
    ls -lrt values.yaml

    mkdir -p templates
    cd templates
    pwd

    echo "Symlinking template files"
    ln -sf "../../../deployment/$ENV/deployment.yaml" deployment.yaml
    ln -sf "../../../deployment/$ENV/service.yaml" service.yaml
    ls -ltr

    cd $CWD
    pwd

  done

  echo

done
