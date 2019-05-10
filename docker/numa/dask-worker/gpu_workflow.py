#!/usr/bin/env python
import pandas as pd
import cudf
import argparse
import time


import numpy as np
from sklearn.model_selection import train_test_split
import xgboost as xgb
import cudf
from cudf.dataframe import DataFrame
from collections import OrderedDict
import gc
from glob import glob
import os
import pyblazing
import pandas as pd
import time
from dask.distributed import Client
from chronometer import Chronometer

from pyblazing import FileSystemType, SchemaFrom, DriverType

def register_hdfs():
    print('*** Register a HDFS File System ***')
    fs_status = pyblazing.register_file_system(
        authority="myLocalHdfs",
        type=FileSystemType.HDFS,
        root="/",
        params={
            "host": "127.0.0.1",
            "port": 54310,
            "user": "hadoop",
            "driverType": DriverType.LIBHDFS3,
            "kerberosTicket": ""
        }
    )
    print(fs_status)


def deregister_hdfs():
    fs_status = pyblazing.deregister_file_system(authority="myLocalHdfs")
    print(fs_status)

def register_posix():

    print('*** Register a POSIX File System ***')
    fs_status = pyblazing.register_file_system(
        authority="mortgage",
        type=FileSystemType.POSIX,
        root="/"
    )
    print(fs_status)

def deregister_posix():
    fs_status = pyblazing.deregister_file_system(authority="mortgage")
    print(fs_status)

from libgdf_cffi import ffi, libgdf

def get_dtype_values(dtypes):
    values = []
    def gdf_type(type_name):
        dicc = {
            'str': libgdf.GDF_STRING,
            'date': libgdf.GDF_DATE64,
            'date64': libgdf.GDF_DATE64,
            'date32': libgdf.GDF_DATE32,
            'timestamp': libgdf.GDF_TIMESTAMP,
            'category': libgdf.GDF_CATEGORY,
            'float': libgdf.GDF_FLOAT32,
            'double': libgdf.GDF_FLOAT64,
            'float32': libgdf.GDF_FLOAT32,
            'float64': libgdf.GDF_FLOAT64,
            'short': libgdf.GDF_INT16,
            'long': libgdf.GDF_INT64,
            'int': libgdf.GDF_INT32,
            'int32': libgdf.GDF_INT32,
            'int64': libgdf.GDF_INT64,
        }
        if dicc.get(type_name):
            return dicc[type_name]
        return libgdf.GDF_INT64

    for key in dtypes:
        values.append( gdf_type(dtypes[key]))

    print('>>>> dtyps for', dtypes.values())
    print(values)
    return values

def get_type_schema(path):
    format = path.split('.')[-1]

    if format == 'parquet':
        return SchemaFrom.ParquetFile
    elif format == 'csv' or format == 'psv' or format.startswith("txt"):
        return SchemaFrom.CsvFile

def open_perf_table(table_ref):
    for key in table_ref.keys():
        sql = 'select * from main.%(table_name)s' % {"table_name": key.table_name}
        return pyblazing.run_query(sql, table_ref)

def run_gpu_workflow(quarter=1, year=2000, perf_file="", **kwargs):

    import time

    load_start_time = time.time()

    names = gpu_load_names()
    acq_gdf = gpu_load_acquisition_csv(acquisition_path=acq_data_path + "/Acquisition_"
                                                        + str(year) + "Q" + str(quarter) + ".txt")


    print("perf_file", perf_file)
    gdf = gpu_load_performance_csv(perf_file)

    load_end_time = time.time()

    etl_start_time = time.time()

    acq_gdf_results = merge_names(acq_gdf, names)

    everdf_results = create_ever_features(gdf)

    delinq_merge_results = create_delinq_features(gdf)

    new_everdf_results = join_ever_delinq_features(everdf_results.columns, delinq_merge_results.columns)

    joined_df_results = create_joined_df(gdf.columns, new_everdf_results.columns)
    del (new_everdf_results)

    testdf_results = create_12_mon_features_union(joined_df_results.columns)

    testdf = testdf_results.columns
    new_joined_df_results = combine_joined_12_mon(joined_df_results.columns, testdf)
    del (testdf)
    del (joined_df_results)
    perf_df_results = final_performance_delinquency(gdf.columns, new_joined_df_results.columns)
    del (gdf)
    del (new_joined_df_results)

    print('perf_df_results', perf_df_results.columns)
    print('acq_gdf_results', acq_gdf_results.columns)
    final_gdf_results = join_perf_acq_gdfs(perf_df_results.columns, acq_gdf_results.columns)
    del (perf_df_results)
    del (acq_gdf_results)

    print('before last_mile_cleaning', final_gdf_results.columns)

    final_gdf = last_mile_cleaning(final_gdf_results.columns)

    etl_end_time = time.time()
    return [(load_end_time - load_start_time), (etl_end_time - etl_start_time)]


