#!/bin/bash
  
# stop haproxy to unlock port 80
haproxy stop

# renew all existing certs
certbot renew

# assing cert names to array
array_certificates=($(certbot certificates | grep Path | sed -e 's/.*live//' -e 's/pl.*/pl/' -e 's/^\///'));

# delete duplicates 
for i in ${!array_certificates[@]}
do
        for j in ${!array_certificates[@]}
        do
                if [[ ${array_certificates[i]} = ${array_certificates[j+1]} ]]
                then
                        unset 'glob_cert_names[j+1]' 
                fi; 
        done
done

# create single pem, move it to haproxy source folder
for cert in ${array_certificates[@]}
do
        path_and_cert_name=/etc/letsencrypt/live/$cert
        cat "$path_and_cert_name"/{fullchain,privkey}.pem > "$path_and_cert_name"/$cert.pem 
        cp "$path_and_cert_name"/$cert.pem /etc/haproxy/certs/ 
done
    
# restart haproxy
/etc/init.d/haproxy restart
