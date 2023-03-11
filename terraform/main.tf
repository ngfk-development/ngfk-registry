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

locals {
  project_id = var.project_id
  region     = "europe-west4"
  zone       = "europe-west4-a"
}

resource "google_project_service" "project" {
  project = local.project_id
  service = "artifactregistry.googleapis.com"
}

# resource "google_artifact_registry_repository" "npm-repository" {
#   location      = "us-central1"
#   repository_id = "npm"
#   description   = "example docker repository"
#   format        = "DOCKER"
# }
