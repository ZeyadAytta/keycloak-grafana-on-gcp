resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.cluster_name}-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count
  
  # Add existing autoscaling configuration
  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }
  
  # Add upgrade_settings parameter
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }
  
  node_config {
     machine_type = var.machine_type
     disk_size_gb = var.disk_size_gb
     disk_type    = var.disk_type
     image_type   = var.image_type 
    # Workload metadata configuration
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
    
    # Kubelet configuration
    kubelet_config {
      cpu_manager_policy = "none"
      cpu_cfs_quota      = false
      pod_pids_limit     = 0
    }
    
    # Add linux_node_config (with minimal configuration)
    linux_node_config {
      sysctls = {
        "net.core.somaxconn" = "1024"
      }
    }
    
    # Add tags parameter
    tags = ["gke-node"]
    
    # Add taints parameter
    taint {
      key    = "node.kubernetes.io/unschedulable"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
    
    # Add labels parameter
    labels = {
      environment = "prod"
    }
    
    # Add resource_labels parameter
    resource_labels = {
      "team" = "devops"
    }
    
    # OAuth scopes for permissions
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
  
  # Add management parameter (for update behavior)
  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
