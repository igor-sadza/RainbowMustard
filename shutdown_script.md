### Shutdown script

```sh
#!/bin/bash
###################################################################
#Script Name: shtudown_script
#Description: Check established connection.If any wait 30 minutes and shutdown server
#Args       :
#Author     : Igor Sadza
#Email      :
###################################################################

glob_current_time=0;
glob_extended_time=0;
glob_setup_extended_time=0;
glob_start_countdown=0;

while true
do
        sleep 0.1;
        glob_current_time=`date +'%s'`;
        glob_estab_connection=($(ss -tn src :80 or src :443 | grep ESTAB));

        if [ -z $glob_estab_connection ] && [ $glob_setup_extended_time -eq 0 ]
        then
                glob_start_countdown=1;
                glob_extended_time=`date -d '($wakeup_time) + 30minutes' +'%s'`;
                glob_setup_extended_time=1;

        elif [ ! -z $glob_estab_connection ] && [ $glob_setup_extended_time -eq 1 ]
        then
                glob_start_countdown=0;
                glob_setup_extend_time=0;
        fi

        if [ $glob_start_countdown -eq 1 ]
        then
                if [ $glob_current_time -ge $glob_extended_time ]
                then
                        ssh root@10.0.0.254 shutdown
                        exit;
                fi
        fi
done
```

### Create ssh-keygen 

Follow this <a href="https://serverfault.com/a/241593"><strong>serverfault</strong></a> instruction

```sh
ssh-keygen -t rsa -b 2048
ssh-copy-id user@server
```