# Trust policy: define QUIEN puede asumir este role
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_agent_role" {
  name               = "${var.project_name}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# Permite que la EC2 sea administrada via SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ec2_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Instance profile: el "contenedor" que conecta el Role con la EC2 real
resource "aws_iam_instance_profile" "ec2_agent_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_agent_role.name
}

# Policy acotada para el operador humano (vos) - reemplaza AdministratorAccess
data "aws_iam_policy_document" "operator_policy" {
  statement {
    sid    = "NetworkingAccess"
    effect = "Allow"
    actions = [
      "ec2:*Vpc*",
      "ec2:*Subnet*",
      "ec2:*RouteTable*",
      "ec2:*InternetGateway*",
      "ec2:*NatGateway*",
      "ec2:*Address*",
      "ec2:Describe*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ComputeAccess"
    effect = "Allow"
    actions = [
      "ec2:*Instance*",
      "ec2:*SecurityGroup*",
      "ec2:*Volume*",
      "ec2:*Snapshot*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IamForThisProject"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:PassRole",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:TagRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
    ]
    resources = [
      "arn:aws:iam::*:role/${var.project_name}-*",
      "arn:aws:iam::*:instance-profile/${var.project_name}-*",
    ]
  }

  statement {
    sid    = "StorageAccess"
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${var.project_name}-*",
      "arn:aws:s3:::${var.project_name}-*/*",
    ]
  }

  statement {
    sid    = "MonitoringAccess"
    effect = "Allow"
    actions = [
      "cloudwatch:*",
      "logs:*",
      "budgets:*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "BackupAccess"
    effect = "Allow"
    actions = [
      "backup:*",
      "ec2:*Snapshot*",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "MonitoringSnsAccess"
    effect = "Allow"
    actions = [
      "sns:GetTopicAttributes",
      "sns:GetSubscriptionAttributes",
      "sns:ListTagsForResource",
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:ListSubscriptionsByTopic",
      "sns:SetTopicAttributes",
      "sns:TagResource",
    ]
    resources = [
      "arn:aws:sns:*:*:${var.project_name}-*",
    ]
  }

  statement {
    sid    = "ReadOwnOperatorPolicy"
    effect = "Allow"
    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
    ]
    resources = [
      "arn:aws:iam::*:policy/${var.project_name}-*",
    ]
  }
}

resource "aws_iam_policy" "operator_policy" {
  name        = "${var.project_name}-operator-policy"
  description = "Permisos acotados para operar el proyecto ai-agent-sandbox"
  policy      = data.aws_iam_policy_document.operator_policy.json
}
