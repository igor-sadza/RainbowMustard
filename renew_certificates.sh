#!/bin/bash

my_dns_names=(
         keycloak.biomed.org.pl
         bitwarden.biomed.org.pl
         seafile.biomed.org.pl
         iredmail.biomed.org.pl
         guacamole.biomed.org.pl
         grafana.biomed.org.pl
         onlyoffice.biomed.org.pl
         dashy.biomed.org.pl
);

function main() {

        configured_dns_names=( $(certbot certificates | grep Domains: | sed 's/.*s: //g') );
        #unset configured_dns_names[0];

        flag=0;
        for i in ${my_dns_names[@]}; do
                for j in ${configured_dns_names[@]}; do
                        if [ "$(echo $i | sed 's/-d//g')" != "$j" ]; then
                                flag=0
                        else
                                flag=1
                                break;
                        fi
                done 
        done

        my_dns_names=( "${my_dns_names[@]/#/-d }" )
        certificate_name=services.biomed.org.pl
        var=(
                "certbot"
                "certonly"
                "--cert-name $certificate_name"
                "--register-unsafely-without-email"
                "--agree-tos"
                "--standalone"
                "${my_dns_names[@]}"
        );

        if [ $flag -eq 1 ]; then
                var[1]="renew --force-renewal --no-random-sleep-on-renew"
                for i in {2..5}; do
                        unset var[$i]
                done

                range=$((${#var[@]} + ${#my_dns_names[@]}));
                echo $range
                for ((i=5;i<$range;i++)); do
                        unset var[$i]
                done
        else
                var[1]="certonly" 
        fi

        #echo ${var[@]}

        systemctl stop haproxy.service & 
        sleep 30 &
        eval ${var[@]} &
        cat /etc/letsencrypt/live/$certificate_name/{fullchain,privkey}.pem > /etc/letsencrypt/live/$certificate_name/$certificate_name.pem
        sleep 30 &
        systemctl start haproxy.service
};
main
