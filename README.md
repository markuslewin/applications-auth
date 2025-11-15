# Create app registration from workflow

The workflow (`deploy.yml`) logs in to Azure using federated identity credentials and creates an app registration in Microsoft Entra ID (`main.bicep`).

## Setup

```bash
bash provision-workflow.sh
```

`provision-workflow.sh` creates a resource group containing a user-assigned managed identity with a federated identity credential, which the workflow uses to log in to Azure.

`workflow.bicep` outputs values required by the workflow. The Bash script forwards these values as GitHub secrets using the GitHub CLI.

The workflow identity is given permission to create an app registration in Microsoft Entra ID using Microsoft Graph.

The identity is also made owner of the resource group. This isn't necessary in this project, but is required once we start provisioning actual resources into the resource group.

**The script sometimes fails due to [replication delays for created principals](https://github.com/microsoftgraph/msgraph-bicep-types/issues/193). Run the script again.**

## Cleanup

Delete the resource group:

```bash
az group delete --name "$RESOURCE_GROUP"
```

If the workflow created an app registration, delete that app:

```bash
az ad app delete --id $(
  az ad app list --filter "uniquename eq 'app-from-workflow'" \
    | jq -r '.[] | .id'
)
```

The app is soft-deleted and can be restored or permanently deleted in the portal.
