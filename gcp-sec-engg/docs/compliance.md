
# Compliance

* Compliance Reports Manager shows all the reports
* Google Cloud meets many third-party and government compliance standards worldwide
* Google Cloud has been certified as secure, but that does not mean that applications built on Google Cloud are automatically certified
* Companies need to worry about only those services you build on
top of Google Cloud




## Assured Workload

* Use it only when - actively subject to regulatory compliance
* How to
  * Create an Assured Workloads folder
  * select Region and Compliance (HIPAA or FedRamp etc)
  * folder name should start with "aw"
  * add new CMEK - with new project
  * resource usage restriction organization policy - to add only supported APIs

* Compliance without compromise
* Simplified security and compliance
* Reduced cost and risk
* comply with data residency
* Cryptographic control over data access
* Assured Support
* Personnel data access controls based on attributes





## GDPR

* PII data protection in Europe (data stored in EU) - addresses data protection and privacy in the EU
  * It does apply to other countries doing business with EU entities and is very strict
* world-class levels of visibility and control over their data through our services
* Regulates how businesses can collect, use, and store personal data
* Builds upon current documentation and reporting requirements to increase accountability
* Authorizes fines on businesses who fail to meet its requirements

## PCI DSS - Payment Card Industry Data Security Standard

* cardholder data (CHD)
* CDE:  cardholder data environment.
* All systems that store, process, or transmit cardholder data (CHD) are in scope for your PCI DSS assessment.
* CLoud IDS is mandatory here
* to establish a “minimum security standard” **to protect customers’ payment card information**.
* The Attestation of Compliance provides formal assurance from a Qualified Security Assessor (QSA) as to adherence to the PCI DSS.
* This needs regular rotation of keys
* Implement network segmentation
  * place your CDE in a dedicated Virtual Private Cloud (VPC)
  * VPC not in default mode to avoid extra subnets
  * Implement Tokenization
  * in-scope apps in 1 VPC, out-of-scope apps in another (and if needed, both VPC can be peered)
  * one can use DLP API to sanitize PCI data
* GCP Tools:
  * Firewalls
  * VPC SC
  * VPC COnnectors
  * Implementing Security Command Center
* Requirements:
  * Implement segmentation and boundary protection
  * Configure least-privilege access to Google Cloud resources
  * Establish Organization-level policies
  * Enforce separation of duties through Shared VPC
  * Harden your cluster's security
  * Have File Integrity and Virus Scanning enabled

## HIPAA - Health Insurance Portability and Accountability Act

* `Healthcare` related
* The `HITECH` Act updated HIPAA and is concerned with promoting the adoption of electronic health records and meaningful use of health information technology
* Protected Health Information (PHI)
* complying with HIPAA is a shared responsibility between the customer and Google
* Following annual audits are done:
  * SSAE 16 / ISAE 3402 Type II
  * ISO 27001 - Requirements for an information security management system (ISMS), specifies a set of best practices
  * ISO 27017 - Cloud Security
  * ISO 20718 - Cloud Privacy (PII related)
  * FedRAMP ATO
  * PCI DSS
* Customer Responsibilities
  * to determine whether or not they are a Covered Entity
  * whether they require a Business Associate Agreement (BAA) with Google

* Best Practises
  * Execute BAA
  * Disable or don't use products not covered under BAA
  * Don't use pre-GA products
  * -------
  * check Encryption requirements
  * Object versioning for GCS
  * COnfigure Audit Log export
  * Configure Access Control - for audit and data logs
  * (audit) log analytics
  * Don't include/store PHI in DataStore, DialogFlow, Build
  * Use Secrets
  * Use CMEK for GCR and AR

## FedRamp - Federal Risk and Authorization Management Program

* Authority to Operate (ATO)
* a government-wide program that provides a standardized approach to the security assessment, authorization, and continuous monitoring of cloud products and services
* Google is one of the first hyperscale commercial cloud providers to achieve FedRAMP High on a commercial public cloud offering, and is one of the largest providers of FedRAMP services available on the market today
* Other docs are:

  * Customer Responsibility Matrix (CRM)
  * System Security Plan (SSP)
  * Penetration test reports and other documents

* Best practises:

  * define how to manage system accounts
  * time period of inactivity to log out the user
  * Use Org wide policies
  * define delay post 3 unsuccessful attempts
  * define triggers and conditions to terminate session
  * Use IAM to regulate user access to view, create, delete, and modify specific resources
  * Develop an organization-wide security assessment and authorization policy
  * Create an organization-wide configuration management policy
  * Set restrictions on the use of open source software across your organization
  * Develop a contingency plan for your organization
  * Develop a media protection policy for your organization

## SOC 2 - Service Organization Controls

* Audit for outsourced services
* The purpose of this report is to evaluate an organization’s information systems relevant to security, availability, processing integrity, confidentiality, and privacy
* Service Organization Controls (SOC) framework is the method by which the control of financial information is measured
* Relevant are different services: VPC Service Controls, DLP, Cloud Security Command Center, Cloud Armor etc


## ISO 27001

* Requirements for an information security management system (ISMS), specifies a set of best practices
* ONLY GUIDANCE, lays out allow Google to ensure a comprehensive and continually improving model for
security management

## ISO 27002

* Establishes commonly-accepted control objectives and best practices for implementing `measures to protect PII` in line with the *privacy* principles in ISO/IEC 29100 for the public cloud computing environment
* Stipulates guidelines based on ISO/IEC 27002, taking into consideration the regulatory requirements for the protection of PII which can apply to a public cloud service provider’s information security risk environment
* applies to all types and sizes of organizations, including public and private companies, government entities, and not-for-profit organizations, which provide information processing services as PII processors using contractual cloud computing with other entities



## ISO 27018

* cloud privacy: the protection of personally identifiable information (PII)
* Builds upon existing ISO/IEC 27002 controls by adding specific items for cloud privacy
* Provides entirely new security controls for personal data

## Chronicle GCP SIEM

* security information and event management (SIEM)
* Security Orchestration, Automation and Response (SOAR)
* Detect, investigate, and hunt for threats like never before
* Features:
  * Cloud-scale security analytics
  * Get faster insights with context rich investigation views
  * Conduct sub-second search across petabytes of information
  * Correlate petabytes of your telemetry with an advanced detection engine continuously updated with new rules and threat indicators
  * Active breach detection
  -------
  * Get to the root cause fast with an intuitive workbench
  * Proactively identify threats in your environment



## Other aspects

### Evaluating the security shared responsibility model (Access Transparency)

### Determining the Google Cloud environment in scope for regulatory compliance
