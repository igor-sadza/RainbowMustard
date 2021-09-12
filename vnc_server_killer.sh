#!/bin/bash
###################################################################
#Script Name: vnc_servers_killer
#Description: Kill running vncserver instances
#Args       :
#Author     : Igor Sadza
#Email      :
###################################################################
FILES="/home/igor/.vnc/*"
for f in $FILES
do
        var=($(echo "$f" | sed 's/^.*\.//'));
        if [ $var == 'pid' ] || [ $var == 'log' ]
        then
                if [ $var == 'pid' ]
                then
                        pkill "cat $f";
                        rm "$f";
                elif [ $var == 'log' ]
                then
                        rm "$f";
                fi
        fi
done
~     
