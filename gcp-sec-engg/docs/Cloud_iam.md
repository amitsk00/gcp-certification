
# IAM

* SSO
* IAM
* Anti Malware
* MDM MAM (Mobile Device/App Mngmt)
* Gateways and CASB

## Other aspects

### Automating the user lifecycle management process

* SAML for Single Sign-On (SSO), for automated user provisioning
* Set up SSO with Google as your Identity provider

### Administering user accounts and groups programmatically

* new Cloud Identity Groups API
* Using the new API you can:
  * Create and delete groups
  * See and update group metadata
  * Add members to and remove members from a group
  * Modify member roles within a group

### Managing and creating short-lived credentials (SA)

### Configuring workload identity federation

* Workload Identity Federation - when some services of yours deployed outside of GCP (in on-premises or other hyperscalers) need to access GCP resources / APIs.
* Can be used with AWS or any that supports OIDC - like SAML2.0, MS AD
* federation is better/safer than using SA as keys can be a risk
* Workload Identity Pool is used for this

* AD
  * exchange their Active Directory Kerberos credentials for short-lived Google Cloud credentials.
  * Workloads can use these short-lived credentials to access Google Cloud APIs
    * Workload uses OIDC to get token or SAML Assertion
    * Workload then use Workload Identity Federation to exchange OIDC token or SAML Assertion against Security Token Service token

## Managing authentication. Considerations include

### Creating a password and session management policy for user accounts

* Create hash for the password
* Allow for third-party identity providers if possible
* Separate the concept of user identity and user account
* Allow multiple identities to link to a single user account
* Don't block long or complex passwords
* Validate the user's identity
* Let your users delete their accounts
* Use 2-Step Verification

* Session Management
  * Under Reauthentication policy, select Require reauthentication, and choose the Reauthentication frequency from the drop-down list.
  * The minimum frequency allowed is 1 hour, and the maximum is 24 hours.
  * The frequency doesn't include how long a user has been inactive in the session.
  * If SAML based IdP is used, then auth refresh request will be sent to IdP and can be re-auth without entering creds if session is valid on IdP
  * Use **Trusted List** as exception from this for special cases where auth isnt possible

### Setting up Security Assertion Markup Language (SAML) and OAuth

### Configuring and enforcing two-factor authentication

* (physical) security keys are safest (used by putting them in USB and then creating keys by touching the key)
* For Android phones, NFC or Bluetooth options can be used
* Or, a Google Prompt on known device
* Or, Google Authenticator app
* Backup codes
* SMS or phone call

### Applying Policy Intelligence for better permission management

* Reduce risk with automated policy controls
* Recommender: discover and remediate excessive permissions
  * Roles needed:
    * roles/recommender.iamViewer
    * roles/resourcemanager.projectIamAdmin
    * roles/iam.roleViewer
* Policy Troubleshooter: quickly resolve access control issues
  * users can visualize all the policies that grant or deny access to API calls
  * see which specific policies blocked the call
  * review an explanation of why the blocked call took place
  * Roles needed are:
    * roles/iam.securityReviewer
    * roles/iam.denyReviewer
    * roles/serviceusage.serviceUsageConsumer (to use CLI)

* Policy Analyzer: understand who has access to resources
  * Roles needed:
    * roles/cloudasset.viewer
    * roles/iam.roleViewer
    * roles/serviceusage.serviceUsageConsumer (to use CLI)
* Policy Simulator: Safely roll out policy changes

## Basic Concepts

### Configuring Workforce Identity Federation

* Workforce is group of users
* this is used to avoid GCDS and IdP will auth users and allow Google access
* works with OIDC or SAML2 like Azure AD, ADFS or Okta

* Configuring Access Context Manager

* Security Health Analytics - works through Sec Command Center

### Workload Identity

* Google Cloud provides service accounts to act as identities for workloads

  1. Attached servcie accounts - using this workload can access GCP services
  2. short lived token/creds - OAuth2 or OIDC token for SA
  3. GKE Workload Identity - GKE SA can act as IAM SA and access GCP servcies

* Workload identity federation: Use credentials from external identity providers to generate short-lived credentials, which workloads can use to temporarily impersonate service accounts. Workloads can then access Google Cloud resources, using the service account as their identity.
* Service account keys: Use the private portion of a service account's public/private RSA key pair to authenticate as the service account.

* Cloud Identity or Google Workspace accounts
  * OU
    * For Org, OU can be created to group users and create hierarchies
    * OU help to assign rules at top level
    * user : OU :: 1:1
    * user : Group :: 1:many
    * OU shudn't be used to manage acess - Groups are meant for access
  * Managed User Account
    * managed by Admin
    * primary email is ID, but can have aliases and recovery mail IDs
  * Groups
    * identified with mail ID - but need not be linked to mailbox
    * nesting of groups is allowed
  * External identities
    * using existing external ID and creds, using IdP
    * setting up SSO using SAML
    * this needs a user in GCP IAM which is identified by external users mail ID
    * GCP account : SAML IdP :: 1:1
    * Commonly used external IdPs include Active Directory Federation Services (AD FS), Azure AD, Okta, or Ping Identity
  * External authoritative source
  * External user account
  * External group

