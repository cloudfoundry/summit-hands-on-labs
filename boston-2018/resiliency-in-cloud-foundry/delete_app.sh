#/bin/bash

if [ $# -eq 0 ];
then
    echo "usage: $0 app_id app_instance_number"
    exit 0
fi

cf curl -X DELETE /v2/apps/$1/instances/$2
