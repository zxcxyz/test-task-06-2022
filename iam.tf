#ec2-scoped ploicies
resource "aws_iam_role" "cluster_instance_role" {
  description        = "cluster-instance-role-${var.project}}"
  assume_role_policy = file("${path.module}/assets/policies/cluster-instance-role.json")
}

resource "aws_iam_policy" "cluster_instance_policy" {
  description = "cluster-instance-policy-${var.project}"
  policy      = file("${path.module}/assets/policies/cluster-instance-policy.json")
}

resource "aws_iam_policy_attachment" "cluster_instance_policy_attachment" {
  name       = "cluster-instance-policy-attachment-${var.project}"
  roles      = [aws_iam_role.cluster_instance_role.id]
  policy_arn = aws_iam_policy.cluster_instance_policy.arn
}

resource "aws_iam_instance_profile" "cluster" {
  name = "cluster-instance-profile-${var.project}"
  path = "/"
  role = aws_iam_role.cluster_instance_role.name
}