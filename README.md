# About
Secure VPS and only permit SSH access from your home network.
Lookup Home IP and update the ufw SSH rule then send a ntfy notification.

The script could easily be adapted for other services like HTTP/HTTPS.
# Getting Started
## Prerequisites
* Dynamic DNS client
* ufw
* ntfy 
### Dynamic DNS
Use one of the free DDNS services or register a domain.  Enable regular updates by running a DDNS Client from within your home network.  This will provide IP updates to your Domain record when it changes.

I use the [Cloudflare Registrar](https://www.cloudflare.com/en-au/products/registrar/) for Domains and pfsense's [Dynamic DNS Service](https://docs.netgate.com/pfsense/en/latest/services/dyndns/index.html) to keep the DNS record updated.
#### ntfy
For notifications, use the paid or self hosted ntfy instance.
## Installation
Download script to your home directory
```bash
wget https://github.com/hhanzo1/update-ufw-rule/blob/main/update-ufw-rule.sh
chmod +x update-ufw-rule.sh
```

Update the following variables:

DNS_HOSTNAME=
NTFY_AUTH_TOKEN=
NTFY_TOPIC=

Replace ntfy.sh with your self hosted ntfy URL.
# Usage
Run the script manually to check it is working as expected, then scheduled via cron.
## Enable the update script
```bash
# Run every day
0 * * * * /home/[USERID]/update-ufw-rule.sh
```
There will be a ntfy push notification every time the update script is run.
# Acknowledgments
* [ufw](https://manpages.ubuntu.com/manpages/jammy/en/man8/ufw.8.html)
* [ntfy](https://ntfy.sh/)
