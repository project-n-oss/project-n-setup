resource "random_id" "random_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "admin" {
  name               = "project-n-admin-${random_id.random_suffix.hex}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
    "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "admin" {
  name = aws_iam_role.admin.name
  role = aws_iam_role.admin.name
}

resource "aws_iam_policy" "deploy" {
  name   = "project-n-admin-deploy-${random_id.random_suffix.hex}"
  policy = data.aws_iam_policy_document.deploy.json
}

resource "aws_iam_policy" "vpc" {
  count = var.manage_vpc ? 1 : 0

  name   = "project-n-admin-vpc-permissions-${random_id.random_suffix.hex}"
  policy = data.aws_iam_policy_document.vpc.json
}

resource "aws_iam_role_policy_attachment" "admin-deploy" {
  policy_arn = aws_iam_policy.deploy.arn
  role       = aws_iam_role.admin.id
}

resource "aws_iam_role_policy_attachment" "admin-vpc" {
  count = var.manage_vpc ? 1 : 0

  policy_arn = aws_iam_policy.vpc[0].arn
  role       = aws_iam_role.admin.name
}

data "aws_iam_policy_document" "deploy" {
  statement {
    sid    = "UnrestrictedResourcePermissions"
    effect = "Allow"
    actions = [
      "acm:DescribeCertificate",
      "acm:ListTagsForCertificate",
      "acm:RequestCertificate",
      "autoscaling:Describe*",
      "ec2:AssociateIamInstanceProfile",
      "ec2:CreateLaunchTemplate",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:DeleteTags",
      "ec2:Describe*",
      "ec2:GetLaunchTemplateData",
      "ec2:RunInstances",
      "eks:CreateCluster",
      "eks:ListClusters"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "IAM"
    effect = "Allow"
    actions = [
      "iam:AddClientIDToOpenIDConnectProvider",
      "iam:AddRoleToInstanceProfile",
      "iam:AttachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeleteInstanceProfile",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetInstanceProfile",
      "iam:GetOpenIDConnectProvider",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListInstanceProfiles",
      "iam:ListInstanceProfilesForRole",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PassRole",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagRole",
      "iam:TagOpenIDConnectProvider",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::*:instance-profile/project-n-*",
      "arn:aws:iam::*:policy/project-n-*",
      "arn:aws:iam::*:role/project-n-*",
      "arn:aws:iam::*:oidc-provider/oidc.eks.*.amazonaws.com",
      "arn:aws:iam::*:oidc-provider/oidc.eks.*.amazonaws.com/id/*",
      "arn:aws:iam::*:role/aws-service-role/eks.amazonaws.com/AWSServiceRoleForAmazonEKS",
      "arn:aws:iam::*:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling",
      "arn:aws:iam::*:role/aws-service-role/elasticloadbalancing.amazonaws.com/AWSServiceRoleForElasticLoadBalancing"
    ]
  }

  statement {
    sid    = "Autoscaling"
    effect = "Allow"
    actions = [
      "autoscaling:AttachInstances",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:SuspendProcesses",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = [
      "arn:aws:autoscaling:*:*:autoScalingGroup:*:autoScalingGroupName/project-n-*"
    ]
  }

  statement {
    sid    = "S3"
    effect = "Allow"
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::n-*",
      "arn:aws:s3:::project-n-*"
    ]
  }

  statement {
    sid    = "EKS"
    effect = "Allow"
    actions = [
      "eks:DescribeUpdate",
      "eks:DescribeCluster",
      "eks:UpdateClusterConfig",
      "eks:UpdateClusterVersion"
    ]
    resources = [
      "arn:aws:eks:*:*:cluster/project-n-*"
    ]
  }

  statement {
    sid    = "SQS"
    effect = "Allow"
    actions = [
      "sqs:AddPermission",
      "sqs:CreateQueue",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ListQueues",
      "sqs:ListQueueTags",
      "sqs:SetQueueAttributes",
      "sqs:TagQueue"
    ]
    resources = [
      "arn:aws:sqs:*:*:project-n-*"
    ]
  }

  statement {
    sid     = "logs"
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:DeleteLogGroup",
      "logs:ListTagsLogGroup",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/eks/project-n*",
      "arn:aws:logs:*:*:log-group::log-stream*"
    ]
  }
}

data "aws_iam_policy_document" "vpc" {
  statement {
    sid    = "EC2InternetGateway"
    effect = "Allow"
    actions = [
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DetachInternetGateway",
      "ec2:DeleteInternetGateway"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2NetworkInterface"
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:AttachNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:DeleteNetworkInterface"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2Route"
    effect = "Allow"
    actions = [
      "ec2:CreateRoute",
      "ec2:DeleteRoute"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2RouteTable"
    effect = "Allow"
    actions = [
      "ec2:CreateRouteTable",
      "ec2:DeleteRouteTable",
      "ec2:AssociateRouteTable",
      "ec2:DisassociateRouteTable"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2Subnet"
    effect = "Allow"
    actions = [
      "ec2:CreateSubnet",
      "ec2:AssociateSubnetCidrBlock",
      "ec2:DisassociateSubnetCidrBlock",
      "ec2:ModifySubnetAttribute",
      "ec2:DeleteSubnet",
      "ec2:DescribeSubnets" # todo check if this fixed the ingress error
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2Vpc"
    effect = "Allow"
    actions = [
      "ec2:CreateVpc",
      "ec2:AssociateVpcCidrBlock",
      "ec2:DisassociateVpcCidrBlock",
      "ec2:ModifyVpcAttribute",
      "ec2:DeleteVpc"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EC2SecurityGroups"
    effect = "Allow"
    actions = [
      "ec2:CreateSecurityGroup",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup"
    ]
    resources = ["*"]
  }
}
