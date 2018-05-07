#!/bin/bash
DNS_RECORD="_acme-challenge IN TXT $CERTBOT_VALIDATION"
DNS_CONF_FILE="/var/named/$CERTBOT_DOMAIN"
echo "$DNS_RECORD" >> "$DNS_CONF_FILE"
#rndc reload $CERTBOT_DOMAIN
systemctl restart named;
