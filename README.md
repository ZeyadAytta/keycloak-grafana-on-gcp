# GCP Infrastructure with Terraform

This project contains Terraform configurations to set up a complete infrastructure stack on Google Cloud Platform (GCP) consisting of:

- Google Kubernetes Engine (GKE) cluster
- Nginx Ingress Controller
- Cert-Manager with Let's Encrypt integration
- Keycloak with RADIUS authentication
- Grafana with Keycloak OAuth integration

## Architecture

The infrastructure follows a microservices architecture:

- **GKE Cluster**: Managed Kubernetes environment to host all services
- **Nginx Ingress**: HTTP/HTTPS traffic management and routing
- **Cert-Manager**: Automatic TLS certificate management using Let's Encrypt
- **Keycloak**: Identity and access management with RADIUS authentication for network devices
- **Grafana**: Monitoring and visualization platform with Keycloak SSO integration

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0+)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- A Google Cloud Platform account with billing enabled
- A registered domain for the Keycloak and Grafana services

## Getting Started

1. Clone this repository:
   ```
   git clone <repository-url>
   cd gcp-terraform
   ```

2. Authenticate with Google Cloud:
   ```
   gcloud auth application-default login
   ```

3. Update the `terraform.tfvars` file with your specific values:
   - Project ID
   - Region
   - Cluster configuration
   - Domain names
   - Passwords (or use environment variables for sensitive data)

4. Initialize the Terraform environment:
   ```
   terraform init
   ```

5. Create a plan to review the changes:
   ```
   terraform plan
   ```

6. Apply the configuration:
   ```
   terraform apply
   ```

## Configuration Details

### GKE Cluster

The GKE module creates a VPC-native cluster with configurable node count and machine types. It uses Workload Identity for GCP service access.

### Nginx Ingress

Deploys the Nginx Ingress Controller as a LoadBalancer service to handle incoming HTTP/HTTPS traffic.

### Cert-Manager

Installs cert-manager and configures it to use Let's Encrypt for automatic TLS certificate management.

### Keycloak

Deploys Keycloak with:
- RADIUS integration for network device authentication
- OIDC/OAuth2 for web applications
- Custom realm and client configuration
- TLS encryption using cert-manager

### Grafana

Deploys Grafana with:
- Persistent storage for dashboards and settings
- OAuth integration with Keycloak for authentication
- Role-based access control via Keycloak groups (Admin, Editor, Viewer)
- Automatic provisioning of test users

## Module Structure

- `modules/gke`: GKE cluster configuration
- `modules/nginx-ingress`: Nginx Ingress Controller installation
- `modules/cert-manager`: Cert-Manager installation and Let's Encrypt configuration
- `modules/keycloak`: Keycloak deployment with RADIUS
- `modules/grafana`: Grafana deployment
- `modules/grafana-keycloak`: Integration between Grafana and Keycloak
- `modules/keycloak-app-integration`: Generic module for integrating applications with Keycloak

## Variables

Key variables in this project:

| Variable | Description | Default |
|----------|-------------|---------|
| `project_id` | GCP Project ID | - |
| `region` | GCP Region | - |
| `cluster_name` | GKE Cluster name | - |
| `keycloak_hostname` | Hostname for Keycloak | - |
| `grafana_hostname` | Hostname for Grafana | - |
| `keycloak_admin_password` | Keycloak admin password | - |
| `grafana_admin_password` | Grafana admin password | - |
| `radius_shared_secret` | RADIUS shared secret | - |
| `realm_id` | Keycloak realm ID | "cloud52" |
| `realm_display_name` | Keycloak realm display name | "cloud52-Org" |

## Outputs

After successful deployment, the following outputs are available:

- `keycloak_url`: URL to access Keycloak admin console
- `grafana_url`: URL to access Grafana
- `radius_service_ip`: External IP for RADIUS service
- `keycloak_realm_id`: ID of the created Keycloak realm
- `auth_url`: Keycloak authentication URL
- `token_url`: Keycloak token URL

## Authentication

### Keycloak Administration

Access the Keycloak admin console at `https://<keycloak_hostname>` using:
- Username: `admin`
- Password: Value of `keycloak_admin_password` in your configuration

### Grafana

Access Grafana at `https://<grafana_hostname>` using:
- Direct login with admin credentials:
  - Username: `admin`
  - Password: Value of `grafana_admin_password`
- OAuth login through Keycloak (if configured)

### RADIUS

The RADIUS server is accessible at the IP address shown in the `radius_service_ip` output.
- Authentication port: 1812
- Accounting port: 1813
- Shared secret: Value of `radius_shared_secret`

## Customization

### Adding Custom Dashboards to Grafana

To add custom dashboards, you can:
1. Use the Grafana UI to create dashboards
2. Export them as JSON
3. Add them to a ConfigMap in the `modules/grafana` module

### Adding Users and Groups in Keycloak

The `modules/grafana-keycloak` module creates basic groups and test users. To add more:
1. Access the Keycloak admin console
2. Navigate to the realm specified in your configuration
3. Add users and groups as needed
4. Assign users to groups based on their Grafana access level

## Maintenance

### Scaling the GKE Cluster

To adjust the number of nodes:
1. Modify the `node_count`, `min_nodes`, or `max_nodes` variables
2. Run `terraform apply`

### Certificate Renewal

Certificates are automatically renewed by cert-manager before expiry. No manual intervention is required.

### Upgrading Keycloak or Grafana

To upgrade either service:
1. Update the version number in the respective module's variables
2. Run `terraform apply`

## Troubleshooting

### Common Issues

1. **Certificate issuance fails**:
   - Check DNS records point to the correct IP
   - Verify Let's Encrypt rate limits
   - Check cert-manager logs with `kubectl logs -n cert-manager -l app=cert-manager`

2. **Keycloak not accessible**:
   - Check ingress configuration with `kubectl get ingress -n keycloak`
   - Verify TLS certificate status
   - Check Keycloak logs with `kubectl logs -n keycloak -l app=keycloak`

3. **Grafana OAuth login fails**:
   - Verify the Keycloak client configuration
   - Check network connectivity between Grafana and Keycloak
   - Check browser console for CORS issues

## Security Considerations

This setup includes several security features:
- TLS encryption for all services
- OAuth2/OIDC for secure authentication
- RADIUS shared secret for network authentication
- Kubernetes RBAC for API security

For production use, consider these additional security measures:
- Use external database for Keycloak (PostgreSQL)
- Implement network policies in Kubernetes
- Configure audit logging
- Use Secret Manager for sensitive values

## License

This project is licensed under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
