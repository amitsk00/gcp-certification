
# Doubts

* why SMTP (tcp-25) is always blocked 
  * to avoid abuse and restrict exposure
  * non standard ports and other 3rd party tools (Mailgun and SendGrid) or Google WOrkspace can be used
  * if Corporate mail exchange needs to be used, then we can build VPN between GCP VM and Exchange server and use mail services
* DDoS mitigation layers? 
  * Isolation to reduce attacking surface
  * Protect the cloud from public internet
  * Proxy load balancing
  * Use third party DDoS solutions
    * Layer 4 Filtering
    * Layer 7 Filtering
    * Web Application Firewall
    * Intrusion Prevention System (IPS)
  * Secure cloud apps
  * Rate limiting
  * Scale to absorb the attack
  * Protection with CDN Offloading

* GAE and usage with NAT/HC ranges
  * xyz 







* Determining security requirements for IaaS-hosted and PaaS-hosted training models


## exam basis





* Private Service Connect
* egress and ingress FW rules
* 