def gpu_load_performance_csv(performance_path, **kwargs):
    """ Loads performance data
    Returns
    -------
    GPU DataFrame
    """
    chronometer = Chronometer.makeStarted()

    cols = [
        "loan_id", "monthly_reporting_period", "servicer", "interest_rate", "current_actual_upb",
        "loan_age", "remaining_months_to_legal_maturity", "adj_remaining_months_to_maturity",
        "maturity_date", "msa", "current_loan_delinquency_status", "mod_flag", "zero_balance_code",
        "zero_balance_effective_date", "last_paid_installment_date", "foreclosed_after",
        "disposition_date", "foreclosure_costs", "prop_preservation_and_repair_costs",
        "asset_recovery_costs", "misc_holding_expenses", "holding_taxes", "net_sale_proceeds",
        "credit_enhancement_proceeds", "repurchase_make_whole_proceeds", "other_foreclosure_proceeds",
        "non_interest_bearing_upb", "principal_forgiveness_upb", "repurchase_make_whole_proceeds_flag",
        "foreclosure_principal_write_off_amount", "servicing_activity_indicator"
    ]

    dtypes = OrderedDict([
        ("loan_id", "int64"),
        ("monthly_reporting_period", "date"),
        ("servicer", "category"),
        ("interest_rate", "float64"),
        ("current_actual_upb", "float64"),
        ("loan_age", "float64"),
        ("remaining_months_to_legal_maturity", "float64"),
        ("adj_remaining_months_to_maturity", "float64"),
        ("maturity_date", "date"),
        ("msa", "float64"),
        ("current_loan_delinquency_status", "int32"),
        ("mod_flag", "category"),
        ("zero_balance_code", "category"),
        ("zero_balance_effective_date", "date"),
        ("last_paid_installment_date", "date"),
        ("foreclosed_after", "date"),
        ("disposition_date", "date"),
        ("foreclosure_costs", "float64"),
        ("prop_preservation_and_repair_costs", "float64"),
        ("asset_recovery_costs", "float64"),
        ("misc_holding_expenses", "float64"),
        ("holding_taxes", "float64"),
        ("net_sale_proceeds", "float64"),
        ("credit_enhancement_proceeds", "float64"),
        ("repurchase_make_whole_proceeds", "float64"),
        ("other_foreclosure_proceeds", "float64"),
        ("non_interest_bearing_upb", "float64"),
        ("principal_forgiveness_upb", "float64"),
        ("repurchase_make_whole_proceeds_flag", "category"),
        ("foreclosure_principal_write_off_amount", "float64"),
        ("servicing_activity_indicator", "category")
    ])
    print("performance_path:", performance_path)
    
    print("params:", 'perf', get_type_schema(performance_path), performance_path, '|', cols, get_dtype_values(dtypes), 1)
    
    performance_table = pyblazing.create_table(table_name='perf', type=get_type_schema(performance_path), path=performance_path, delimiter='|', names=cols, dtypes=get_dtype_values(dtypes), skip_rows=1)
    Chronometer.show(chronometer, 'Read Performance CSV')
    return performance_table

