#/bin/bash 


if [ $# -eq 0 ];
then
    echo "usage: get_guid.sh application name"
    exit 0
fi

cf curl /v2/apps?q=name:$1 | grep \"guid\"  | awk -F "\"" '{print $4}'
