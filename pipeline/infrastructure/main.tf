/*
Resources' Prefixes:
  ING - Resources used in services of Ingestion Layer
  TRF - Resources used in services of Transformation Layer
  SER - Resources used in services of Serving Layer
  GLB - Resources used across all AWS structure
*/


/* BUCKET FOR STORAGE */

resource "aws_s3_bucket" "GLB_storage_bucket" {
  bucket = "${var.GLB_project_name}-${var.GLB_identifier}"
}



/* BUCKET FOR TRANSFORMATION */
resource "aws_s3_bucket" "TRF_storage_bucket" {
  bucket = "${var.GLB_project_name}-${var.GLB_identifier}-prepared-bucket"
}


/* Use S3 bucket to save script of glue job to transform taxi data*/
resource "aws_s3_object" "taxi_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/taxi_job.py"
  source = "${path.module}/glue_jobs/taxi_job.py"
  etag   = filemd5("${path.module}/glue_jobs/taxi_job.py")
}





















/* CATALOG FOR TRANSFORMATION */
# resource "aws_glue_catalog_database" "TRF_glue_prepared_catalog" {
#   name     = "${local.prefix}_prepared_catalog"
# }


# /* CREATE TABLE IN THAT CATALOG FOR TRANSFORMATION */
# resource "aws_glue_catalog_table" "example_table" {
#   database_name = aws_glue_catalog_database.TRF_glue_prepared_catalog.name
#   name          = "table_citibike"
#   table_type    = "EXTERNAL_TABLE"
#   parameters = {
#     "classification" = "parquet"
#   }

#   storage_descriptor {
#     location      = "s3://da7-qxz50zr-prepared-bucket/citibike_coords_partitioned/"
#     input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
#     output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
#     ser_de_info {
#       name                  = "parquet_serde"
#       serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
#     }

#     columns {
#       name    = "ride_id"
#       type    = "string"
#     }

#     columns {
#       name    = "Start_Coordinate"
#       type    = "string"
#     }

#     columns {
#       name    = "End_Coordinate"
#       type    = "string"
#     }

#   }

#   # Define partition keys for the table
#   partition_keys {
#       name = "Start_Month"
#       type = "int"
#     }
# }
