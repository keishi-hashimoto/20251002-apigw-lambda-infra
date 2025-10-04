#!/bin/bash
#MISE dir="./src"

set -Ceo pipefail

WORKSPACE="$(terraform workspace show)"

terraform init -backend-config="bucket=${BUCKET_NAME}" -backend-config="key=${WORKSPACE}/${BUCKET_KEY}"