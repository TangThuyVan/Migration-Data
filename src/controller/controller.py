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
        check_int_bad, df_native = query.check_int(df_native)
        check_length_bad, df_native = query.check_length(df_native)
        check_dup_bad, df_native = query.check_dup(df_native)
        re_na = query.re_name(df_native)

        df_bad = pd.concat([check_int_bad, 
                            check_length_bad,
                            check_dup_bad])

        return df_native, df_bad

    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }