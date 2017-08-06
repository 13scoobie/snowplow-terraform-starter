resource "aws_redshift_cluster" "SnowplowSink" {
  cluster_identifier = "snowplow-analytics"
  database_name      = "test"
  master_username    = "${var.redshift_username}"
  master_password    = "${var.redshift_password}"
  node_type          = "dc1.large"
  cluster_type       = "single-node"
  publicly_accessible = false

  tags {
    SnowplowProccess = "sink"
  }
}

resource "aws_s3_bucket" "SnowplowSink" {
  bucket = "snowplow-firehose-sink"
  acl    = "private"

  tags {
    Name        = "snowplow-firehose-sink"
    Environment = "production"
    SnowplowProccess = "sink"
  }
}


resource "aws_kinesis_firehose_delivery_stream" "SnowplowSink" {
  name        = "snowplow-sink"
  destination = "redshift"
  depends_on = ["aws_redshift_cluster.SnowplowSink"]

  s3_configuration {
    role_arn           = "${aws_iam_role.SinkFirehose.arn}"
    bucket_arn         = "${aws_s3_bucket.SnowplowSink.arn}"
    buffer_size        = 10
    buffer_interval    = 400
    compression_format = "GZIP"
  }

  redshift_configuration {
    role_arn           = "${aws_iam_role.SinkFirehose.arn}"
    cluster_jdbcurl    = "jdbc:redshift://${aws_redshift_cluster.SnowplowSink.endpoint}/${aws_redshift_cluster.SnowplowSink.database_name}"
    username           = "${var.redshift_username}"
    password           = "${var.redshift_password}"
    data_table_name    = "${var.redshift_table}"
    copy_options       = "delimiter '|'" # the default delimiter
    data_table_columns = "test-col"
  }
}
