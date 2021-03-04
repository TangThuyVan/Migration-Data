from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from config import config as cf
from service.model import ConnPostgre
import pandas as pd
import numpy as np
import json
import re



class Validation:
    def __init__(self):
        super().__init__()
    def check_price(self, dataFrame):
        # remove "?", "free"
        df_n1 = pd.DataFrame(dataFrame.loc[dataFrame['Price'].str.isnumeric() == False])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['Price'].str.isnumeric() == False].index, inplace=True))
        # remove data null 
        df_n2 = pd.DataFrame(dataFrame.loc[dataFrame['Price'].isna()])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame['Price'].isna()].index, inplace=True))
        # noi 2 bang da remove
        df_null = pd.concat([df_n1,df_n2])
        return df_null, dataFrame
    def check_length(self, col, dataFrame):
        # remove gia tri co do dai >5
        length_native = pd.DataFrame(dataFrame.loc[dataFrame[col].str.len() > 5])
        pd.DataFrame(dataFrame.drop(dataFrame[dataFrame[col].str.len() > 5].index, inplace=True))
        return length_native, dataFrame

    def check_dtype(self, dataFrame):
        data = ['Height', 'Width', 'Length', 'Engine-size', 'Bore', 'Stroke', 'Price']
        for i in range(0,len(data)-1):
            if (dataFrame[data[i]].dtypes != np.int64):
                df = dataFrame.drop(data[i], axis = 1, inplace=True)
                return df
            else: 
                return 'no'
    def check_dup(self, dataFrame):
        dup = dataFrame.duplicated()
        df_dup = dataFrame.drop_duplicates
        return dup, df_dup
    def re_name(self,dataFrame):
        name = dataFrame.rename(columns = {"Fuel-type":"type","Num-of-cylinders":"Num_cylinders"}, inplace = True)
        return str(dataFrame.columns)
    def day_update(self,dataFrame):
        t = []
        for s in dataFrame['Load-date']:
            new_str = re.sub('/\d*/','/01/',s)
            t.append(new_str)
        tb = pd.DataFrame(t)
        dataFrame['New-Load-date'] = tb
        new_df = dataFrame.drop('Load-date', axis = 1)
        return new_df
