from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import config as cf
from service.model import ConnPostgre
from service.validation import Validation
import pandas as pd
import json

app = Flask(__name__)
app.debug = True

# from controller import view
data = pd.read_csv('D:\car_sample_data.csv', sep=';', index_col=0)
dataFrame = pd.DataFrame(data)
mess = "success"

# if request.files['file']:
#   print(request.files.get['file'])

@app.route('/insert')
def insert():
    try:
        data = pd.read_csv('D:\car_sample_data.csv', sep=';', index_col=0)
        dataFrame = pd.DataFrame(data)

        conn = ConnPostgre(cf.HOST, cf.USER, cf.PASSWORD, cf.DATABASE)
        conn.sql_insert('carv2', dataFrame)
        return 'success'
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }


@app.route('/query')
def check():
    try:
        price = Validation()
        price_check = price.check_price(dataFrame)
        return price_check
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }
    

@app.route('/query2')
def check2():
    try:
        length = Validation()
        check_length = length.check_length(dataFrame)
        return check_length
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }
    

@app.route('/query3')
def check3():
    try:
        dtypes = Validation()
        check_dtypes = dtypes.check_dtype(dataFrame)
        return check_dtypes
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }

@app.route('/query4')
def check4():
    try:
        name = Validation()
        re_na = name.re_name(dataFrame)
        return re_na
    except Exception as ex:
        mess = ex
    return {'message': str(mess),
             'status' : 'connect failed'  }
