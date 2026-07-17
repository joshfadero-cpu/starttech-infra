# Allow only this CloudFront distribution to read the frontend bucket
data "aws_iam_policy_document" "frontend_bucket" {
  statement {
    sid       = "AllowCloudFrontOACRead"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.starttech.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.frontend_bucket.json
}
