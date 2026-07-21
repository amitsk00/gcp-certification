
# Org

## Defining resource hierarchy. Considerations include

### Creating and managing organizations

### Managing organization policies for organization folders, projects, and resources

### Using resource hierarchy for access control and permissions inheritance

## Imp notes

* each Google Workspace or Cloud Identity account is linked to only one Org (and 1 domain)
  * but a `user alias` domain or `secondary` domain can be added
* we can have multiple accounts with multiple Org, using same primary domain.

## Folders

* ` Folder Admin `or `Folder Creator` role to create folders

```cli
gcloud resource-manager folders create \
   --display-name=[DISPLAY_NAME] \
   --organization=[ORGANIZATION_ID]
```

* to change folder permission, you need `Folder IAM Administrator` or `Folder Admin`

```cli
gcloud resource-manager folders \
  add-iam-policy-binding [FOLDER_ID] \
  --member=user:email1@example.com \
  --role=roles/resourcemanager.folderEditor
```

* update Essential COntacts

```cli
gcloud essential-contacts update CONTACT_ID \
    --notification-categories="NOTIFICATION_CATEGORIES" \
    --language="LANGUAGE"
    --RESOURCE_TYPE="RESOURCE_ID"
```

```cli
resource "google_essential_contacts_contact" "contact" {
  parent = "RESOURCE_TYPE/RESOURCE_ID"
  email = "EMAIL"
  language_tag = "LANGUAGE"
  notification_category_subscriptions = NOTIFICATION_CATEGORIES
}
```

## Constraints

* roles/orgpolicy.policyAdmin needed to create policies

```cli
gcloud org-policies describe \
  LIST_CONSTRAINT --organization=ORGANIZATION_ID

gcloud org-policies describe \
  BOOLEAN_CONSTRAINT --organization=ORGANIZATION_ID  
```

* use tags to conditionally add organization policy constraints
  * can add multiple conditions within the same organization policy
  * tag to be created to enable the API, and org level constraint to check this tag and deny based on it

```cli
gcloud resource-manager tags keys create SHORT_NAME \
    --parent=RESOURCE_ID
```



## some roles

### Org Admin

* setup process and for lifecycle control for the organization resource
* They can
  * define IAM policies and grant
  * define hierarchy
* __cannot__ create folders or permissions (to make it least privileged)
