from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import config as cf
from service.model import ConnPostgre
from service.validation import Validation
import pandas as pd
import json
from datetime import date

app = Flask(__name__)
app.debug = True

tb = cf.car_table
bad_tb = cf.bad_table
na_tb = cf.native_table

data = pd.read_csv(tb)
dataFrame = pd.DataFrame(data)
conn = ConnPostgre(cf.HOST, cf.USER, cf.PASSWORD, cf.DATABASE)
mess = "success"
query = Validation()


# if request.files['file']:
#   print(request.files.get['file'])

@app.route('/insert')
def insert():
    try:
        data = pd.read_csv(na_tb)
        dataFrame = pd.DataFrame(data)
        conn = ConnPostgre(cf.HOST, cf.USER, cf.PASSWORD, cf.DATABASE)
        conn.sql_insert('car_table', dataFrame)
        return 'success'
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }

# @app.route('/query')
# def check():
#     try:
#         price_check_bad, price_check_native = query.check_price(dataFrame)
#         price_check_bad.to_csv(bad_tb, index=True, mode='a')
#         price_check_native.to_csv(na_tb, index=True, mode='a')
#         return "ok"
#     except Exception as ex:
#         mess = ex
#     return {'message': str(mess),
#              'status' : 'connect failed'  }
    

# @app.route('/query2')
# def check2():
#     col = input("Enter column name: ")
#     try:
#         check_length_bad, check_length_native = query.check_length(col, dataFrame)
#         check_length_bad.to_csv(bad_tb, index=True, mode='a', header=False)
#         check_length_native.to_csv(na_tb, index=True, mode='a', header=False)
#         return "ok"
#     except Exception as ex:
#         mess = ex
#     return {'message': str(mess),
#              'status' : 'connect failed'  }
    

# @app.route('/query3')
# def check3():
#     try:
#         check_dtypes = query.check_dtype(dataFrame)
#         return check_dtypes
#     except Exception as ex:
#         mess = ex
#     return {'message': str(mess),
#              'status' : 'connect failed'  }

# @app.route('/query4')
# def check4():
#     try:
#         check_dup_bad, check_dup_native, dt = query.check_dup(dataFrame)
#         check_dup_bad.to_csv(bad_tb, index=True, mode='a', header=False)
#         check_dup_native.to_csv(na_tb, index=True, mode='a', header=False)
#         return "ok"
#     except Exception as ex:
#         mess = ex
#     return {'message': str(mess),
#              'status' : 'connect failed'  }

# @app.route('/query5')
# def check5():
#     try:
#         re_na = query.re_name(native_frame)
#         return re_na
#     except Exception as ex:
#         mess = ex
#     return {'message': str(mess),
#              'status' : 'connect failed'  }

# @app.route('/query6')
# def check6():
#     try:
#         day = query.day_update(native_frame)
#         conn.sql_change('na_tb', day)
#         return "ok"
#     except Exception as ex:
#         mess = ex
#     return {'message': str(mess),
#              'status' : 'connect failed'  }

@app.route('/query7')
def check7():
    col = input("Enter column name: ")
    col1 = input("Enter column name: ")
    col2 = input("Enter column name: ")
    col3 = input("Enter column name: ")
    try:
        df_native = query.day_update(dataFrame)
        price_check_price_bad, df_native = query.check_price(col, df_native)
        # price_check_length_bad, df_native = query.check_price(col1, df_native)
        # price_check_width_bad, df_native = query.check_price(col2, df_native)
        # price_check_height_bad, df_native = query.check_price(col3, df_native)
        check_length_bad, df_native = query.check_length(col, df_native)
        check_dup_bad, df_native= query.check_dup(df_native)
        re_na = query.re_name(df_native)

        df_bad = pd.concat([price_check_price_bad, 
                            # price_check_length_bad, 
                            # price_check_width_bad,
                            # price_check_height_bad,
                            check_length_bad,
                            check_dup_bad])
        # df_native = pd.concat([price_check_native, check_length_native, check_dup_native])

        df_bad.to_csv(bad_tb, index=False)
        df_native.to_csv(na_tb, index=False)

        # re_na = query.re_name(native_frame)
        # day = query.day_update(native_frame)
        return 'ok'
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }