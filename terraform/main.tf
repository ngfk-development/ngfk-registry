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

locals {
  project_id = var.project_id
  region     = "europe-west4"
  zone       = "europe-west4-a"
}

resource "google_project_service" "project" {
  project = local.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "npm" {
  repository_id = "npm"
  format        = "NPM"
}
