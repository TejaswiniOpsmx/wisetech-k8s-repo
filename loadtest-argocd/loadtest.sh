#!/bin/bash

# Check if the number of tests is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_tests>"
  exit 1
fi

# Get the number of tests from the command line argument
num_tests=$1

# Output file
output_file="values.yaml"

# Start the YAML content
echo "apps:" > "$output_file"

# Generate the test entries
for (( i=1; i<=num_tests; i++ ))
do
  echo "  - name: \"test$i\"" >> "$output_file"
done

echo "YAML file '$output_file' generated with $num_tests test entries."
