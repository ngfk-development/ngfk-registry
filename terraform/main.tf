terraform {
  required_version = ">= 0.12"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }

  backend "gcs" {}
}

variable "project_id" {
  type = string
}

variable "verdaccio_image" {
  type = string
}

locals {
  project_id     = var.project_id
  project_number = data.google_project.project.number
  region         = "europe-west4"
  zone           = "europe-west4-a"

  verdaccio_image = var.verdaccio_image
  npm_domain      = "npm.ngfk.dev"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

data "google_project" "project" {}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_artifact_registry_repository" "docker" {
  project       = local.project_id
  location      = local.region
  repository_id = "docker"
  format        = "DOCKER"
}

resource "google_storage_bucket" "npm_registry" {
  name     = "${local.project_id}-npm-registry"
  location = local.region
}

resource "google_cloud_run_v2_service" "verdaccio" {
  name     = "verdaccio"
  location = local.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  depends_on = [
    google_storage_bucket.npm_registry
  ]

  template {
    containers {
      image = local.verdaccio_image

      env {
        name  = "VERDACCIO_PORT"
        value = 8080
      }

      env {
        name = "GITHUB_CLIENT_ID"
        value_source {
          secret_key_ref {
            secret  = "GITHUB_CLIENT_ID"
            version = "latest"
          }
        }
      }

      env {
        name = "GITHUB_CLIENT_SECRET"
        value_source {
          secret_key_ref {
            secret  = "GITHUB_CLIENT_SECRET"
            version = "latest"
          }
        }
      }

      env {
        name = "GITHUB_TOKEN"
        value_source {
          secret_key_ref {
            secret  = "GITHUB_TOKEN"
            version = "latest"
          }
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }
}

resource "google_cloud_run_domain_mapping" "npm" {
  name     = local.npm_domain
  location = local.region

  metadata {
    namespace = local.project_id
  }

  spec {
    route_name = google_cloud_run_v2_service.verdaccio.name
  }
}

resource "google_cloud_run_v2_service_iam_binding" "public" {
  project  = local.project_id
  location = local.region
  name     = google_cloud_run_v2_service.verdaccio.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

resource "google_secret_manager_secret_iam_member" "github_client_id" {
  secret_id = "GITHUB_CLIENT_ID"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "github_client_secret" {
  secret_id = "GITHUB_CLIENT_SECRET"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
}

resource "google_secret_manager_secret_iam_member" "github_token" {
  secret_id = "GITHUB_TOKEN"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${local.project_number}-compute@developer.gserviceaccount.com"
}
