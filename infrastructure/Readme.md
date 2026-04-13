# Infrastructure

For the History Through Art Jekyll site (hosted on **GitHub Pages**).

## Image hosting

- **S3:** Private bucket (Block Public Access); objects are **not** served directly from S3 URLs.
- **CloudFront:** Distribution in front of S3 with **Origin Access Control (OAC)**; browsers and the site use the **CloudFront hostname** (custom domain optional).
- **Responsive images:** No edge resizing. From each original, generate a few widths (e.g. 480 / 960 / 1440) plus **WebP/AVIF** (or as needed) **locally via CLI**, sync to S3. Jekyll uses **`srcset` / `sizes` or `<picture>`** so mobile loads smaller files.
- **Uploads:** Single operator; **`aws s3 sync`** (or `cp`) after generation. Delete with **`aws s3 rm`**; invalidate CloudFront only if you reuse the same URL.

**IaC:** **Terraform** in this directory provisions the bucket, OAC, distribution, and bucket policy.


### Terraform usage

From this directory (AWS credentials configured, e.g. `AWS_PROFILE`):

```bash
terraform init
terraform plan
terraform apply
```

After apply, use **`terraform output`** for the S3 bucket name and CloudFront URL. Upload with `aws s3 sync` / `cp` using an IAM principal that has **`s3:PutObject`**, **`s3:DeleteObject`**, and **`s3:ListBucket`** on that bucket (and **`cloudfront:CreateInvalidation`** on the distribution if you invalidate after overwrites).

State is local by default; add a **remote backend** (e.g. S3 + DynamoDB) when you want team/shared applies.


### Terraform files

| File | Purpose |
|------|--------|
| `versions.tf` | Terraform `>= 1.5`, AWS provider `5.x`, and the default `provider "aws"` (region from `var.aws_region`). |
| `variables.tf` | Input variables: `aws_region`, `name_prefix`, `cloudfront_price_class`, `tags`. |
| `s3.tf` | S3 bucket (`bucket_prefix`), public access block, ownership controls, SSE-S3 encryption, and bucket policy allowing CloudFront OAC read access only. |
| `cloudfront.tf` | Origin Access Control, CloudFront distribution (S3 regional origin, caching / origin-request managed policies, HTTPS). |
| `outputs.tf` | Bucket id/ARN, distribution id, CloudFront domain name, and base `https://` URL for assets. |
| `.gitignore` | Ignores `.terraform/`, state files, `*.tfvars`, and overrides; **does not** ignore `terraform.lock.hcl` (commit the lock file). |
| `terraform.tfvars.example` | Example optional overrides; copy to `terraform.tfvars` (gitignored) to customize. |
