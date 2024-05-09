import sys
from awsglue.transforms import *
from pyspark.context import SparkContext
from awsglue.context import GlueContext
  
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
glueContext = GlueContext(sc)

dyf = glueContext.create_dynamic_frame.from_options(
    "s3",
    {
        "paths": [
            "s3://da7-qxz50zr-prepared-bucket/taxi/"
        ]
    },
    "parquet",
    recurse =  True,
    transformation_ctx = "parquet_data"
)


connection_options = {"url": "jdbc:postgresql://da7-data-warehouse.cre2iy7kuiri.eu-central-1.rds.amazonaws.com:5432/playground", "user": "ctw03641", "password": "50c1a63e193649ffb3988ef308d7d05b","dbtable": "ctw03641_staging.taxi_data"}

glueContext.write_dynamic_frame.from_options(frame = dyf, connection_type = "postgresql", connection_options = connection_options, transformation_ctx = "data_loading")