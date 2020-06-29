resource "aws_iam_instance_profile" "Collector" {
  name = "snowplow-collector-profile"
  role = "${aws_iam_role.Collector.name}"
}

resource "aws_iam_instance_profile" "Enrich" {
  name = "snowplow-enrich-profile"
  role = "${aws_iam_role.Enrich.name}"
}

resource "aws_iam_instance_profile" "S3Sink" {
  name = "snowplow-sink-s3-profile"
  role = "${aws_iam_role.S3Sink.name}"
}

resource "aws_iam_role" "Collector" {
  name = "snowplow-collector"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "CollectorPolicy" {
  name = "snowplow-collector-policy"
  role = "${aws_iam_role.Collector.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.CollectorGood.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.CollectorBad.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "Enrich" {
  name = "snowplow-enrich"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "EnrichPolicy" {
  name = "snowplow-enrich-policy"
  role = "${aws_iam_role.Enrich.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": [
                "${aws_kinesis_stream.CollectorGood.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.EnrichGood.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.EnrichBad.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "S3Sink" {
  name = "snowplow-sink-s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "S3Sink" {
  name = "snowplow-sink-s3-policy"
  role = "${aws_iam_role.S3Sink.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:GetShardIterator",
                "kinesis:GetRecords",
                "kinesis:ListShards"
            ],
            "Resource": [
                "${aws_kinesis_stream.EnrichGood.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:PutRecord",
                "kinesis:PutRecords"
            ],
            "Resource": [
                "${aws_kinesis_stream.S3SinkBad.arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
                "${aws_s3_bucket.SnowplowSink.arn}"
            ]
        }
    ]
}
EOF
}