def gpu_load_acquisition_csv(acquisition_path, **kwargs):
    """ Loads acquisition data
    Returns
    -------
    GPU DataFrame
    """
    chronometer = Chronometer.makeStarted()

    cols = [
        'loan_id', 'orig_channel', 'seller_name', 'orig_interest_rate', 'orig_upb', 'orig_loan_term',
        'orig_date', 'first_pay_date', 'orig_ltv', 'orig_cltv', 'num_borrowers', 'dti', 'borrower_credit_score',
        'first_home_buyer', 'loan_purpose', 'property_type', 'num_units', 'occupancy_status', 'property_state',
        'zip', 'mortgage_insurance_percent', 'product_type', 'coborrow_credit_score', 'mortgage_insurance_type',
        'relocation_mortgage_indicator'
    ]

    dtypes = OrderedDict([
        ("loan_id", "int64"),
        ("orig_channel", "category"),
        ("seller_name", "category"),
        ("orig_interest_rate", "float64"),
        ("orig_upb", "int64"),
        ("orig_loan_term", "int64"),
        ("orig_date", "date"),
        ("first_pay_date", "date"),
        ("orig_ltv", "float64"),
        ("orig_cltv", "float64"),
        ("num_borrowers", "float64"),
        ("dti", "float64"),
        ("borrower_credit_score", "float64"),
        ("first_home_buyer", "category"),
        ("loan_purpose", "category"),
        ("property_type", "category"),
        ("num_units", "int64"),
        ("occupancy_status", "category"),
        ("property_state", "category"),
        ("zip", "int64"),
        ("mortgage_insurance_percent", "float64"),
        ("product_type", "category"),
        ("coborrow_credit_score", "float64"),
        ("mortgage_insurance_type", "float64"),
        ("relocation_mortgage_indicator", "category")
    ])

    print(acquisition_path)

    acquisition_table = pyblazing.create_table(table_name='acq', type=get_type_schema(acquisition_path), path=acquisition_path, delimiter='|', names=cols, dtypes=get_dtype_values(dtypes), skip_rows=1)
    Chronometer.show(chronometer, 'Read Acquisition CSV')
    return acquisition_table

def gpu_load_names(**kwargs):
    """ Loads names used for renaming the banks
    Returns
    -------
    GPU DataFrame
    """
    chronometer = Chronometer.makeStarted()

    cols = [
        'seller_name', 'new_seller_name'
    ]

    dtypes = OrderedDict([
        ("seller_name", "category"),
        ("new_seller_name", "category"),
    ])

    names_table = pyblazing.create_table(table_name='names', type=get_type_schema(col_names_path), path=col_names_path, delimiter='|', names=cols, dtypes=get_dtype_values(dtypes), skip_rows=1)
    Chronometer.show(chronometer, 'Read Names CSV')
    return names_table


def merge_names(names_table, acq_table):
    chronometer = Chronometer.makeStarted()
    tables = {names_table.name: names_table.columns,
              acq_table.name:acq_table.columns}

    query = """SELECT loan_id, orig_channel, orig_interest_rate, orig_upb, orig_loan_term,
        orig_date, first_pay_date, orig_ltv, orig_cltv, num_borrowers, dti, borrower_credit_score,
        first_home_buyer, loan_purpose, property_type, num_units, occupancy_status, property_state,
        zip, mortgage_insurance_percent, product_type, coborrow_credit_score, mortgage_insurance_type,
        relocation_mortgage_indicator, new_seller_name as seller_name
        FROM main.acq as a LEFT OUTER JOIN main.names as n ON  a.seller_name = n.seller_name"""
    result = pyblazing.run_query(query, tables)
    Chronometer.show(chronometer, 'Create Acquisition (Merge Names)')
    return result


def create_ever_features(table, **kwargs):
    chronometer = Chronometer.makeStarted()
    query = """SELECT loan_id,
        max(current_loan_delinquency_status) >= 1 as ever_30,
        max(current_loan_delinquency_status) >= 3 as ever_90,
        max(current_loan_delinquency_status) >= 6 as ever_180
        FROM main.perf group by loan_id"""
    result = pyblazing.run_query(query, {table.name: table.columns})
    Chronometer.show(chronometer, 'Create Ever Features')
    return result


def create_delinq_features(table, **kwargs):
    chronometer = Chronometer.makeStarted()
    query = """SELECT loan_id,
        min(monthly_reporting_period) as delinquency_30
        FROM main.perf where current_loan_delinquency_status >= 1 group by loan_id"""
    result_delinq_30 = pyblazing.run_query(query, {table.name: table.columns})

    query = """SELECT loan_id,
        min(monthly_reporting_period) as delinquency_90
        FROM main.perf where current_loan_delinquency_status >= 3 group by loan_id"""
    result_delinq_90 = pyblazing.run_query(query, {table.name: table.columns})

    query = """SELECT loan_id,
        min(monthly_reporting_period) as delinquency_180
        FROM main.perf where current_loan_delinquency_status >= 6 group by loan_id"""
    result_delinq_180 = pyblazing.run_query(query, {table.name: table.columns})



    new_tables = {"delinq_30": result_delinq_30.columns, "delinq_90": result_delinq_90.columns, "delinq_180": result_delinq_180.columns}
    query = """SELECT d30.loan_id, delinquency_30, delinquency_90,
                delinquency_180 FROM main.delinq_30 as d30
                LEFT OUTER JOIN main.delinq_90 as d90 ON d30.loan_id = d90.loan_id
                LEFT OUTER JOIN main.delinq_180 as d180 ON d30.loan_id = d180.loan_id"""
    result_merge = pyblazing.run_query(query, new_tables)
    print(query)
    print(result_merge)
    print(result_merge.columns)
    if result_merge.columns['delinquency_90'].has_null_mask:
        result_merge.columns['delinquency_90'] = result_merge.columns['delinquency_90'].fillna(
            np.dtype('datetime64[ms]').type('1970-01-01').astype('datetime64[ms]'))

    if result_merge.columns['delinquency_180'].has_null_mask:
        result_merge.columns['delinquency_180'] = result_merge.columns['delinquency_180'].fillna(
            np.dtype('datetime64[ms]').type('1970-01-01').astype('datetime64[ms]'))

    Chronometer.show(chronometer, 'Create deliquency features')
    return result_merge


