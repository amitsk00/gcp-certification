# Security

## Deploying Secure Web Proxy

* helps you secure egress web traffic (HTTP/S)
* web rqst can originate from VM, containers, serverless env and workloads connected by VPN
* Access to trusted external web services
* Monitored access to untrusted web services
  * Source ID using tags, SA or IP
  * Target ID using URLs, hostnames
  * Request based on methods, headers or URLs
  
## Access Context Manager [here](https://cloud.google.com/access-context-manager/docs/access-control)

<https://cloud.google.com/sdk/gcloud/reference/access-context-manager/perimeters/update>

* User + Device + Context is the new security perimeter
* Devcie type and OS + IP + user Identity

### Made up of

* Access Policy -
  * it has levels and perimeters
  * Policy can be at Org or Folder or Project level

* Access levels - its collection of conditions - like, device type, IP, ID

* IP Address
  * single Access Level can have multiple IP ranges
  * Access Levels **cannot include** private IP ranges (for example, 192.168.0.0/16, 172.16.0.0/12).

* Device Type - This would include OS and verion too

* User Identity -

* Workload Identity = used when microservices deployed to your GKE cluster need to access other GCP resources / APIs.
* Workload Identity Federation = when some services of yours deployed outside of GCP (in on-premises or other hyperscalers) need to access GCP resources / APIs.

## Apigee Security

* Automated API Security with ML based abuse detection
* Key Functionalities: Advanced API Security focuses on two key areas:
  * Identifying API Misconfigurations: It simplifies the process of finding API proxies that violate security standards, saving time for API teams.
  * Detecting Bots: It can effectively detect bots that successfully exploit APIs and return a 200 OK response, indicating successful data access.
* Fully managed comprehensive solution to build, manage, and secure APIs—for any use case or scale
* Managing high value/volume of APIs with enterprise-grade security and dev engagement
* Implement security in multiple layers with advanced controls
  * Better protect your web apps and APIs against threats and fraud with Google Cloud
  * Google Cloud WAAP can be used to protect applications on Google Cloud and on-premises
  * Google Cloud Web App and API Protection (WAAP)
    * Cloud Armor protects against DDoS attacks and common web application vulnerabilities (OWASP 10), and is WAF
    * Apigee manages API keys , enforces quotas , validates OAuth tokens and provides analytics on API trends
    * reCAPTCHA Enterprise protects against bot attacks

## Cert Authority

* Simplify the deployment, management, and security of your enterprise PKI
* Customize Certificate Authority Service to your needs by
  * configuring custom CAs and certificates
  * Custom key sizes and algos
  * enforcing granular access controls (with IAM and VPC SC)
  * automating common tasks with APIs
  * integrating with your existing systems
* Have peace of mind knowing that your CA service is highly available, scalable, backed by an SLA, auditable, and ready to help you achieve compliance with advanced hardware and software security controls
* Help lower your total cost of ownership and simplify licensing with pay-as-you-go pricing and zero capital expenditures
* Have confidence that your CAs are approved as part of ISO 27001, 27017, 27018, SOC1, SOC2, SOC3, BSI C5, and PCI DSS.
* `CA Pool` allows rotation seamless as no disruption by adding new cert in pool and revoking old one

* Help lower your total cost of ownership and simplify licensing with pay-as-you-go pricing and zero capital expenditures
* protect keys in HSM
* Audit logs

## Signed URL / Policy for GCS

* SA to have access to GCL
* signed URL to have access to anyone, temp basis
* Signed Policy Documents (UTF 8 and base64 encoded) specify what can be uploaded to a bucket with a form POST
* Allow greater control over size, content type, and other upload characteristics than signed URLs.

## OAuth

<https://cloud.google.com/apigee/docs/api-platform/security/oauth/oauth-home>

## Security Command Center

* Identify security misconfigurations and vulnerabilities in your Google Cloud environment and resolve them with actionable recommendations
* Uncover threats with specialized detectors
* Threat prevention - Uncover misconfigurations
* Threat detection
* Attack path simulation
* Duet AI
* SIEM and SOAR integrations

* Continuous exports findings work only for newly created findings.
* Continuous exports to Pub/Sub are usually used for forwarding findings to external security management systems such as Splunk or QRadar.
  * Pub/Sub can be created from Console
  * BQ is created using `gcloud scc bqexports create`

