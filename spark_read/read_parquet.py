import os
import findspark
findspark.init()
from pyspark.sql import SparkSession
from dotenv import load_dotenv

os.makedirs(name="/tmp/spark_events", exist_ok=True)

load_dotenv()
ACCESS_KEY = os.getenv("AWS_ACCESS_KEY_ID")
SECRET_KEY = os.getenv("AWS_SECRET_ACCESS_KEY")
REGION = os.getenv("AWS_DEFAULT_REGION")
ROLE = os.getenv("AWS_ASSUME_ROLE")

spark = SparkSession.builder\
    .master('local')\
    .appName('test')\
    .config('spark.eventLog.dir', '/tmp/spark_events')\
    .config('spark.jars.packages', 'org.apache.hadoop:hadoop-aws:3.2.0')\
    .config ('spark.sql.execution.arrow.pyspark.enabled', 'true')\
    .config('spark.hadoop.fs.s3a.aws.credentials.provider', 'org.apache.hadoop.fs.s3a.auth.AssumedRoleCredentialProvider')\
    .config('spark.hadoop.fs.s3a.assumed.role.arn' ,ROLE)\
    .config('spark.hadoop.fs.s3a.access.key', ACCESS_KEY)\
    .config('spark.hadoop.fs.s3a.secret.key', SECRET_KEY)\
    .config('spark.hadoop.fs.s3a.impl', 'org.apache.hadoop.fs.s3a.S3AFileSystem')\
    .getOrCreate()

spark.sparkContext.setLogLevel("ERROR")
spark.sparkContext.setSystemProperty("aws.region", REGION)

location = "s3a://firehose-ingest-bucket/data"
raw_frame = spark.read.parquet(location).filter("date = '2022-6-22'")
names = raw_frame.select("body.newData.Patient.name")
names.show()