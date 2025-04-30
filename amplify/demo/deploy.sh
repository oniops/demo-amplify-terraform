#!/bin/bash

CMD=$1

if [ ! -z "${PROJECT}" ] && ( [ "plan"=="${CMD}" ] || [ "apply"=="${CMD}" ] || [ "refresh"=="${CMD}" ] ); then
    terraform ${CMD} -var-file=./env/${PROJECT}.tfvars -state=./states/${PROJECT}.tfstate
fi
