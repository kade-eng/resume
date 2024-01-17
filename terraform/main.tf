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
  region  = "us-central1"
  zone    = "us-central1-b"
}

provider "google-beta" {
  project = "sincere-pixel-410716"
  region  = "us-central1"
  zone    = "us-central1-b"
}

resource "google_storage_bucket" "my_bucket" {
  name          = "kade-site-bucket"
  location      = "US"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket_object" "html_file" {
  name   = "index.html"
  bucket = google_storage_bucket.my_bucket.name
  source = "../site/index.html"
}

resource "google_storage_bucket_object" "css_file" {
  name   = "styles.css"
  bucket = google_storage_bucket.my_bucket.name
  source = "../site/styles.css"
}

resource "google_storage_bucket_object" "old_img" {
  name   = "old.png"
  bucket = google_storage_bucket.my_bucket.name
  source = "../site/imgs/old.png"
}

resource "google_storage_bucket_object" "new_img" {
  name   = "new.png"
  bucket = google_storage_bucket.my_bucket.name
  source = "../site/imgs/new.png"
}

resource "google_dns_managed_zone" "my_dns_zone" {
  name     = "kade-bc-zone"
  dns_name = "kade-bc.com."
}

resource "google_dns_record_set" "www_record" {
  name    = "www.kade-bc.com."
  type    = "CNAME"
  ttl     = 300
  managed_zone = google_dns_managed_zone.my_dns_zone.name

  rrdatas = ["www.kade-bc.com."]
}