output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnet_id" {
  value = module.network.public_subnet_id
}

output "private_subnet_id" {
  value = module.network.private_subnet_id
}

output "instance_profile_name" {
  value = module.iam.instance_profile_name
}

output "instance_id" {
  value = module.compute.instance_id
}

output "bucket_name" {
  value = module.storage.bucket_name
}

output "vault_name" {
  value = module.backup.vault_name
}