def join_ever_delinq_features(everdf_tmp, delinq_merge, **kwargs):
    chronometer = Chronometer.makeStarted()
    tables = {"everdf": everdf_tmp, "delinq": delinq_merge}
    query = """SELECT everdf.loan_id as loan_id, ever_30, ever_90, ever_180,
                  delinquency_30,
                  delinquency_90,
                  delinquency_180 FROM main.everdf as everdf
                  LEFT OUTER JOIN main.delinq as delinq ON everdf.loan_id = delinq.loan_id"""
    result_merge = pyblazing.run_query(query, tables)
    if result_merge.columns['delinquency_30'].has_null_mask:
        result_merge.columns['delinquency_30'] = result_merge.columns['delinquency_30'].fillna(
            np.dtype('datetime64[ms]').type('1970-01-01').astype('datetime64[ms]'))
    if result_merge.columns['delinquency_90'].has_null_mask:
        result_merge.columns['delinquency_90'] = result_merge.columns['delinquency_90'].fillna(
            np.dtype('datetime64[ms]').type('1970-01-01').astype('datetime64[ms]'))
    if result_merge.columns['delinquency_180'].has_null_mask:
        result_merge.columns['delinquency_180'] = result_merge.columns['delinquency_180'].fillna(
            np.dtype('datetime64[ms]').type('1970-01-01').astype('datetime64[ms]'))
    Chronometer.show(chronometer, 'Create ever deliquency features')
    return result_merge


def create_joined_df(gdf, everdf, **kwargs):
    chronometer = Chronometer.makeStarted()
    tables = {"perf": gdf, "everdf": everdf}

    query = """SELECT perf.loan_id as loan_id,
                perf.monthly_reporting_period as mrp_timestamp,
                EXTRACT(MONTH FROM perf.monthly_reporting_period) as timestamp_month,
                EXTRACT(YEAR FROM perf.monthly_reporting_period) as timestamp_year,
                perf.current_loan_delinquency_status as delinquency_12,
                perf.current_actual_upb as upb_12,
                everdf.ever_30 as ever_30,
                everdf.ever_90 as ever_90,
                everdf.ever_180 as ever_180,
                everdf.delinquency_30 as delinquency_30,
                everdf.delinquency_90 as delinquency_90,
                everdf.delinquency_180 as delinquency_180
                FROM main.perf as perf
                LEFT OUTER JOIN main.everdf as everdf ON perf.loan_id = everdf.loan_id"""

    results = pyblazing.run_query(query, tables)

    if results.columns['upb_12'].has_null_mask:
        results.columns['upb_12'] = results.columns['upb_12'].fillna(999999999)
    if results.columns['delinquency_12'].has_null_mask:
        results.columns['delinquency_12'] = results.columns['delinquency_12'].fillna(-1)
    if results.columns['ever_30'].has_null_mask:
        results.columns['ever_30'] = results.columns['ever_30'].astype('int8').fillna(-1)
    if results.columns['ever_90'].has_null_mask:
        results.columns['ever_90'] = results.columns['ever_90'].astype('int8').fillna(-1)
    if results.columns['ever_180'].has_null_mask:
        results.columns['ever_180'] = results.columns['ever_180'].astype('int8').fillna(-1)
    if results.columns['delinquency_30'].has_null_mask:
        results.columns['delinquency_30'] = results.columns['delinquency_30'].fillna(-1)
    if results.columns['delinquency_90'].has_null_mask:
        results.columns['delinquency_90'] = results.columns['delinquency_90'].fillna(-1)
    if results.columns['delinquency_180'].has_null_mask:
        results.columns['delinquency_180'] = results.columns['delinquency_180'].fillna(-1)

    Chronometer.show(chronometer, 'Create Joined DF')
    return results


