<!-- ABOUT -->
## Requirements

Firstly you need to install <a href="https://github.com/aboul3la/Sublist3r"><strong>Sublist3r</strong></a>

```sh
apt-get install git python-requests python-dnspython; \
git clone https://github.com/aboul3la/Sublist3r.git
```

### Script

```sh
DOMAIN=igor-sadza.pl; \
python sublist3r.py -d $DOMAIN -o domains_list; \
sed -i 's/^/-d /' domains_list; \
sed -i ':a;N;$!ba;s/\n/ /g' domains_list; \
sed -i '1s/^/certbot certonly --standalone --expand -d '$DOMAIN' /' domains_list;  \
. domains_list; \
rm domains_list; \
cat /etc/letsencrypt/live/$DOMAIN/{fullchain,privkey}.pem > /etc/letsencrypt/live/$DOMAIN/$DOMAIN.pem
```


