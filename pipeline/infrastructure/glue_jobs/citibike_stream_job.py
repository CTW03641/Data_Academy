# %idle_timeout 2880
# %glue_version 4.0
# %worker_type G.1X
# %number_of_workers 5

# Import libraries
import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job

from pyspark.sql.functions import col
  
sc = SparkContext.getOrCreate()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)

s3_path = "s3://da7-qxz50zr/citibike_stream_json/"

# Read JSON file into a DataFrame
df = spark.read.json(s3_path)


converted_df = df.select(
    col("end_lat").cast("double").alias("end_lat"),
    col("end_lng").cast("double").alias("end_lng"),
    col("end_station_id").cast("string").alias("end_station_id"),
    col("end_station_name"),
    col("ended_at"),
    col("member_casual"),
    col("ride_id"),
    col("rideable_type"),
    col("start_lat").cast("double").alias("start_lat"),
    col("start_lng").cast("double").alias("start_lng"),
    col("start_station_id").alias("start_station_id"),
    col("start_station_name"),
    col("started_at")
)


# Compute the optimal number of repartitions
num_output_partitions = int(sc._conf.get('spark.executor.instances')) * int(sc._conf.get('spark.executor.cores'))
repartitioned_df = converted_df.repartition(num_output_partitions)

# Write the repartitioned DataFrame to S3 as Parquet format
repartitioned_df.write.mode("overwrite").parquet("s3://da7-qxz50zr-prepared-bucket/citibike_stream/")