* Made up of
  * Container Threat [Detection](https://cloud.google.com/security-command-center/docs/concepts-security-sources#container-threat-detection)
  * Event Threat Detection
  * Rapid Vulnerability DetectionPreview
  * Secured Landing Zone servicePreview
  * Security Health Analytics
  * Virtual Machine Threat Detection
  * Web Security Scanner

* Sensitive Data Protection is supported only in organization-level activations of Security Command Center.

## Context aware  Access [here](https://cloud.google.com/access-context-manager/docs/overview)  

* to define fine-grained, attribute based access control for projects and resources
* This only defines policy, its enforced by others like VPC SC/IAP/IAM Conditions
* Access Policy is made up of
  * Access Levels
  * Service Perimeters

* made up of Access Level which is
  * Device type, operating system and version
  * IP address (can't include private IP ranges)
  * User identity

```cli
gcloud access-context-manager policies create \
--organization ORGANIZATION_ID [--scopes=SCOPE] --title POLICY_TITLE
```  

## Intrusion Detection System [here](https://cloud.google.com/security/products/intrusion-detection-system?hl=en)

* Easy deployment and minimal upkeep
  * Network-based threat detection
  * Cloud-native and managed
* Backed by industry-leading threat research ( built with Palo Alto Networks’ threat detection technologies)
  * Industry-leading security breadth and efficacy
* Supporting customers’ compliance goals
* Integrates with Chronicle (security analytics platform), SIEM and SOAR
* If using Shared VPC, single IDS can support multiple proj using shared VPC
* IDS Enpoint is a zonal resource which monitors
* uses *Packet Mirroring* based on
  1. subnet - all instances in t
  2. tags - upto 5 tags are allowed
  3. individual VM - upto 50
* Each IDS instance can capable of inspecting traffic in a single region
  1. it peers google network
  2. creates 3 VM on Google nextwork for IDS
  2. Private Service Access is a link between VPC and mirrored VPC
  2. packet mirroring and logs are used by this
* This is needed for PCI DSS and HIPAA

## Implementing security controls for AI/ML systems

* `SAIF` Secure AI Framework
* Expand strong security foundations to the AI ecosystem
* Extend detection and response to bring AI into an organization’s threat universe
  * Monitor Gen AI input and output
  * Threat Intelliegence to anticipate atatcks
* Automate defenses to keep pace with existing and new threats
* Harmonize platform level controls to ensure consistent security across the organization
  * support AI risk mitigation and scale protections across different platforms and tools
  * Perspective API
* Adapt controls to adjust mitigations and create faster feedback loops for AI deployment
  * reinforcement learning based on incidents and user feedback
  * updating training data sets, fine-tuning models to respond strategically to attacks
* Contextualize AI system risks in surrounding business processes
  * construct automated checks to validate AI performance
* Google Cloud Security AI Workbench
  * threat overload
  * toilsome tools
  * the talent gap
* prevent threats from spreading
  * VirusTotal Code Insight
  * Mandiant Breach ANalysis for Chronicle - everage Sec-PaLM to quickly find, summarize, and act on threats
  * reCaptcha
  * Assured OSS - FOSS vuln management

## DLP

### InfoTypes

* Pre Defined - many options are available
* Custom - can be created based on need - like, custom internal mail ID , and then `likelihood` can be attached to each
  * small/regular custom dict
    * use when list is static
    * count can be in thousands
    * e.g. Room Names
  * large/stored custom dict
    * when the list is present in bucket or BQ
    * count can be in millions
    * list of phrases is stored in BQ table or bucket file, and then DLP converts that into a dict file (not editable by users)

  * RegEx

* these types can be of INCLUDE or EXCLUDE category
  * Exclude can be used to reduce the outcome
  * Hotword - can be used to increase the likelihood
* These can be RegEx , digits with precision, math checksum or prefixes
* `Likelihood` is returns by API to confirm the same as name suggests

### Inspection

* Inspection jobs -  You can inspect a BigQuery table, a Cloud Storage bucket or folder, and a Datastore kind
* content.inspect -  method of the DLP API lets you send data directly to the DLP API for inspection
* hybrid job - lets you scan payloads of data sent from any source, and then store the inspection findings in Google Cloud

### De-Identify

* Create a de-identified copy of Cloud Storage data using an inspection job
* content.deidentify - request to the DLP API

* `dlpJob` to create the job

### Sensitive Data Protection provides the following method types

* Content methods - data sent directly to API
* Storage methods - data is stored in storage
* Hybrid methods - request starts as COntent method, but results are stored as Storage

### Inspecting and redacting personally identifiable information (PII)

* Healthcare API is a good option for redacting images
* DLP API is also now for sensitive  data protection

### de-identification

* Redaction: Deletes all or part of a detected sensitive value.
* Replacement: Replaces a detected sensitive value with a specified surrogate value.
* Masking: Replaces a number of characters of a sensitive value with a specified surrogate character, such as a hash (#) or asterisk (*).
* Crypto-based tokenization: Encrypts the original sensitive data value using a cryptographic key. 
  * Sensitive Data Protection supports several types of tokenization, including transformations that can be reversed, or "re-identified."
* Bucketing: "Generalizes" a sensitive value by replacing it with a range of values. 
  * For example, replacing a specific age with an age range, or temperatures with ranges corresponding to "Hot," "Medium," and "Cold."
* Date shifting: Shifts sensitive date values by a random amount of time.
* Time extraction: Extracts or preserves specified portions of date and time values.

### Configuring pseudonymization

* de-identification technique that replaces sensitive data values with cryptographically generated tokens.
* 2 types
  * one way
  * two way (using symmetric keys)

---

### Configuring and monitoring Security Command Center (Security Health Analytics, Event Threat Detection, Container Threat Detection, Web Security Scanner)

### Identity Aware Proxy IAP

* Control access to your cloud-based and on-premises applications and VMs (SSH and RDP) running on Google Cloud
* Verify user identity and use context to determine if a user should be granted access
  * Admins can create and enforce granular access-control policies based on attributes like user identity, device security status, and IP address
* Work from untrusted networks without the use of a VPN (zero trust model)
* when to use:
  * With IAP, you can set up group-based application access: a resource could be accessible for employees and inaccessible for contractors, or only accessible to a specific department
  * when you want to enforce access control policies for applications and resources
  * works with signed headers or GAE Standard as well
* IAP doesn't handle HC - JWT header validation allows the health check path
* Signed headers provide secondary security in case someone bypasses IAP
  * it strips the x-goog-* headers provided by the client
  * JWT is in the HTTP request header x-goog-iap-jwt-assertion
    * JWT header Algorithm ES256

### Cloud Asset Inventory

* earlier this was done using Forseti - Inventory, Identify, Report, Enforcer
* Now this is part of IAM
* An `asset snapshot` is the set of available assets under a Resource Manager project, folder, or organization at a specific timestamp.
* keeps 35 days of history of metadata
  * if no changes to the data, latest entry is always maintained
  * data can be exported to BQ or GCS for analysis on timely basis

### Web Security Scanner

* Identify security vuln in web apps like GAE, Run, GKE or VM based web apps
* currently supports *only public URLs and IPs* that are **not** behind firewall
* it crawls all links from the starting URL specified with all inputs and event handlers
  * sends GET  requests only
* Caution:
  * cant detect all vuln
  * not suitable to be used in Prod env - can adversely affect reliability of the app
  * it may not start scanning immed
  * it may take hours based on app size (24 hrs too)
  * if `IAP` is enabled on app, ensure that Web Security Scanner SA has `IAP Secured Web App User` role
    * when IAP is used, for OAUTH client ID, use IAP pages to get client ID to be added on WSS
* managed scans work only with def port, 80 for HTTP and 443 for HTTS, for others we have to use Custom Scans
  * managed scans
    * through Security Comamnd Center (SCC)
    * if used as service, the Vuln are shown in SCC pages
  * Custom scans
    * need extra setup to show Vuln in SCC
* Best Practises
  * Run scans in TEST env
  * Run scans with test ID which doesn't have access to PII or sensitive info
  * block user interface events
  * backup the data before scans
  * excluded URLs can be used to exclude some part from scan
* COmmon findings
  * mixed mode (HTTP + HTTPS)
  * expired libraries
  * clear text passwords
  