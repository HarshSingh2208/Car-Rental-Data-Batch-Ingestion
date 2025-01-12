from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.operators.dataproc import DataprocSubmitPySparkJobOperator
from airflow.providers.snowflake.operators.snowflake import SnowflakeOperator
from airflow.operators.python import PythonOperator
from airflow.models.param import Param

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'car_rental_data_pipeline',
    default_args=default_args,
    description='Car Rental Data Pipeline',
    schedule_interval=None,
    start_date=datetime(2024, 8, 2),
    catchup=False,
    tags=['dev'],
    params={
        'execution_date': Param(default='NA', type='string', description='Execution date in yyyymmdd format'),
    }
)

# Python function to get the execution date
def get_execution_date(ds_nodash, **kwargs):
    execution_date = kwargs['params'].get('execution_date', 'NA')
    if execution_date == 'NA':
        execution_date = ds_nodash
    return execution_date

# PythonOperator to call the get_execution_date function
get_execution_date_task = PythonOperator(
    task_id='get_execution_date',
    python_callable=get_execution_date,
    provide_context=True,
    op_kwargs={'ds_nodash': '{{ ds_nodash }}'},
    dag=dag
)

# Task to perform SCD2 merge on customer_dim
merge_customer_dim = SnowflakeOperator(
    task_id='merge_customer_dim',
    snowflake_conn_id='snowflake_conn_v2',
    sql="""
        MERGE INTO customer_dim AS target
        USING (
            SELECT
                $1 AS customer_id,
                $2 AS name,
                $3 AS email,
                $4 AS phone
            FROM @car_rental_data_stage/customers_{{ ti.xcom_pull(task_ids='get_execution_date') }}.csv (FILE_FORMAT => 'csv_format')
        ) AS source
        ON target.customer_id = source.customer_id AND target.is_current = TRUE
        WHEN MATCHED AND (
            target.name != source.name OR
            target.email != source.email OR
            target.phone != source.phone
        ) THEN
            UPDATE SET target.end_date = CURRENT_TIMESTAMP(), target.is_current = FALSE;
    """,
    dag=dag
)

# Task to insert all records from the staging table into the target table
insert_customer_dim = SnowflakeOperator(
    task_id='insert_customer_dim',
    snowflake_conn_id='snowflake_conn_v2',
    sql="""
        INSERT INTO customer_dim (customer_id, name, email, phone, effective_date, end_date, is_current)
        SELECT
            $1 AS customer_id,
            $2 AS name,
            $3 AS email,
            $4 AS phone,
            CURRENT_TIMESTAMP() AS effective_date,
            NULL AS end_date,
            TRUE AS is_current
        FROM @car_rental_data_stage/customers_{{ ti.xcom_pull(task_ids='get_execution_date') }}.csv (FILE_FORMAT => 'csv_format');
    """,
    dag=dag
)

pyspark_job_file_path = 'gs://car_rental_ingestion_project/scripts/car_rental_spark_code.py'

CLUSTER_NAME='**************'
PROJECT_ID='************'
REGION='*************'

submit_pyspark_job = DataprocSubmitPySparkJobOperator(
    task_id='submit_pyspark_job',
    main=pyspark_job_file_path,
    arguments=['--date={{ ti.xcom_pull(task_ids=\'get_execution_date\') }}'],  # Passing date as an argument to the PySpark script
    cluster_name=CLUSTER_NAME,
    region=REGION,
    project_id=PROJECT_ID,
    dag=dag,
    dataproc_jars=['gs://car_rental_ingestion_project/jars/spark-snowflake_2.12-2.15.0-spark_3.4.jar', 'gs://car_rental_ingestion_project/jars/snowflake-jdbc-3.16.0.jar']
)

get_execution_date_task >> merge_customer_dim >> insert_customer_dim >> submit_pyspark_job


### Single merge statement

"""
        MERGE INTO customer_dim AS target
        USING (
            SELECT
                $1 AS customer_id,
                $2 AS name,
                $3 AS email,
                $4 AS phone
            FROM @car_rental_data_stage/customers_{{ ti.xcom_pull(task_ids='get_execution_date') }}.csv (FILE_FORMAT => 'csv_format')
        ) AS source
        ON target.customer_id = source.customer_id AND target.is_current = TRUE
        
        -- Update matched records
        WHEN MATCHED AND (
            target.name != source.name OR
            target.email != source.email OR
            target.phone != source.phone
        ) THEN
            UPDATE SET target.end_date = CURRENT_TIMESTAMP(), target.is_current = FALSE
        
        -- Insert unmatched records
        WHEN NOT MATCHED THEN
            INSERT (customer_id, name, email, phone, effective_date, end_date, is_current)
            VALUES (source.customer_id, source.name, source.email, source.phone, CURRENT_TIMESTAMP(), NULL, TRUE);
    """
