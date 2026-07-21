# Networks  

## Concepts

### IPv6

* only IPv6 isnt supported
* single stack for IPv4
* dual stack for IPv4 and IPv6
* /48 ULA range within fd20::/20 is assigned if enabled on VPC
* VM gets /96 range from subnet
  * VM inherits IPv6 access type (internal or external) from subnet
* dual stack not supported on auto mode or legacy networks

### Routes

* applies for egress (from VM)
* System generated
* Custom
* Peering based

### Connectivity

* Private Google Access (*PGA*)
  * OnPrem/ VM to Google Cloud public API endpoints
  * Products like
    * GCS
    * BQ
    * Pub/Sub
* Private Service Access (*PSA*)
  * OnPrem/VM to Google Services in Google VPC
  * Needs VPC Peering
  * Products
    * CLoud SQL
    * Memcache
    * Cloud IDS
* Private Service Connect (*PSC*)
  * This is better than PSA, as no peering needed
  * single or many Consumer endpoints thru PSC to a single Producer Service attachment
  * Accessible from OnPrem too (without using public IP of PGA)
  * Enables using customer-defined private
endpoints using *.p.googleapis.com
* Follows VPC SC
  * Products like
    * Managed Services:
      * Google APIs
    * Producer VPC
      * Google services
      * 3rd party services
      * Intra-Org servcies
* Serverless VPC Access
  * gets access using VPC Connectors
  * its just /28 MIG on service VPC
  * Products like
    * CLoud Run
    * App Engine standard
    * Cloud Functions

### Network Security

* Configuring network perimeter controls
  * firewall rules
  * Identity-Aware Proxy (IAP)
* Configuring load balancing
  * global
  * network
  * HTTP(S)
  * SSL Proxy
  * TCP Proxy  
* Identifying Domain Name System Security Extensions (DNSSEC)
* Identifying differences between private versus public addressing
* Configuring web application firewall (WAF) (Google Cloud Armor)
* Configuring Cloud DNS

* Network Isolation
  * diff VPC for each need
  * one VPC for on-prem conn (VPN etc)
  * one VPC that allows public internet access
  * one VPC just within Google


## Designing perimeter security. Considerations include

### Configuring network perimeter controls (firewall rules, hierarchical firewalls, Identity-Aware Proxy [IAP], load balancers, and Certificate Authority Service)

### Identifying differences between private and public addressing

### Configuring web application firewall (Google Cloud Armor)

* Geo-based access control 
* Pre-configured WAF rules for SQL injection (SQLi) and Cross-Site Scripting (XSS) defense 
* A custom rules language for custom Layer 7 (L7) filtering policies 
* Security Command Center integration

### Configuring Cloud DNS security settings DNSSEC

* it can be specified at below levels:
  1. DNS zone
  2. top level domain
  3. DNS resolver
  

## Configuring boundary segmentation. Considerations include

### Configuring security properties of a VPC network, VPC peering, Shared VPC, and firewall rules

### Configuring network isolation and data encapsulation for N-tier application design

### Configuring VPC Service Controls

### Designing and configuring private connectivity between data centers and VPC network (IPsec and Cloud Interconnect)

### Using Cloud NAT to enable outbound traffic

* outbound connection to public internet (public NAT) or other VPC (private NAT) for
  * Compute Engine virtual machine (VM) instances
  * Private Google Kubernetes Engine (GKE) clusters
  * Cloud Run instances through Serverless VPC Access
  * Cloud Functions instances through Serverless VPC Access
  * App Engine standard environment instances through Serverless VPC Access
* If request is to Private Google Access, NAT is not used



### Firewall Insights

* helps to understand and optimize firewalls
* Metric
  * derived from Firewall logging - only if logging is enabled
* provides insights, recommendations, and metrics about how your firewall rules are being used
* overlapping ranges
* unused ranges or ports
* types
  * Shadowed firewall rule 
  * Overly permissive rule 
  * Deny with no hits
* Roles here:
  * Firewall Recommender Admin 
  * Firewall Recommender Viewer 



### Packet monitoring

* clone the traffic from VM (not VPC) and send for examination
* captures all traffic and package data, like payloads and headers
* Collector destination is an instance group that is behind an internal load balancer. Instances in the instance group are referred to as collector instances
  * internal passthrough Network Load Balancer.
  * forwarding rule must be configured for Packet Mirroring
* configure filters to collect traffic based on protocol, CIDR ranges (IPv4, IPv6, or both), direction of traffic (ingress-only, egress-only, or both), or a combination
* _priority of a packet mirroring policy is always 1000 and cannot be changed_
* VPC Flow Logs doesn't log mirrored packets (on target side)
* You cannot mirror and collect traffic on the same network interface of a VM instance because doing this would cause a mirroring loop
