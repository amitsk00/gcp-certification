
# Best practises

## GFE

* The GFE is an HTTP/TCP reverse proxy which is used to serve requests to many Google properties including: Search, Ads, G Suite (Gmail, Chat, Meet, Docs, Drive, etc.), Cloud External HTTP(S) Load Balancing, Proxy/SSL Load Balancing, and many Cloud APIs
* 1st level sends request to backend, or through 2nd level in some cases
* GFE additionally applies protection against denial of service attacks.


## Cloud Armour

* WAF solution at GCP, ML based L7 protection against DDoS
* Mitigate OWASP Top 10 risks and help protect workloads
* Bot management to stop fraud at the edge through native integration with reCAPTCHA Enterprise
* security policies
  * to protect applications
  * define prioritized rules with configurable match conditions and actions
  * provide edge security and act on client traffic to **Google Front Ends (GFEs)**
  * works with Serverless NEG as well
  `preview mode` helps at early stages
* Threat Intelligence
* Named IP address lists
* Adaptive Protection
* works with below LB
  * Global external Application Load Balancer
  * Classic Application Load Balancer
  * External proxy Network Load Balancer
  * External passthrough Network Load Balancer




# Protection levels

## Data protection

### Governance




### Configuring format-preserving substitution

* `Pseudonymization` is a technique that replaces sensitive data with cryptographically generated tokens
  * also referred to as tokenization or surrogate replacement
* symmetric keys allow 2 ways changes and hence the name
* Types
  * Deterministic encryption using AES-SIV - produces hash and hence orig char set is not preserved, can re-identify
  * Format preserving encryption - both the character set and the length of the input value are preserved in the output value, can re-identify
    * char-set can be nemuric, hexa, alpha-numeric 
  * Cryptographic hashing - uses HMAC-SHA-256, length is same, but can't re-identify


### Restricting access to BigQuery, Cloud Storage, and Cloud SQL datastores




## Data Masking

<https://cloud.google.com/apigee/docs/api-platform/security/data-masking>

## Infra Security

* DDoS
* Firewalls
* IDS/IPS
* WAF
* Container Security

### Automating virtual machine image creation, hardening, maintenance, and patch management

* For added security, you can also use the Trusted image feature to define an organization policy (ompute.trustedImageProjects) that restricts images in specific public image projects from being used
* startup scripts - to load what you need, but in idempotent way
* The process of creating a custom image is called **baking**.
* Automated baking using Packer
* Enforcing lifecycle policies -
  * --delete-in or --delete-on
  * --obsolete-in or --obsolete-on
* `compute.imageUser` for using images from shared project

### Automating container image creation, verification, hardening, maintenance, and patch management

* NA

### Automating policy as code and drift detection

* `Chekov` from HSBC side
* Codify infrastructure and policies
* automate routine compliance checks
* Automated enforcement - Prevent non-compliance by asserting infrastructure and policies as code for easy onboarding on Google Cloud
* Detect non-compliance via Security Command Center, notifying stakeholders when offending infrastructure is identified.
* Modernize compliance by automating routine checks to reduce your audit fatigue

* Use `IaC` (like Terraform) to detect drift

* Drift -
  * In the context of infrastructure and application management, drift refers to the system state in which the actual configuration and state of the system deviate from the intended or expected configuration and state
  * automated by tools, scripts or services that analyze and compare configurations, resource states or event logs

## Scanning, Logging and Monitoring

* Vuln Scanning
* SIEM

