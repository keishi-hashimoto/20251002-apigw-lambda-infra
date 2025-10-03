resource "aws_s3_bucket" "ssh" {
  bucket = var.ssh_bucket_name
}

resource "aws_s3_bucket_public_access_block" "ssh" {
  bucket                  = aws_s3_bucket.ssh.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "ssh" {
  bucket = aws_s3_bucket.ssh.id

  index_document {
    suffix = var.index_document
  }
  error_document {
    key = var.error_page
  }
}


data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.ssh.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "ssh" {
  bucket = aws_s3_bucket.ssh.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}