def create_12_mon_features_union(joined_df, **kwargs):
    chronometer = Chronometer.makeStarted()
    tables = {"joined_df": joined_df}
    josh_mody_n_str = "timestamp_year * 12 + timestamp_month - 24000.0"
    query = "SELECT loan_id, " + josh_mody_n_str + " as josh_mody_n, max(delinquency_12) as max_d12, min(upb_12) as min_upb_12  FROM main.joined_df as joined_df GROUP BY loan_id, " + josh_mody_n_str
    mastertemp = pyblazing.run_query(query, tables)

    all_temps = []
    all_tokens = []
    tables = {"joined_df": mastertemp.columns}
    n_months = 12

    for y in range(1, n_months + 1):
        josh_mody_n_str = "floor((josh_mody_n - " + str(y) + ")/12.0)"
        query = "SELECT loan_id, " + josh_mody_n_str + " as josh_mody_n, max(max_d12) > 3 as max_d12_gt3, min(min_upb_12) = 0 as min_upb_12_eq0, min(min_upb_12) as upb_12  FROM main.joined_df as joined_df GROUP BY loan_id, " + josh_mody_n_str

        metaToken = pyblazing.run_query_get_token(query, tables)
        all_tokens.append(metaToken)

    for metaToken in all_tokens:
        temp = pyblazing.run_query_get_results(metaToken)
        all_temps.append(temp)

    y = 1
    tables2 = {"temp1": all_temps[0].columns}
    union_query = "(SELECT loan_id, max_d12_gt3 + min_upb_12_eq0 as delinquency_12, upb_12, floor(((josh_mody_n * 12) + " + str(
            24000 + (y - 1)) + ")/12) as timestamp_year, josh_mody_n * 0 + " + str(
            y) + " as timestamp_month from main.temp" + str(y) + ")"
    for y in range(2, n_months + 1):
        tables2["temp" + str(y)] = all_temps[y-1].columns
        query = " UNION ALL (SELECT loan_id, max_d12_gt3 + min_upb_12_eq0 as delinquency_12, upb_12, floor(((josh_mody_n * 12) + " + str(
            24000 + (y - 1)) + ")/12) as timestamp_year, josh_mody_n * 0 + " + str(
            y) + " as timestamp_month from main.temp" + str(y) + ")"
        union_query = union_query + query

    results = pyblazing.run_query(union_query, tables2)
    Chronometer.show(chronometer, 'Create 12 month features once')
    return results


def combine_joined_12_mon(joined_df, testdf, **kwargs):
    chronometer = Chronometer.makeStarted()
    tables = {"joined_df": joined_df, "testdf": testdf}
    query = """SELECT j.loan_id, j.mrp_timestamp, j.timestamp_month, j.timestamp_year,
                j.ever_30, j.ever_90, j.ever_180, j.delinquency_30, j.delinquency_90, j.delinquency_180,
                t.delinquency_12, t.upb_12
                FROM main.joined_df as j LEFT OUTER JOIN main.testdf as t
                ON j.loan_id = t.loan_id and j.timestamp_year = t.timestamp_year and j.timestamp_month = t.timestamp_month"""
    results = pyblazing.run_query(query, tables)
    Chronometer.show(chronometer, 'Combine joind 12 month')
    return results


def final_performance_delinquency(gdf, joined_df, **kwargs):
    chronometer = Chronometer.makeStarted()
    tables = {"gdf": gdf, "joined_df": joined_df}
    query = """SELECT g.loan_id, current_actual_upb, current_loan_delinquency_status, delinquency_12, interest_rate, loan_age, mod_flag, msa, non_interest_bearing_upb
        FROM main.gdf as g LEFT OUTER JOIN main.joined_df as j
        ON g.loan_id = j.loan_id and EXTRACT(YEAR FROM g.monthly_reporting_period) = j.timestamp_year and EXTRACT(MONTH FROM g.monthly_reporting_period) = j.timestamp_month """
    results = pyblazing.run_query(query, tables)
    Chronometer.show(chronometer, 'Final performance delinquency')
    return results


