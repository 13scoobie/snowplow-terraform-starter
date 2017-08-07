// Create a security Group
resource "aws_security_group" "Collector" {
  name = "snowplow-collector-sg"

  tags {
    Name = "snowplow-collector-sg"
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "TCP"
    security_groups = ["${aws_security_group.CollectorELB.id}"]
  }

  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "TCP"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Create a new instance
resource "aws_instance" "Collector" {
  ami = "ami-14b5a16d"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.Collector.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.Collector.name}"

  tags {
    Name = "snowplow-collector"
  }

  root_block_device {
    volume_type = "standard"
    volume_size = 100
    delete_on_termination = 1
  }

  provisioner "file" {
    source      = "./collector"
    destination = "~/collector"

    connection {
      user = "ec2-user"
      private_key = "${file(var.key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "cd ~/collector",
      "cp config.hocon.sample config.hocon",
      "sed -i -e 's/{{collectorPort}}/${var.collector_port}/g' config.hocon",
      "sed -i -e 's/{{collectorCookieExpiration}}/${var.collector_cookie_expiration}/g' config.hocon",
      "sed -i -e 's/{{collectorCookieName}}/${var.collector_cookie_name}/g' config.hocon",
      "sed -i -e 's/{{collectorCookieDomain}}/${var.my_domain}/g' config.hocon",
      "sed -i -e 's/{{collectorSinkKinesisStreamRegion}}/${var.aws_region}/g' config.hocon",
      "sed -i -e 's/{{collectorKinesisStreamGoodName}}/${aws_kinesis_stream.CollectorGood.name}/g' config.hocon",
      "sed -i -e 's/{{collectorKinesisStreamBadName}}/${aws_kinesis_stream.CollectorBad.name}/g' config.hocon",
      "sed -i -e 's/{{collectorSinkKinesisMinBackoffMillis}}/${var.collector_kinesis_min_backoff}/g' config.hocon",
      "sed -i -e 's/{{collectorSinkKinesisMaxBackoffMillis}}/${var.collector_kinesis_max_backoff}/g' config.hocon",
      "sed -i -e 's/{{collectorSinkBufferByteThreshold}}/${var.collector_sink_byte_thresh}/g' config.hocon",
      "sed -i -e 's/{{collectorSinkBufferRecordThreshold}}/${var.collector_sink_record_thresh}/g' config.hocon",
      "sed -i -e 's/{{collectorSinkBufferTimeThreshold}}/${var.collector_sink_time_thresh}/g' config.hocon",
      "wget https://dl.bintray.com/snowplow/snowplow-generic/snowplow_scala_stream_collector_${var.collector_version}.zip",
      "unzip snowplow_scala_stream_collector_${var.collector_version}.zip",
      "chmod +x snowplow-stream-collector-${var.collector_version}",
      "sudo nohup ./snowplow-stream-collector-${var.collector_version} --config config.hocon &",
      "sleep 5"
    ]

    connection {
      user = "ec2-user"
      private_key = "${file(var.key_path)}"
    }
  }
}
