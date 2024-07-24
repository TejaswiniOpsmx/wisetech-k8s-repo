#!/bin/bash
file=$1
cat $file  | yq eval 'del(.metadata.annotations."kubectl.kubernetes.io/last-applied-configuration")' \
| yq eval 'del(.metadata.creationTimestamp)' \
| yq eval 'del(.metadata.generation)' \
|  yq eval 'del(.metadata.resourceVersion)' \
|  yq eval 'del(.metadata.uid)' \
| yq eval 'del(.status)'
