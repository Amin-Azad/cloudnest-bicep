# Portfolio deployment qualification

## Deployment profile

- Region: Sweden Central
- App Service: B1 Linux, 1 instance
- SQL Database: Free
- Single region
- Four private endpoints
- VNet integration enabled
- Key Vault, Storage, monitoring, RBAC, policies and diagnostics enabled
- Disaster recovery disabled
- Front Door disabled
- Deployment slot disabled
- Autoscale disabled

## Validation

Azure deployment validation completed successfully.

## What-If

- Create: 53
- Delete: 0
- Replace: 0
- Unsupported: 2

The two unsupported changes are role assignments whose principal IDs depend on the system-assigned managed identity of the Web App and are not resolvable by What-If before deployment.

No destructive changes were identified.
