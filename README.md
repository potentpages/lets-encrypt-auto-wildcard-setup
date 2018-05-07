# Let's Encrypt Automatic Wildcard Certificate Setup
How to automatically install Let's Encrypt Certificates to a Web Server (Named+Nginx/Apache)

## About This Tutorial
Looking to install a wildcard Let's Encrypt certificate automatically without needing an interactive terminal? Here's a quick script on how to do this:

## The Commands In One Go
```shell
sudo yum install -y certbot wget;
wget -o "/usr/local/src/authenticator.sh" https://static.potentpages.com/uploads/2018/05/authenticator.txt;
sudo chmod 700 "/usr/local/src/authenticator.sh"
certbot certonly --manual --server https://acme-v02.api.letsencrypt.org/directory  --preferred-challenges=dns --agree-tos --no-eff-email --manual-public-ip-logging-ok --rsa-key-size 4096 --email [[Your Email Address]] --manual-auth-hook /var/local/src/authenticator.sh -d *.[[Your Domain Name]] -d [[Your Domain Name]]
rm -rf "/usr/local/src/authenticator.sh"
```

## The Commands in More Detail
```shell
sudo yum install -y certbot wget;
```
This installs the certbot, the "automatic client that fetches and deploys SSL/TLS certificates for your webserver." https://certbot.eff.org/about/ . This is the program we will use to obtain our SSL certificate from the Let's Encrypt servers.  We will also need to use wget to download a callback for the certbot script.

```shell
wget -o "/usr/local/src/authenticator.sh" https://static.potentpages.com/uploads/2018/05/authenticator.txt;
```
This command downloads a script that will be used to copy the DNS information from the certbot over to a named config file for your domain. If you would rather not use wget, you can simply copy and paste the following code into "/usr/local/src/authenticator.sh"

```shell
#!/bin/bash
DNS_RECORD="_acme-challenge IN TXT $CERTBOT_VALIDATION"
DNS_CONF_FILE="/var/named/$CERTBOT_DOMAIN"
echo "$DNS_RECORD" >> "$DNS_CONF_FILE"
#rndc reload $CERTBOT_DOMAIN
systemctl restart named;
```

This script just copies the verification code from the shell parameters into a named dns configuration file. Please note that under some circumstances, a restart may be required for your name server. Otherwise, a simple "rndc reload" should work.

```shell
sudo chmod 700 "/usr/local/src/authenticator.sh"
```
We need to make our shell script executable, but only by the main user, not by everyone else. Opening it up to everyone could pose a security risk to your DNS server (we will be deleting the script at the end of this).

```shell
certbot certonly --manual --server https://acme-v02.api.letsencrypt.org/directory --preferred-challenges=dns --agree-tos --no-eff-email --manual-public-ip-logging-ok --rsa-key-size 4096 --email [[Your Email Address]] --manual-auth-hook /var/local/src/authenticator.sh -d *.[[Your Domain Name]] -d [[Your Domain Name]]
```
This is the main command that gets the certificate from Let's Encrypt. 

### Here's what each part means:
certbot: we need to run the certbot program
certonly: we're only looking to obtain a certificate
* --manual: we need to run the certbot program in manual mode, not using a plugin or the standalone web server.
* --server https://acme-v02.api.letsencrypt.org/directory: This tells the certbot that we need to use the ACME v02 servers, not the v1 ones. This is required in order to obtain wildcard certificates.
* --preferred-challenges=dns: This specifies that we will be using a DNS challenge. This is required in order to use the ACME v02 servers, which in turn is required for the SSL certifiate.
* --agree-tos: agree to the terms of service here: https://letsencrypt.org/repository/
* --no-eff-email: this doesn't register your email address to receive messages from the Electronic Frontier Foundation. If you would like to receive messages, please use "--eff-email" instead
* --manual-public-ip-logging-ok: this is required if you don't have an account; it will log the IP address of the server that's reqesting the certificate
* --rsa-key-size 4096: the size of the RSA key
* --email [[Your Email Address]]: this specifies your email address, and the one that will be associated with the SSL certificate. Please replace "[[Your Email Address]]" with your email address.
* --manual-auth-hook /var/local/src/authenticator.sh: This is the callback hook that's run before the DNS verification. The challenge information will be sent to the script so that it can be entered into the DNS configuraiton. This in turn allows your server to be verified.
* -d *.[[Your Domain Name]] -d [[Your Domain Name]]: These are your domain names. They specify what should be covered under the certificate. You can add more here if you want.

For more information on the [certbot commands, please go here](https://certbot.eff.org/docs/using.html#certbot-commands "List of Certbot Comands"): 

```shell
rm -rf "/usr/local/src/authenticator.sh"
```
This will remove the script from your server. This prevents it from being used to attack your DNS server.

If you want to learn more about automated server setup, please read our [Nginx+Apache+Lets Encrypt+more tutorial](https://potentpages.com/servers/hosting/page-load-under-2s-part-1).
