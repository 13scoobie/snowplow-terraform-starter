# Create ELB Security Group
resource "aws_security_group" "CollectorELB" {
  name = "snowplow-collector-elb-sg"

  tags {
    Name = "snowplow-collector-elb-sg"
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create ELB
resource "aws_elb" "Collector" {
  name               = "snowplow-collector-elb"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  security_groups = ["${aws_security_group.CollectorELB.id}"]

  tags {
    Name = "snowplow-collector-elb"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  instances                   = ["${aws_instance.Collector.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 300
  connection_draining         = true
  connection_draining_timeout = 300
}
