# KMS

* create and manage your keys in GCP
* Data Encryption Keys (DEK) are from Google
* DEK are then encrypted with Key Encryption Keys (KEK) , also called as Envelope Encryption
* KEK are either CMEK  or EKM

* when creating or read key version, for multi region locations, consensus across regions is needed, and hence less efficient
  * crypto ops doesnt need any consensus and hence multi region perform in similar manner as single region keys

## GMEK

* by default available, for data at rest and data in transit and **hence outside of scope of KMS**
* Automatically rotates keys and re-encrypts data.
* Supports encryption using AES-256.
* FIPS 140-2 Level 1 validated.

## CMEK
 
* You control automatic key rotation schedule; IAM roles and permissions; enable, disable, or destroy key versions.
* Supports symmetric and asymmetric keys for encryption and decryption.
* Automatically rotates symmetric keys.
* Supports several common algorithms.
* FIPS 140-2 Level 1 validated.
* FIPS 140-2 Level 3 validated ---> for `HSM`
* cost is medium, 1 per HSM, 0.06 for s/w
* You grant the CryptoKey Encrypter/Decrypter IAM role (roles/cloudkms.cryptoKeyEncrypterDecrypter) on the CMEK key to the service account for the service.
* Types
    1. Softwrae keys can be generated inside GCP
    2. keys can be created outside and imported into GCP
    3. HSM can be used too. If Cloud HSM is used, Google manages HSM cluster
    4. EKM - external keys, never get into Google for rest/storage, keys taken only for proessing but not stored
* CMEK-compliant service encrypts temporary data by using an `ephemeral` key that only exists in memory and is never written to disk. When the temporary data is no longer needed, the ephemeral key is flushed from memory. Without the ephemeral key, the encrypted data can't be accessed, even if the storage resource still exists
* location of key and resource must match. Some resources don't support *global* region

## CSEK

* this is outside of KMS
* need to provide KEY when creating/using storage object
* You provide key materials when needed.
* Key material resides in-memory - Google does not permanently store your keys on our servers.
* Might increase costs associated with Compute Engine or Cloud Storage
* supported only by GCE and GCS

## EKM External Key Manager

* keys are never sent to Google
* GCP services connect to EKM over internet or VPC
* keys can be software or hardware based
* Supports symmetric keys for encryption and decryption.
* Manually rotate your keys in coordination with Cloud EKM and your EKM provider.
* FIPS 140-2 Level 2 or FIPS 140-2 Level 3 validated, depending on the EKM.
* select location geographically as near as possible to external Key

## Cloud HSM

With Cloud HSM, you can generate encryption keys and perform cryptographic operations in FIPS 140-2 Level 3 validated * HSMs

* fully managed servcie
* Cloud HSM can be used with Cloud KMS or KMS API
* Each Cloud HSM key has an attestation statement that contains certified information about your key.
  * This attestation and its associated certificate chains can be used to verify the authenticity of the statement and attributes of the key and HSM.
* Limitations:
  * Message size limited to `8K` (sw keys have size of 64K)
  * not available in all regions
  * key operations for asymmetric keys stored in Cloud HSM may incur a noticeably greater latency


## Key types

* The purpose of a symmetric key is always Symmetric encrypt/decrypt.
  * single key
  * they always have primary version, used when version is not mentioned
* The purpose of an asymmetric key is either Asymmetric encrypt/decrypt or Asymmetric signing.
  * it has private (required to decrypt data or for signing) and public (required to encrypt data or to verify a signature) key parts
  * doesn't have any primary version
  * Signer needs `cloudkms.cryptoKeyVersions.useToSign`
  * Retriever or Validator needs `cloudkms.cryptoKeyVersions.viewPublicKey`
