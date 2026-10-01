# Sufijo random para garantizar nombre de bucket unico globalmente
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "rag_documents" {
  bucket = "${var.project_name}-rag-docs-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${var.project_name}-rag-docs"
  }
}

# Bloquea TODO acceso publico, sin excepciones
resource "aws_s3_bucket_public_access_block" "rag_documents" {
  bucket = aws_s3_bucket.rag_documents.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encripcion en reposo por default
resource "aws_s3_bucket_server_side_encryption_configuration" "rag_documents" {
  bucket = aws_s3_bucket.rag_documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versionado - protege contra sobre-escrituras o borrados accidentales
resource "aws_s3_bucket_versioning" "rag_documents" {
  bucket = aws_s3_bucket.rag_documents.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket policy: solo el Role de la EC2 puede leer/escribir, y solo via HTTPS
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowEC2RoleAccess"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.ec2_role_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.rag_documents.arn,
      "${aws_s3_bucket.rag_documents.arn}/*",
    ]
  }

  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.rag_documents.arn,
      "${aws_s3_bucket.rag_documents.arn}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "rag_documents" {
  bucket = aws_s3_bucket.rag_documents.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.rag_documents]
}
