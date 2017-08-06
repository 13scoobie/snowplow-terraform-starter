// Create S3 bucket
resource "aws_s3_bucket" "SnowplowSink" {
  bucket = "snowplow-s3-sink"
  acl    = "private"

  tags {
    Name        = "snowplow-s3-sink"
    Environment = "production"
    SnowplowProccess = "sink"
  }
}

// Create a security Group
resource "aws_security_group" "S3Sink" {
  name = "snowplow-sink-s3-sg"

  tags {
    Name = "snowplow-sink-s3-sg"
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
resource "aws_instance" "S3Sink" {
  ami = "ami-14b5a16d"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.S3Sink.name}"]
  iam_instance_profile = "${aws_iam_instance_profile.S3Sink.name}"

  tags {
    Name = "snowplow-sink-s3"
  }

  root_block_device {
    volume_type = "standard"
    volume_size = 100
    delete_on_termination = 1
  }

  provisioner "file" {
    source      = "./sink_s3"
    destination = "~/sink_s3"

    connection {
      user = "ec2-user"
      private_key = "${file(var.key_path)}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y lzop liblzo2-dev",
      "cd ~/sink_s3",
      "cp config.hocon.sample config.hocon",
      "sed -i -e 's/{{sinkStreamRegion}}/${var.aws_region}/g' config.hocon",
      "sed -i -e 's/{{sinkStreamAppName}}/${aws_dynamodb_table.S3SinkApp.name}/g' config.hocon",
      "sed -i -e 's/{{sinkStreamIn}}/${aws_kinesis_stream.EnrichGood.name}/g' config.hocon",
      "sed -i -e 's/{{sinkStreamBad}}/${aws_kinesis_stream.S3SinkBad.name}/g' config.hocon",
      "sed -i -e 's/{{sinkS3BucketName}}/${var.s3_sink_bucket_name}/g' config.hocon",
      "sed -i -e 's/{{sinkStreamInByteLimit}}/${var.s3_sink_byte_thresh}/g' config.hocon",
      "sed -i -e 's/{{sinkStreamInRecordLimit}}/${var.s3_sink_record_thresh}/g' config.hocon",
      "sed -i -e 's/{{sinkStreamInTimeLimit}}/${var.s3_sink_time_thresh}/g' config.hocon",
      "wget https://dl.bintray.com/snowplow/snowplow-generic/kinesis_s3_${var.s3_sink_version}.zip",
      "unzip kinesis_s3_${var.s3_sink_version}.zip",
      "chmod +x snowplow-kinesis-s3-${var.s3_sink_version}",
      "sudo nohup ./snowplow-kinesis-s3-${var.s3_sink_version} --config config.hocon &",
      "sleep 2"
    ]

    connection {
      user = "ec2-user"
      private_key = "${file(var.key_path)}"
    }
  }
}
