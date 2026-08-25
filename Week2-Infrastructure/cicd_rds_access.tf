# The RDS security group (in security_groups.tf) only allows inbound Postgres
# traffic from the ASG's app security group. The dedicated CI/CD instance has
# a different security group, so it needs its own explicit allow rule.
resource "aws_security_group_rule" "rds_from_cicd" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.cicd_instance.id
  description               = "Postgres from the dedicated CI/CD instance"
}
