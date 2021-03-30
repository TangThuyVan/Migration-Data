from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from config import config as cf
from service.model import ConnPostgre
from service.validation import Validation
import pandas as pd
import json
from datetime import date

app = Flask(__name__)
app.debug = True

bad_tb = cf.bad_table
na_tb = cf.native_table

@app.route('/validate', methods=['POST'])
def update():
    mess = ''
    try:
        if request.files['file']:
            file = request.files.get('file')
            df_native, df_bad = check(file)

            df_bad.to_csv(bad_tb, index=False)
            df_native.to_csv(na_tb, index=False)
            

            data = pd.read_csv(na_tb)
            dataFrame = pd.DataFrame(data)
            conn = ConnPostgre(cf.HOST, cf.USER, cf.PASSWORD, cf.DATABASE)
            conn.sql_insert('car', dataFrame)
        
        return 'success'
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }


@app.route('/query', methods=['POST'])
def check(file_csv):
    data = pd.read_csv(file_csv)
    dataFrame = pd.DataFrame(data)

    query = Validation()
    mess = "success"
    try:
        df_native = query.day_update(dataFrame)

        columns_name = ['Normalized-losses', 'Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke','Horsepower', 'peak-rpm','Price']
        check_int_bad, df_native = query.check_value(df_native, columns_name)

        column_name = 'Drive-wheels'
        check_length_bad, df_native = query.check_length(df_native, column_name)

        check_dup_bad, df_native = query.check_dup(df_native)

        columns_name = ['Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke','Horsepower', 'peak-rpm']
        df_native = query.change_type_float(df_native,columns_name)

        columns_name = ['Normalized-losses', 'Price']
        df_native = query.change_type_int(df_native,columns_name)

        columns_name = {"No" : "id",
                        "Symboling" : "symboling",
                        "Normalized-losses" : "normalized_losses",
                        "Make" : "make",
                        "Fuel-type" : "fuel_type",
                        "Aspiration" : "aspiration",
                        "Num-of-doors" : "num_of_doors",
                        "Body-style" : "body_style",
                        "Drive-wheels" : "drive_wheels",
                        "Engine-location" : "engine_location",
                        "Wheel-base" : "wheel_base",
                        "Length" : "length",
                        "Width" : "width",
                        "Height" : "height",
                        "Curb-weight" : "curb_weight",
                        "Engine-type" : "engine_type",
                        "Num-of-cylinders" : "num_of_cylinders",
                        "Engine-size" : "engine_size",
                        "Fuel-system" : "fuel_system",
                        "Bore" : "bore",
                        "Stroke" : "stroke",
                        "Compression-ratio" : "compression_ratio",
                        "Horsepower" : "horsepower",
                        "peak-rpm" : "peak_rpm",
                        "city-mpg" : "city_mpg",
                        "highway-mpg" : "highway_mpg",
                        "Price" : "price"}
        df_native = query.re_name(df_native, columns_name)

        df_bad = pd.concat([check_int_bad, check_length_bad, check_dup_bad])

        return df_native, df_bad

    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }

