terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "Getting-Started-Azure"
    workspaces {
      name = "globo-web-dev"
    }
  }
}