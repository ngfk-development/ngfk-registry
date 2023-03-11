# NGFK Development - Registry

## NPM

`https://npm.ngfk.dev`

## Initial project setup

1. Created Google Cloud project
   - Project name: `ngfk-registry`
1. Add a bucket for terraform state
   - Bucket name: `ngfk-registry-tf-state`
1. Create a service-account for GitHub Actions
   - Account ID: `github-actions`
   - Email: `github-actions@ngfk-registry.iam.gserviceaccount.com`
1. Setup Workload Identity Federation (WIF) for GitHub Actions
   - Pool ID: `github`
   - Provider: `OpenID Connect (OIDC)`
   - Provider ID: `github-actions`
   - Issuer: `https://token.actions.githubusercontent.com`
   - Attribute `google.subject`: `assertion.sub`
   - Attribute `attribute.repository`: `assertion.repository`
1. Grant service-account access to WIF
   - Filter: `repository` = `ngfk-development/ngfk-registry`
