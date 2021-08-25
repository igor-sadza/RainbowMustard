#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
var=`qm list | grep 101 | grep 'running'`

VALUE_OUTPUT=`cat $SCRIPT_DIR/.win10-client-snapshot-restore-tmp`

if [ ! "${var}" ]
then
        if [ "${VALUE_OUTPUT}" == "restore" ]
        then
                qm rollback 101 configured
                echo "restored" > $SCRIPT_DIR/.win10-client-snapshot-restore-tmp
        fi
else
        echo "restore" > $SCRIPT_DIR/.win10-client-snapshot-restore-tmp
fi
