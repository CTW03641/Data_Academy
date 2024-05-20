

/* GLUE JOB TO PREPARE taxi Data*/
resource "aws_glue_job" "TRF_glue_job_taxi" {
  name     = "${local.prefix}_glue_job_taxi"
  role_arn = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.TRF_storage_bucket.bucket}/glue-jobs/taxi_job.py"
    python_version  = "3"
  }

  number_of_workers = 5 # Adjust the number of workers as needed

  depends_on = [aws_s3_object.taxi_job_script]

}


/* S3 bucket to save glue job to transform taxi data*/
resource "aws_s3_object" "citibike_stream_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/citibike_stream_job.py"
  source = "${path.module}/glue_jobs/citibike_stream_job.py"
  etag   = filemd5("${path.module}/glue_jobs/citibike_stream_job.py")
}


/* GLUE JOB TO PREPARE citibike_stream Data*/
resource "aws_glue_job" "TRF_glue_job_citibike_stream" {
  name     = "${local.prefix}_glue_job_citibike_stream"
  role_arn = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.citibike_stream_job_script.bucket}/glue-jobs/citibike_stream_job.py"
    python_version  = "3"
  }
}






/* S3 bucket to save glue job to Load taxi and citibike data to RDS*/
resource "aws_s3_object" "citibike_load_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/citibike_load.py"
  source = "${path.module}/glue_jobs/citibike_load.py"
  etag   = filemd5("${path.module}/glue_jobs/citibike_load.py")
}

resource "aws_s3_object" "taxi_load_job_script" {
  bucket = aws_s3_bucket.TRF_storage_bucket.bucket
  acl    = "private"
  key    = "glue-jobs/taxi_load.py"
  source = "${path.module}/glue_jobs/taxi_load.py"
  etag   = filemd5("${path.module}/glue_jobs/taxi_load.py")
}


# Create glue jobs to Load taxi and citibike data to RDS*/
resource "aws_glue_job" "TRF_glue_job_citibike_load" {
  name     = "${local.prefix}_glue_job_citibike_load"
  role_arn = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.citibike_load_job_script.bucket}/glue-jobs/citibike_load.py"
    python_version  = "3"
  }

  max_capacity = 2.0 # Allocates 2 DPUs to this job

  connections = [
    "data-academy-7_postgres_connection_intranet_0", "data-academy-7_postgres_connection_intranet_1"
  ]
}


resource "aws_glue_job" "TRF_glue_job_taxi_load" {
  name     = "${local.prefix}_glue_job_taxi_load"
  role_arn = aws_iam_role.glue_role.arn
  execution_property {
    max_concurrent_runs = 1
  }

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_object.taxi_load_job_script.bucket}/glue-jobs/taxi_load.py"
    python_version  = "3"
  }

  max_capacity = 2.0 # Allocates 2 DPUs to this job

  connections = [
    "data-academy-7_postgres_connection_intranet_0", "data-academy-7_postgres_connection_intranet_1"
  ]

}

