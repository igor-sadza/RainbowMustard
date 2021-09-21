<!-- ABOUT THE PROJECT -->
## About The Project

Script for my rasbery-pi. I needed a way to wake up my server without logging into ssh.

<!-- GETTING STARTED -->
### Prerequisites

1. Install this packages
```sh
apt-get install sudo soacat certbot git python-requests python-dnspython;
```
Dont forget to rederict 80/443 ports to our linux machine!

2. Script needs ssl certificate

Install <a href="https://github.com/aboul3la/Sublist3r"><strong>Sublist3r</strong></a>

```sh
git clone https://github.com/aboul3la/Sublist3r.git
```

Generate your ssl cert

```sh
DOMAIN=YOUR-DOMAIN.COM; \
python sublist3r.py -d $DOMAIN -o domains_list; \
sed -i 's/^/-d /' domains_list; \
sed -i ':a;N;$!ba;s/\n/ /g' domains_list; \
sed -i '1s/^/certbot certonly --standalone --expand -d '$DOMAIN' /' domains_list;  \
. domains_list; \
rm domains_list; \
cat /etc/letsencrypt/live/$DOMAIN/{fullchain,privkey}.pem > /etc/letsencrypt/live/$DOMAIN/$DOMAIN.pem
```

3. Create script
```sh
cd /root/ && mkdir -p /bin/wol_script/ && vi /root/bin/wol_script/script.sh
```
```sh
#!/bin/bash
###################################################################
#Script Name: Wol script                                                                                         
#Description: Wait for http request and send magic packet for wol.                                                                                
#Args       :                                                                                           
#Author     : Igor Sadza                                             
#Email      :                                          
###################################################################

#Global variables
# ---------------------
glob_host_ip=10.0.0.254
glob_host_mac=00:0A:E6:3E:FD:E1
glob_ssl_cert=your.domain.com
glob_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )";

glob_https_request=0;
glob_current_time=0;
glob_wakeup_time=0;
glob_wakeup_time_extended=0;
glob_wakeup=0;
glob_start_pinging=0;
glob_iptables_rules=(
        'PREROUTING -t nat -p tcp -i wlan0 --dport 443 -j DNAT --to-destination IP:443' 
        'POSTROUTING -t nat -p tcp -d IP --dport 443 -j MASQUERADE' 
        'FORWARD -p tcp -d IP --dport 443 -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT'
        );
        
#If something goes wrong - wipe socat & iptables
# ---------------------
killall -9 socat
for ((i = 0; i < ${#glob_iptables_rules[@]}; i++))
do
        iptables -C ${glob_iptables_rules[$i]}
        if [ $? -eq 0 ]
        then
                iptables -D ${glob_iptables_rules[$i]}
        fi
done
iptables save

while true 
do 
        glob_current_time=`date +'%s'`; #+'%H:%M:%S'`;

#Check http request
# ---------------------
        if [ $glob_https_request -eq 0 ]
        then

                timeout 5 socat -T 1 \
                ssl-l:443, \
                reuseaddr, \
                cert=/etc/letsencrypt/live/$glob_ssl_cert/$glob_ssl_cert.pem, \
                verify=0, \
                fork, \
                reuseaddr, \
                keepalive, \
                keepidle=10, \
                keepintvl=10, \
                keepcnt=2, \
                crlf system:"cat "$glob_script_dir"/index.html; cat > "$glob_script_dir"/output"
      
                if [ -f "$glob_script_dir/output" ]
                then
                        var=($(grep wol "$glob_script_dir/output" | sed 's/^.*\(wol\).*$/\1/'));
                fi
                
                if [[ -n "${var}" ]]
                then
                        echo WAKEUP!
                        wakeonlan 04:92:26:da:e0:c8
                        glob_wakeup_time=`date +'%s'; #+'%H:%M:%S'`;
                        glob_wakeup_time_extended=`date -d '($wakeup_time) + 2minutes' +'%s'; #+'%H:%M:%S'`;
                        glob_https_request=1
                        sysctl net.ipv4.conf.wlan0.forwarding=1
                        for ((i = 0; i < ${#glob_iptables_rules[@]}; i++))
                        do
                                iptables -A ${glob_iptables_rules[$i]}
                        done
                        rm /root/bin/script_wait_for_wol/output
                fi
        fi

        fi

# Wait minute
# ---------------------
        if [ $glob_https_request -eq 1 ]
        then
                if [ $glob_current_time -ge $glob_wakeup_time_extended ] && [ $glob_wakeup -eq 0 ]
                then
                        glob_start_pinging=1
                        glob_wakeup=1
                        echo START_PINGING!
                fi
        fi

# Checks host is wakeup
# ---------------------
        ping_var=($(ping -w 1 10.0.0.200 | grep from));
        if [[ $glob_start_pinging -eq 1 ]] || [[ -n "${ping_var} ]]
        then
                if [ -n "${ping_var}" ]
                then
                        sysctl net.ipv4.conf.wlan0.forwarding=1
                        for ((i = 0; i < ${#glob_iptables_rules[@]}; i++))
                        do
                                iptables -C ${glob_iptables_rules[$i]}
                                while [ $? -eq 1 ]
                                do
                                        iptables -A ${glob_iptables_rules[$i]}
                                done
                        done
                fi
        elif [[ -z "${ping_var" ]]
        then
                glob_https_request=0
                glob_start_pinging=0
                glob_wakeup=0
                sysctl net.ipv4.conf.wlan0.forwarding=0
                for ((i = 0; i < ${#glob_iptables_rules[@]}; i++))
                do
                        iptables -C ${glob_iptables_rules[$i]}
                        while [ $? -eq 0 ]
                        do
                                iptables -D ${glob_iptables_rules[$i]}
                        done
                done
        fi
done
```

4. Run script and check if everything works fine.


### Create WOL service

1. Make it executable

```sh
chmod +x wol_script.sh
```
2. Create service file

```sh
vi /lib/systemd/system/wol.service
```
```
[Unit]
Description=Wol service

[Service]
Type=simple
ExecStart=/usr/bin/sudo /bin/bash /root/bin/wol_script/script.sh

[Install]
WantedBy=multi-user.target
```
3. Copy unit file to system

```sh
cp /lib/systemd/system/wol.service /etc/systemd/system/wol.service; \
chmod 644 /etc/systemd/system/wol.service
```
4. Start our new service
```sh
sudo systemctl start wol
```

### Usage

Go to your-domain.com. After a while your server will wake up!
