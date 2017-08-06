resource "aws_dynamodb_table" "EnrichInRead" {
  name           = "${var.enrich_app_name}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags {
    Name        = "${var.enrich_app_name}"
    Environment = "production"
    SnowplowProccess = "enrich"
  }
}

resource "aws_kinesis_stream" "CollectorGood" {
  name             = "${var.collector_kinesis_sink_good}"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Environment = "production"
    SnowplowProccess = "collector"
  }
}

resource "aws_kinesis_stream" "CollectorBad" {
  name             = "${var.collector_kinesis_sink_bad}"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Environment = "production"
    SnowplowProccess = "collector"
  }
}

resource "aws_kinesis_stream" "EnrichGood" {
  name             = "${var.enrich_stream_out_good}"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Environment = "production"
    SnowplowProccess = "enrich"
  }
}

resource "aws_kinesis_stream" "EnrichBad" {
  name             = "${var.enrich_stream_out_bad}"
  shard_count      = 1
  retention_period = 48

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  tags {
    Environment = "production"
    SnowplowProccess = "enrich"
  }
}
