#!/bin/bash

# Sergio Alías, 20240516
# Last modified 20240516

OUT_SEQ=$1
OUT_TAX=$2
P_VERSION=$3
P_TAXON=$4
P_CLUSTER=$5
P_SINGLETONS=$6

qiime rescript get-unite-data \
    --p-version $P_VERSION \
    --p-taxon-group $P_TAXON \
    --p-cluster-id $P_CLUSTER \
    $P_SINGLETONS \
    --o-sequences $OUT_SEQ \
    --o-taxonomy $OUT_TAX