# CloudNest Security Architecture

CloudNest follows a layered security approach using Azure-native security services and zero-trust networking principles.

The goal of the security design is to reduce public exposure, avoid hardcoded secrets, and secure communication between Azure services.

## Security Components

- Azure Front Door with Web Application Firewall (WAF)
- Managed Identity
- Azure Key Vault
- Private Endpoints
- Private DNS Zones
- Azure RBAC
- HTTPS traffic enforcement
- Secretless authentication

## Web Application Firewall (WAF)

Azure Front Door is protected using a WAF policy.

The WAF helps protect the application against common web attacks such as:

- SQL injection
- Cross-site scripting (XSS)
- malicious HTTP requests
- suspicious traffic patterns

This provides an additional security layer before traffic reaches the application.

## Managed Identity

The Azure App Service uses a system-assigned Managed Identity.

This allows the application to authenticate securely to Azure services without storing usernames, passwords, or connection strings inside the application code.

## Azure Key Vault

Secrets are stored securely inside Azure Key Vault.

The App Service retrieves secrets using Key Vault references and Managed Identity authentication.

Example:

```text
@Microsoft.KeyVault(SecretUri=https://<keyvault-name>.vault.azure.net/secrets/<secret-name>/)
```
## Secretless Authentication Model

CloudNest uses a secretless authentication model by combining Azure App Service Managed Identity with Azure Key Vault.

Instead of storing secrets directly inside application code or configuration files, the App Service uses its managed identity to access secrets from Key Vault securely.

This improves security by reducing the risk of exposed credentials.

## Private Endpoints

CloudNest uses Private Endpoints to secure Azure services privately inside the virtual network.

Private Endpoints were configured for:

- Azure Storage Account
- Azure Key Vault

This reduces exposure to the public internet and allows backend Azure services to be accessed using private network connectivity.

## Private DNS Zones

Private DNS Zones were configured to support private name resolution for Private Endpoints.

Configured DNS Zones:

- `privatelink.blob.core.windows.net`
- `privatelink.file.core.windows.net`
- `privatelink.vaultcore.azure.net`

These zones allow Azure resources inside the virtual network to resolve private endpoint addresses correctly.

## RBAC and Access Control

Azure Role-Based Access Control (RBAC) is used to manage permissions across the CloudNest environment.

RBAC helps ensure:

- least privilege access
- centralized access management
- secure administrative operations

This supports controlled access to Azure resources based on user or service identity.

## HTTPS and Secure Access

HTTPS is enforced for application access through Azure Front Door and Azure App Service.

Public access to sensitive backend resources is minimized through private networking, firewall controls, and identity-based access.

## Zero-Trust Networking Approach

CloudNest follows zero-trust networking principles by:

- minimizing public exposure
- using private connectivity
- separating application and backend services
- using identity-based authentication
- enforcing least privilege access

This approach helps reduce the attack surface and improves the overall security posture of the platform.

## Summary

The CloudNest security architecture demonstrates how Azure-native services can be combined to create a more secure cloud platform using modern identity, networking, and governance practices.