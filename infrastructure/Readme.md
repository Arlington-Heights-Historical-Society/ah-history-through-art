# Infrastructure

For the History Through Art Jekyll site (hosted on **GitHub Pages**).

## AWS setup
One time setup commands:
```
# configure the cdn-developer IAM user locally (this assumes it exists in AWS)
aws sts get-caller-identity --profile cdn-developer

# Enter the access key, secret, and default region (e.g. us-east-2 to match variables.tf)
aws sts get-caller-identity --profile cdn-developer
```
New shell setup
```
export AWS_PROFILE=cdn-developer
```

## Image hosting

- **S3:** Private bucket (Block Public Access); objects are **not** served directly from S3 URLs.
    - S3 bucket policy will also be created by terraform
- **CloudFront:** Distribution in front of S3 with **Origin Access Control (OAC)**; browsers and the site use the **CloudFront hostname** (custom domain optional).
- **Responsive images:** No edge resizing. From each original, generate a few widths (e.g. 480 / 960 / 1440) plus **WebP/AVIF** (or as needed) **locally via CLI**, sync to S3. Jekyll uses **`srcset` / `sizes` or `<picture>`** so mobile loads smaller files.
- **Uploads:** Single operator; **`aws s3 sync`** (or `cp`) after generation. Delete with **`aws s3 rm`**; invalidate CloudFront only if you reuse the same URL.

**IaC:** **Terraform** in this directory provisions the bucket, OAC, distribution, and bucket policy.


### Terraform usage

From this directory (AWS credentials configured, e.g. `AWS_PROFILE`):

#### Infra Setup
```bash
terraform init
terraform plan
terraform apply
```
Currently that creates:
```
Changes to Outputs:
  + cloudfront_distribution_id = (known after apply)
  + cloudfront_domain_name     = (known after apply)
  + cloudfront_url             = (known after apply)
  + s3_bucket_arn              = (known after apply)
  + s3_bucket_id               = (known after apply)
```

After apply, use **`terraform output`** for the S3 bucket name and CloudFront URL. Upload with `aws s3 sync` / `cp` using an IAM principal that has **`s3:PutObject`**, **`s3:DeleteObject`**, and **`s3:ListBucket`** on that bucket (and **`cloudfront:CreateInvalidation`** on the distribution if you invalidate after overwrites).

State is local by default; add a **remote backend** (e.g. S3 + DynamoDB) when you want team/shared applies.

**IAM:** `terraform apply` still needs permission to create/update **S3** and **CloudFront** resources (distribution, OAC, bucket policy). The config uses **documented managed policy IDs** in `cloudfront.tf` so **`terraform plan` does not call** `cloudfront:ListCachePolicies` / `ListOriginRequestPolicies`. If you prefer data-source lookups instead, grant those list/get actions (or broader `cloudfront:*` for admins).

#### tear down
```
terraform destroy
```

### Upload objects
Single file
```
BUCKET=$(terraform output -raw s3_bucket_id)
aws s3 cp ./your-image.webp "s3://$BUCKET/imageshistart/harmony/your-image.webp"

# example
aws s3 cp images/harmonypark/harmony-park-today.webp "s3://$BUCKET/images/histart/harmony/harmony-park-today.webp"
```
Whole folder
```
aws s3 sync ./build/images s3://YOUR_BUCKET_NAME/images --delete
```
Get the URL
```
# get this from the terraform outputs
CLOUDFRONT_DOMAIN=d2fyd5kvehusob.cloudfront.net
```
Add the files to the site:
```
https://CLOUDFRONT_DOMAIN/images/histart/harmony/my-photo-960.webp

# example
https://d2fyd5kvehusob.cloudfront.net/images/histart/harmony/harmony-park-today.webp
```


### Terraform files

| File | Purpose |
|------|--------|
| `versions.tf` | Terraform `>= 1.5`, AWS provider `5.x`, and the default `provider "aws"` (region from `var.aws_region`). |
| `variables.tf` | Input variables: `aws_region`, `name_prefix`, `cloudfront_price_class`, `tags`. |
| `s3.tf` | S3 bucket (`bucket_prefix`), public access block, ownership controls, SSE-S3 encryption, and bucket policy allowing CloudFront OAC read access only. |
| `cloudfront.tf` | Origin Access Control, CloudFront distribution (S3 regional origin, HTTPS). Uses **hard-coded IDs** for AWS managed policies *CachingOptimized* and *CORS-S3Origin* so plan works without `cloudfront:List*Policy` permissions. |
| `outputs.tf` | Bucket id/ARN, distribution id, CloudFront domain name, and base `https://` URL for assets. |
| `.gitignore` | Ignores `.terraform/`, state files, `*.tfvars`, and overrides; **does not** ignore `terraform.lock.hcl` (commit the lock file). |
| `terraform.tfvars.example` | Example optional overrides; copy to `terraform.tfvars` (gitignored) to customize. |
