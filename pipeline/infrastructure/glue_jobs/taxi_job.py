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

s3_path = "s3://da7-qxz50zr/taxi/"

# Read JSON file into a DataFrame
df = spark.read.json(s3_path)

converted_df = df.select(
    col("Airport_fee").cast("decimal(6,2)").alias("airport_fee"),
    col("DOLocationID").cast("string").alias("do_location_id"),
    col("PULocationID").cast("string").alias("pu_location_id"),
    col("RatecodeID").cast("string").alias("rate_code_id"),
    col("VendorID").cast("string").alias("vendor_id"),
    col("congestion_surcharge").cast("decimal(6,2)").alias("congestion_surcharge"),
    col("extra").cast("decimal(6,2)").alias("extra"),
    col("fare_amount").cast("decimal(6,2)").alias("fare_amount"),
    col("improvement_surcharge").cast("decimal(6,2)").alias("improvement_surcharge"),
    col("mta_tax").cast("decimal(6,2)").alias("mta_tax"),
    col("passenger_count").cast("int").alias("passenger_count"),
    col("payment_type").cast("int").alias("payment_type"),
    col("store_and_fwd_flag").cast("string").alias("store_and_fwd_flag"),
    col("tip_amount").cast("decimal(6,2)").alias("tip_amount"),
    col("tolls_amount").cast("decimal(6,2)").alias("tolls_amount"),
    col("total_amount").cast("decimal(6,2)").alias("total_amount"),
    col("tpep_dropoff_datetime").cast("timestamp").alias("tpep_dropoff_datetime"),
    col("tpep_pickup_datetime").cast("timestamp").alias("tpep_pickup_datetime"),
    col("trip_distance").cast("float").alias("trip_distance")
)


# Compute the optimal number of repartitions
num_output_partitions = int(sc._conf.get('spark.executor.instances')) * int(sc._conf.get('spark.executor.cores'))
repartitioned_df = converted_df.repartition(num_output_partitions)

# Write the repartitioned DataFrame to S3 as Parquet format
repartitioned_df.write.mode("overwrite").parquet("s3://da7-qxz50zr-prepared-bucket/taxi/")