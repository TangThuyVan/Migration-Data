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

data = pd.read_csv(tb, index_col=0)
dataFrame = pd.DataFrame(data)
conn = ConnPostgre(cf.HOST, cf.USER, cf.PASSWORD, cf.DATABASE)
mess = "success"
query = Validation()

# if request.files['file']:
#   print(request.files.get['file'])

@app.route('/insert')
def insert():
    try:
        # data = pd.read_csv('C:/Users/Administrator/Desktop/task1/car_sample_data1.csv', index_col=0)
        # dataFrame = pd.DataFrame(data)
        # print(dataFrame)
        conn = ConnPostgre(cf.HOST, cf.USER, cf.PASSWORD, cf.DATABASE)
        conn.sql_insert('carv2', dataFrame)
        return 'success'
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }

@app.route('/tocsv')
def save():
    try:
        dataFrame.to_csv('')
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }    

@app.route('/query')
def check():
    try:
        price_check_bad, price_check_native = query.check_price(dataFrame)
        price_check_bad.to_csv(bad_tb, index=True, mode='a',)
        price_check_native.to_csv(na_tb, index=True, mode='a')
        return "ok"
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }
    

@app.route('/query2')
def check2():
    col = input("Enter column name: ")
    try:
        check_length_bad, check_length_native = query.check_length(col, dataFrame)
        check_length_bad.to_csv(bad_tb, index=True, mode='a', header=False)
        check_length_native.to_csv(na_tb, index=True, mode='a', header=False)
        return "ok"
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }
    

@app.route('/query3')
def check3():
    try:
        check_dtypes = query.check_dtype(dataFrame)
        return check_dtypes
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }

@app.route('/query4')
def check4():
    try:
        re_na = query.re_name(dataFrame)
        return re_na
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }

@app.route('/query5')
def check5():
    try:
        day = query.day_update(dataFrame)
        conn.sql_change('carv2', day)
        return "ok"
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }
