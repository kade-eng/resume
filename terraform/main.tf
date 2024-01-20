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

resource "google_compute_global_address" "website" {
  provider = google
  name     = "website-lb-ip"
}

resource "google_dns_managed_zone" "my_dns_zone" {
  name     = "kade-bc-zone"
  dns_name = "kade-bc.com."
}

resource "google_dns_record_set" "website" {
  provider     = google
  name         = google_dns_managed_zone.my_dns_zone.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_dns_zone.name
  rrdatas      = [google_compute_global_address.website.address]
}

resource "google_dns_record_set" "www_record" {
  provider     = google
  name         = "www.${google_dns_managed_zone.my_dns_zone.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.my_dns_zone.name

  rrdatas = ["kade-bc.com."]
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "website" {
  provider    = google
  name        = "website-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.my_bucket.name
  enable_cdn  = true
}

# Create HTTPS certificate
resource "google_compute_managed_ssl_certificate" "website" {
  provider = google-beta
  name     = "website-cert"
  managed {
    domains = ["kade-bc.com", "www.kade-bc.com"]
  }
}

# GCP URL MAP
resource "google_compute_url_map" "website" {
  provider        = google
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website.self_link
}

# GCP target proxy
resource "google_compute_target_https_proxy" "website" {
  provider         = google
  name             = "website-target-proxy"
  url_map          = google_compute_url_map.website.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.website.self_link]
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  provider              = google
  name                  = "website-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.website.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.website.self_link
}