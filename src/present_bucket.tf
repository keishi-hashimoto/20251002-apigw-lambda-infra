resource "aws_s3_bucket" "present" {
  bucket = var.present_bucket
}

resource "aws_s3_object" "present" {
  bucket = aws_s3_bucket.present.bucket
  key    = var.present_bucket

  source = "./present.html"
}

resource "aws_s3_bucket_public_access_block" "present" {
  bucket                  = aws_s3_bucket.present.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}