#
# resource "aws_iam_user" "user" {
#   name = "${var.username}"
# }
#
# resource "aws_iam_user_policy_attachment" "IAMFullAccess" {
#   user       = "${aws_iam_user.user.name}"
#   policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
# }
#
# resource "aws_iam_user_policy_attachment" "CloudWatchLogsFullAccess" {
#   user       = "${aws_iam_user.user.name}"
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
# }
#
# resource "aws_iam_user_policy_attachment" "AmazonEC2ContainerServiceFullAccess" {
#   user       = "${aws_iam_user.user.name}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerServiceFullAccess"
# }
#
# resource "aws_iam_user_policy_attachment" "AmazonEC2ContainerRegistryPowerUser" {
#   user       = "${aws_iam_user.user.name}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
# }
#
# resource "aws_iam_user_policy_attachment" "AmazonEC2ContainerRegistryFullAccess" {
#   user       = "${aws_iam_user.user.name}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
# }
#
# resource "aws_iam_user_policy_attachment" "AmazonVPCFullAccess" {
#   user       = "${aws_iam_user.user.name}"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
# }

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
}
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "xrayWriteOnlyAccess_policy" {
  role       = "${aws_iam_role.ecs_task_execution_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}
