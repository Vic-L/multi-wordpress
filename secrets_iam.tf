# with reference to https://stackoverflow.com/a/52868251/2667545

resource "aws_iam_policy" "secrets_bucket" {
  name = "${var.secrets_bucket_name}-secrets_bucket_iam_policy"
  description = "Allow reading from the S3 bucket"

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Action":[
        "s3:GetObject"
      ],
      "Resource":[
        "${module.secrets_bucket.arn}",
        "${module.secrets_bucket.arn}/*"
      ]
    },
    {
      "Effect":"Allow",
      "Action":[
        "s3:ListAllMyBuckets"
      ],
      "Resource":"*"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "secrets_bucket" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "secrets_bucket" {
  name = "${var.secrets_bucket_name}-iam_role"
  assume_role_policy = data.aws_iam_policy_document.secrets_bucket.json
}

resource "aws_iam_role_policy_attachment" "secrets_bucket" {
  role = aws_iam_role.secrets_bucket.name
  policy_arn = aws_iam_policy.secrets_bucket.arn
}

resource "aws_iam_instance_profile" "secrets_bucket" {
  name = "${var.secrets_bucket_name}-iam_instance_profile"
  role = aws_iam_role.secrets_bucket.name
}