def join_perf_acq_gdfs(perf, acq, **kwargs):
    chronometer = Chronometer.makeStarted()
    tables = {"perf": perf, "acq": acq}
    query = """SELECT p.loan_id, current_actual_upb, current_loan_delinquency_status, delinquency_12, interest_rate, loan_age, mod_flag, msa, non_interest_bearing_upb,
     borrower_credit_score, dti, first_home_buyer, loan_purpose, mortgage_insurance_percent, num_borrowers, num_units, occupancy_status,
     orig_channel, orig_cltv, orig_date, orig_interest_rate, orig_loan_term, orig_ltv, orig_upb, product_type, property_state, property_type,
     relocation_mortgage_indicator, seller_name, zip FROM main.perf as p LEFT OUTER JOIN main.acq as a ON p.loan_id = a.loan_id"""
    results = pyblazing.run_query(query, tables)
    Chronometer.show(chronometer, 'Join performance acquitistion gdfs')
    return results


def last_mile_cleaning(df, **kwargs):
    chronometer = Chronometer.makeStarted()
    print(df)
    for col, dtype in df.dtypes.iteritems():
        if str(dtype) == 'category':
            df[col] = df[col].cat.codes
        df[col] = df[col].astype('float32')
    df['delinquency_12'] = df['delinquency_12'] > 0
    df['delinquency_12'] = df['delinquency_12'].fillna(False).astype('int32')
    for column in df.columns:
        df[column] = df[column].fillna(-1)
    Chronometer.show(chronometer, 'Last mile cleaning')
    return df


def gpu_workflow(): 
    parser = argparse.ArgumentParser(description='gpu workflow.')
    parser.add_argument("quarter", help="Sample")
    parser.add_argument("year", help="Sample")
    parser.add_argument("perf_file", help="Sample")

    args = parser.parse_args()
    quarter = args.quarter
    year = args.year
    perf_file = args.perf_file

    
    load_start_time = time.time()

    names = gpu_load_names()
    acq_gdf = gpu_load_acquisition_csv(acquisition_path=acq_data_path + "/Acquisition_"
                                                        + str(year) + "Q" + str(quarter) + ".txt")


    gdf = gpu_load_performance_csv(perf_file)

    load_end_time = time.time()

    etl_start_time = time.time()

    acq_gdf_results = merge_names(acq_gdf, names)

    everdf_results = create_ever_features(gdf)

    delinq_merge_results = create_delinq_features(gdf)

    new_everdf_results = join_ever_delinq_features(everdf_results.columns, delinq_merge_results.columns)

    joined_df_results = create_joined_df(gdf.columns, new_everdf_results.columns)
    del (new_everdf_results)

    testdf_results = create_12_mon_features_union(joined_df_results.columns)

    testdf = testdf_results.columns
    new_joined_df_results = combine_joined_12_mon(joined_df_results.columns, testdf)
    del (testdf)
    del (joined_df_results)
    perf_df_results = final_performance_delinquency(gdf.columns, new_joined_df_results.columns)
    del (gdf)
    del (new_joined_df_results)

    final_gdf_results = join_perf_acq_gdfs(perf_df_results.columns, acq_gdf_results.columns)
    del (perf_df_results)
    del (acq_gdf_results)

    final_gdf = last_mile_cleaning(final_gdf_results.columns)

    etl_end_time = time.time()
    
    
    with open('/blazingdb/data/tpch/results/'   +  str(year) + "Q" + str(quarter)  +'.txt', 'w') as file:
        file.write(str(load_end_time - load_start_time) + " " + str(etl_end_time - etl_start_time))
    return 1


use_registered_hdfs = False
use_registered_posix = True

if use_registered_hdfs:
    register_hdfs()
elif use_registered_posix:
    register_posix()

# to download data for this notebook, visit https://rapidsai.github.io/demos/datasets/mortgage-data and update the following paths accordingly

acq_data_path = ""
perf_data_path = ""
col_names_path = ""
if use_registered_hdfs:
    acq_data_path = "hdfs://myLocalHdfs/data/acq"
    perf_data_path = "hdfs://myLocalHdfs/data/perf"
    col_names_path = "hdfs://myLocalHdfs/data/names.csv"
elif use_registered_posix:
    acq_data_path = "/blazingdb/data/tpch/acq"
    perf_data_path = "/blazingdb/data/tpch/perf"
    col_names_path = "/blazingdb/data/tpch/names.csv"

start_year = 2000
end_year = 2000  # end_year is inclusive
start_quarter = 1
end_quarter = 3
#i think this can be commented
#part_count = 1  # the number of data files to train against

if __name__ == "__main__":
    gpu_workflow()

