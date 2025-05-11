resource "aws_glue_catalog_database" "log_db" {
  name = "structured_log_db"
}
resource "aws_glue_catalog_table" "log_table" {
  name          = "structured_logs"
  database_name = aws_glue_catalog_database.log_db.name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "classification"                     = "json"
    "projection.enabled"                 = "true"
    "projection.orderdate.format"        = "yyyy/MM/dd"
    "projection.orderdate.type"          = "date"
    "projection.orderdate.interval"      = "1"
    "projection.orderdate.interval.unit" = "DAYS"
    "projection.orderdate.range"         = "2025/01/01,NOW"
    "storage.location.template"          = "s3://${aws_s3_bucket.log_bucket.bucket}/logs/$${orderdate}"
    "skip.header.line.count"             = "0"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.log_bucket.bucket}/logs/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.IgnoreKeyTextOutputFormat"
    ser_de_info {
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
    }

    columns {
      name = "timestamp"
      type = "string"
    }

    columns {
      name = "level"
      type = "string"
    }

    columns {
      name = "msg"
      type = "string"
    }
  }

  partition_keys {
    name = "orderdate"
    type = "string"
  }
}
