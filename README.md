# NGFK Development - Registry

## Registry

- `https://npm.ngfk.dev`

## Manual Google cloud steps

### Initial project setup

1. Created Google Cloud project
   - Project name: `ngfk-registry`
1. Add a bucket for terraform state
   - Bucket name: `ngfk-registry-tf-state`
1. Create a service-account for GitHub Actions
   - Account ID: `github-actions`
   - Email: `github-actions@ngfk-registry.iam.gserviceaccount.com`
   - Role: `Owner`
1. Setup Workload Identity Federation (WIF) for GitHub Actions
   - Pool ID: `github`
   - Provider: `OpenID Connect (OIDC)`
   - Provider ID: `github-actions`
   - Issuer: `https://token.actions.githubusercontent.com`
   - Attribute `google.subject`: `assertion.sub`
   - Attribute `attribute.repository`: `assertion.repository`
1. Grant service-account access to WIF
   - Filter: `repository` = `ngfk-development/ngfk-registry`

### Adding users

1. Create a user specific service account
   - Account ID: `rick-ngfk-dev`
   - Email: `rick-ngfk-dev@ngfk-registry.iam.gserviceaccount.com`
   - Role: `Artifact Registry Reader`
1. Create a new service account json key
1. Retrieve `.npmrc` settings
   - `gcloud artifacts print-settings npm --project=ngfk-registry --location=europe-west4 --repository=npm  --scope=@ngfk --json-key=$KEY_FILE_PATH`
   - Replace `europe-west4-npm.pkg.dev/ngfk-registry/npm` with `npm.ngfk.dev`
1. Store settings in users `~/.npmrc` file.
