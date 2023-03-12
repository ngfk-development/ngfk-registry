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

variable "nginx_image" {
  type = string
}

locals {
  project_id = var.project_id
  region     = "europe-west4"
  zone       = "europe-west4-a"

  nginx_image = var.nginx_image
  npm_domain  = "npm.ngfk.dev"
}

provider "google" {
  project = local.project_id
  region  = local.region
  zone    = local.zone
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_artifact_registry_repository" "npm" {
  project       = local.project_id
  location      = local.region
  repository_id = "npm"
  format        = "NPM"
}

resource "google_artifact_registry_repository" "docker" {
  project       = local.project_id
  location      = local.region
  repository_id = "docker"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "nginx" {
  name     = "nginx"
  location = local.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = local.nginx_image
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
    route_name = google_cloud_run_v2_service.nginx.name
  }
}

resource "google_cloud_run_v2_service_iam_binding" "public" {
  project  = local.project_id
  location = local.region
  name     = google_cloud_run_v2_service.nginx.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}
