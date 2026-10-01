output "bucket_name" {
  value = aws_s3_bucket.rag_documents.id
}

output "bucket_arn" {
  value = aws_s3_bucket.rag_documents.arn
}
