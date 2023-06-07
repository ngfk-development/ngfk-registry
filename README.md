# NGFK Development - Registry

## Registry

- `https://npm.ngfk.dev`

## Manual setup

### Google Cloud Platform

Most of the Google Cloud Platform infrastructure is deployed using Terraform. To
get terraform to work properly from GitHub Actions these steps were taken.

1. Create GCP project
   - Project ID: `ngfk-registry`
1. Add a bucket for Terraform's state
   - Bucket name: `ngfk-registry-tf-state`
1. Create a service-account for GitHub Actions
   - Account ID: `github-actions`
   - Email: `github-actions@ngfk-registry.iam.gserviceaccount.com`
   - Role: `Owner`
1. Setup Workload Identity Federation (WIF)
   - Pool ID: `github`
   - Provider: `OpenID Connect (OIDC)`
   - Provider ID: `github-actions`
   - Issuer: `https://token.actions.githubusercontent.com`
   - Attribute `google.subject`: `assertion.sub`
   - Attribute `attribute.repository`: `assertion.repository`
1. Grant service-account access to WIF
   - Filter: `repository` = `ngfk-development/ngfk-registry`

### Verdaccio (NPM)

[Verdaccio](https://verdaccio.org/) is used as a lightweight NPM registry, with
GitHub accounts for
[authorization](https://github.com/n4bb12/verdaccio-github-oauth-ui). These
steps were taken to configure Verdaccio with GitHub.

1. Generate a GitHub oauth app
   - Name: `Verdaccio`
   - Homepage URL: `https://npm.ngfk.dev/`
   - Callback URL: `https://npm.ngfk.dev/-/oauth/callback`
1. Generate a personal GitHub access token
   - Name: `NGFK Development - Verdaccio`
   - Access: `repo` and `read:org`
1. Store information in Google Cloud Platform secret manager
   - Project ID: `ngfk-registry`
   - Client ID: `GITHUB_CLIENT_ID`
   - Client secret: `GITHUB_CLIENT_SECRET`
   - Token: `GITHUB_TOKEN`