* Federated user identities - use external creds to federate on GCP
* Federation using Cloud Identity or Google Workspace - external ID uses External ID Provider (IdP) to access GCP. GCP also has ID for the same user - pref with same mail ID. GCDS or AD can be used to synch up IDs
* Workforce identity federation - can use IdP to auth group of users, **no need** to synch/GCDS

## IdP

* The maximum size for attribute mappings is 4 KB.

* Allow policy
  * Principal
  * Role
  * Condition - optional
  * etag - for consistency checking
  * version
* Deny policy
  * name : policies/ATTACHMENT_POINT/denypolicies/POLICY_ID
  * uid
  * kind
  * etag
  * displayName
  * createTime
  * updateTime
  * deniedPrincipals
  * exceptionPrincipals: Optional
  * deniedPermissions
  * Deny takes precedence over Allow

1. principal requests an access
2. system first checks Deny policy
    1. if access is denied (present in Deny policy), deny the request
    2. else (missing in Deny policy), go further
3. system checks for Allow policy
    1. if access is given (present in Allow policy), access is granted
    2. else (missing in Allow policy), access is denied

## GCDS

* Roles needed to start with
  * DNS Admin
  * external IdP Admin
  * future Admin of GCP Org

* Connects over HTTPS port and uses VPC access connector

* Steps to be taken:
  * Sign up for Cloud Identity or Google Workspace. During the sign-up process, you must provide a contact phone number and email address, the primary domain that you want to use, and the username for the first super-admin user account.
  * Verify the ownership of your primary domain by creating either a TXT or CNAME record in the corresponding DNS zone of your DNS server.
  * Add any secondary domains to the Cloud Identity or Google Workspace account.
  * Verify ownership of the secondary domains by creating either TXT or CNAME records in the corresponding DNS zones of your DNS server.
  * Protect your account by configuring security settings.
  * Create a default configuration for user accounts
* OU are not needed if ext IdP is being used
* OU specific for Google Workspace can be used as some settings can't be applied to groups and hence OU may be needed
  
* Azure AD:
  * CReate new OU in GCP - only for this reason
  * create new use to access Azure AD and add in this new OU
  * new user must be super-admin so that all user management is possible

  * In Azure portal, create new App as Google Cloud
    * In Attributes, map UPN Source as `mail`
    * From User Settings, all or some groups can be setup

    * Then, Azure AD SSO is needed for auth
    * Configure `SAML` for this  
      * Uisng Manage > SSO > SAML
      * provide reply and sign-on URL paths
      * Download SAML Signing Cert
      * For `Uniq User ID` use source as Mail
    * COnfigure Google WOrkspace for SSO
      * Open `Admin Console` and login as super-admin
      * Security > Auth > SSO with 3rd party IdP
      * Add URL for Sign-on, Sign-out and change=password (as setup previously on Azure AD)
      * For Verification Cert, upload prev downloaded cert (from Azure AD)

  * Main GCDS tasks:
    * It reads for LDAP, and using `Directory API` laods into Cloud Identity
    * for on-prem AD, its best to run GCDS on-prem
    * This process has sensitive info (and hence should remain within local network)
    * LDAPS (LDAP + SSL) or Cloud VPN can be used to encrypt the data
    * There needs a user on GCP side, with super-admin privs
  
### Configuring Google Cloud Directory Sync and third-party connectors

* synch Google with AD or LDAP
* Configure rules for custom mapping
* Uses rules and exclusions so you can omit data from a sync
* It uses OAuth for auth the APIs and SMTP for synch reports.
  * Directory API — Manages Chrome devices, groups, group aliases, members, organizational units, users, and user aliases.
  * Domain Shared Contacts API — Creates, deletes, and updates shared contact information for external contacts.
* it may take upto 8 days to synch as cache stays for 8 days
* To manually clear cache
    1. Run a sync from Configuration Manager and select to clear the cache when performing a sync.
    2. Use the command line flag -f to force a flush of the cache.
    3. Modify the XML config file to set the maxCacheLifetime value to 0.

### How GCDS works

* You set up rules to specify how the system generates a list of your data.
* During a sync, the list is exported from your LDAP server.
* GCDS connects to your Google Account and generates a list of users, groups, and shared contacts that you specify.
* LDAPS or VPN should be used for connection to make it secure
* GCDS compares these lists and updates your Google Account to match the data.
* After the synchronization, you get an email report so that you can monitor the process.

### Managing a super administrator account

[here](https://cloud.google.com/resource-manager/docs/super-admin-best-practices)
