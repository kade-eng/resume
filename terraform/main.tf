terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.10.0"
    }
    google-beta = {
      source = "hashicorp/google-beta"
      version = "5.10.0"
    }
  }
}

provider "google" {
  project = "sincere-pixel-410716"
  region  = "us-east1"
  zone    = "us-east1-b"
}

provider "google-beta" {
  project = "sincere-pixel-410716"
  region  = "us-east1"
  zone    = "us-east1-b"
}

resource "google_storage_bucket" "website_bucket" {
  provider = google
  name     = "kades-resume-website"
  location = "US"

  force_destroy = true
}