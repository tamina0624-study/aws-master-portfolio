# Step 0 Setup Memo

## 1. Branch
- Branch name: `feature/cicd-bootstrap`
- Purpose: Build CI/CD learning pipeline incrementally without affecting `main`.

## 2. Target Directories
- Python app: `projects/17-cicd-pipeline/app`
- Python tests: `projects/17-cicd-pipeline/tests`
- Terraform: `projects/17-cicd-pipeline/terraform`

## 3. Planned CI/CD Variables
- `AWS_ROLE_ARN`: IAM role ARN for GitHub OIDC federation
- `AWS_REGION`: us-east-2
- `TF_WORKING_DIR`: Terraform working directory path
- `PYTHON_VERSION`: Python runtime for workflow (example: `3.12`)

## 4. GitHub Environment Variables (for later CD step)
- `DEPLOY_ENV`: `dev` / `stg` / `prod`
- `APP_NAME`: target application name

## 5. Secrets/Vars Policy
- Do not store long-term access keys in repository secrets if OIDC is available.
- Use repository/environment variables for non-sensitive values.
- Use GitHub Environment protection rules for `stg` and `prod` approvals.

## 6. Completion Check
- [x] Feature branch created
- [x] Target directories decided and created
- [x] CI/CD variable list documented
