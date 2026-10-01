resource "aws_backup_vault" "main" {
  name = "${var.project_name}-vault"

  tags = {
    Name = "${var.project_name}-vault"
  }
}

resource "aws_backup_plan" "main" {
  name = "${var.project_name}-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)"  # Todos los dias a las 5am UTC

    lifecycle {
      delete_after = var.retention_days
    }
  }

  tags = {
    Name = "${var.project_name}-backup-plan"
  }
}

# Trust policy: AWS Backup necesita asumir un role para poder tomar snapshots en tu nombre
data "aws_iam_policy_document" "backup_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "backup_role" {
  name               = "${var.project_name}-backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_assume_role.json

  tags = {
    Name = "${var.project_name}-backup-role"
  }
}

resource "aws_iam_role_policy_attachment" "backup_policy" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

# Selection: que recurso especifico aplica a este plan
resource "aws_backup_selection" "main" {
  name         = "${var.project_name}-selection"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup_role.arn

  resources = [
    var.instance_arn,
  ]
}
